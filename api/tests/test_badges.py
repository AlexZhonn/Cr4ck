"""
Integration tests for the Badges / Achievements system.

Covers:
- GET /api/v1/badges        — public catalog
- GET /api/v1/badges/me     — user's earned badges (auth required)
- Badge awarding via POST /api/v1/evaluate (mocked AI)
- GET /auth/v1/me           — badges included in profile response
"""

from unittest.mock import patch
import pytest
from tests.conftest import db_required

pytestmark = [pytest.mark.asyncio, db_required]

# ── Helpers ──────────────────────────────────────────────────────────────────

async def _login(client, user) -> str:
    resp = await client.post(
        "/auth/v1/login",
        json={"email": user["email"], "password": user["password"]},
    )
    return resp.json()["access_token"]


def _make_ai_response(score: int) -> dict:
    return {
        "score": score,
        "summary": "Test summary.",
        "strengths": ["Good structure"],
        "improvements": ["Add docs"],
        "oop_feedback": "Good OOP.",
        "architecture_feedback": "Solid design.",
    }


# ── Catalog endpoint ─────────────────────────────────────────────────────────

class TestBadgeCatalog:
    async def test_public_catalog_returns_list(self, client):
        """GET /api/v1/badges should return a non-empty list without auth."""
        resp = await client.get("/api/v1/badges")
        assert resp.status_code == 200
        data = resp.json()
        assert isinstance(data, list)
        assert len(data) >= 15

    async def test_catalog_badge_shape(self, client):
        """Each badge in the catalog must have id, label, description, icon."""
        resp = await client.get("/api/v1/badges")
        badge = resp.json()[0]
        assert "id" in badge
        assert "label" in badge
        assert "description" in badge
        assert "icon" in badge


# ── /badges/me endpoint ──────────────────────────────────────────────────────

class TestMyBadges:
    async def test_unauthenticated_returns_401(self, client):
        resp = await client.get("/api/v1/badges/me")
        assert resp.status_code in (401, 403)

    async def test_authenticated_returns_empty_list_for_new_user(self, client, verified_user):
        token = await _login(client, verified_user)
        resp = await client.get(
            "/api/v1/badges/me",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert resp.status_code == 200
        assert resp.json() == []


# ── Badge awarding via evaluate ──────────────────────────────────────────────

class TestBadgeAwarding:
    async def test_first_solve_badge_awarded(self, client, verified_user, db):
        """Submitting any challenge for the first time should award first_solve."""
        token = await _login(client, verified_user)

        # Grab a real challenge id from the DB
        with db.cursor() as cur:
            cur.execute("SELECT id FROM challenges WHERE is_active = TRUE LIMIT 1")
            row = cur.fetchone()
        if not row:
            pytest.skip("No active challenges in DB")
        challenge_id = str(row["id"])

        with patch("routers.evaluate._run_evaluation", return_value=_make_ai_response(85)):
            resp = await client.post(
                "/api/v1/evaluate",
                headers={"Authorization": f"Bearer {token}"},
                json={
                    "challenge_id": challenge_id,
                    "challenge_title": "Test Challenge",
                    "language": "python",
                    "code": "class Foo: pass",
                    "problem_description": "Test",
                },
            )

        assert resp.status_code == 200
        data = resp.json()
        badge_ids = [b["id"] for b in data.get("badges_earned", [])]
        assert "first_solve" in badge_ids, f"Expected first_solve in {badge_ids}"
        # Score 85 → score_80 badge too
        assert "score_80" in badge_ids, f"Expected score_80 in {badge_ids}"

        # Clean up
        with db.cursor() as cur:
            cur.execute(
                "DELETE FROM user_badges WHERE user_id = %s", (verified_user["id"],)
            )
            cur.execute(
                "DELETE FROM submissions WHERE user_id = %s", (verified_user["id"],)
            )
            cur.execute(
                "DELETE FROM user_challenges WHERE user_id = %s", (verified_user["id"],)
            )
        db.commit()

    async def test_perfect_score_badges_awarded(self, client, verified_user, db):
        """Score 100 should award first_perfect (and first_solve on first attempt)."""
        token = await _login(client, verified_user)

        with db.cursor() as cur:
            cur.execute("SELECT id FROM challenges WHERE is_active = TRUE LIMIT 1")
            row = cur.fetchone()
        if not row:
            pytest.skip("No active challenges in DB")
        challenge_id = str(row["id"])

        with patch("routers.evaluate._run_evaluation", return_value=_make_ai_response(100)):
            resp = await client.post(
                "/api/v1/evaluate",
                headers={"Authorization": f"Bearer {token}"},
                json={
                    "challenge_id": challenge_id,
                    "challenge_title": "Test",
                    "language": "python",
                    "code": "class Perfect: pass",
                },
            )

        assert resp.status_code == 200
        badge_ids = [b["id"] for b in resp.json().get("badges_earned", [])]
        assert "first_perfect" in badge_ids
        assert "score_90" in badge_ids

        # Clean up
        with db.cursor() as cur:
            cur.execute("DELETE FROM user_badges WHERE user_id = %s", (verified_user["id"],))
            cur.execute("DELETE FROM submissions WHERE user_id = %s", (verified_user["id"],))
            cur.execute("DELETE FROM user_challenges WHERE user_id = %s", (verified_user["id"],))
        db.commit()

    async def test_no_duplicate_badge_on_retry(self, client, verified_user, db):
        """Submitting the same challenge twice should not re-award first_solve."""
        token = await _login(client, verified_user)

        with db.cursor() as cur:
            cur.execute("SELECT id FROM challenges WHERE is_active = TRUE LIMIT 1")
            row = cur.fetchone()
        if not row:
            pytest.skip("No active challenges in DB")
        challenge_id = str(row["id"])

        payload = {
            "challenge_id": challenge_id,
            "challenge_title": "Test",
            "language": "python",
            "code": "class Foo: pass",
        }

        with patch("routers.evaluate._run_evaluation", return_value=_make_ai_response(85)):
            await client.post(
                "/api/v1/evaluate",
                headers={"Authorization": f"Bearer {token}"},
                json=payload,
            )
            resp2 = await client.post(
                "/api/v1/evaluate",
                headers={"Authorization": f"Bearer {token}"},
                json=payload,
            )

        assert resp2.status_code == 200
        badge_ids = [b["id"] for b in resp2.json().get("badges_earned", [])]
        assert "first_solve" not in badge_ids, "first_solve should not be awarded on retry"

        # Clean up
        with db.cursor() as cur:
            cur.execute("DELETE FROM user_badges WHERE user_id = %s", (verified_user["id"],))
            cur.execute("DELETE FROM submissions WHERE user_id = %s", (verified_user["id"],))
            cur.execute("DELETE FROM user_challenges WHERE user_id = %s", (verified_user["id"],))
        db.commit()


# ── /auth/me includes badges ─────────────────────────────────────────────────

class TestMeIncludesBadges:
    async def test_me_returns_badges_field(self, client, verified_user):
        """/auth/v1/me must include a badges list (empty for a new user)."""
        token = await _login(client, verified_user)
        resp = await client.get(
            "/auth/v1/me",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert "badges" in data
        assert isinstance(data["badges"], list)
