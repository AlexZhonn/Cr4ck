"""
Integration tests for Solution Showcase endpoints.

Covers:
- POST /api/v1/challenges/:id/share   — share (auth required, score ≥ 80)
- DELETE /api/v1/challenges/:id/share — unshare (auth required)
- GET /api/v1/challenges/:id/top-solutions — list (auth required, must have attempted)

Auth flow: each test logs in via /auth/v1/login to obtain an access token.
"""

import pytest
from tests.conftest import db_required

pytestmark = [pytest.mark.asyncio, db_required]

CHALLENGE_ID = "test-sol-challenge"
GOOD_CODE = "class Solution:\n    pass\n"
LANGUAGE = "python"


async def _login(client, user: dict) -> str:
    """Helper: log in and return an access token."""
    resp = await client.post(
        "/auth/v1/login",
        json={"email": user["email"], "password": user["password"]},
    )
    assert resp.status_code == 200, f"login failed: {resp.text}"
    return resp.json()["access_token"]


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------


@pytest.fixture
def user_with_low_score(db, verified_user):
    """User who has attempted the challenge with score < 80."""
    with db.cursor() as cur:
        cur.execute(
            """INSERT INTO user_challenges
               (user_id, challenge_id, best_score, attempts)
               VALUES (%s, %s, 50, 1)
               ON CONFLICT (user_id, challenge_id) DO UPDATE
                 SET best_score = 50""",
            (verified_user["id"], CHALLENGE_ID),
        )
    db.commit()
    yield verified_user
    with db.cursor() as cur:
        cur.execute(
            "DELETE FROM user_challenges WHERE user_id = %s AND challenge_id = %s",
            (verified_user["id"], CHALLENGE_ID),
        )
    db.commit()


@pytest.fixture
def user_with_high_score(db, verified_user):
    """User who has attempted the challenge with score ≥ 80."""
    with db.cursor() as cur:
        cur.execute(
            """INSERT INTO user_challenges
               (user_id, challenge_id, best_score, attempts)
               VALUES (%s, %s, 90, 1)
               ON CONFLICT (user_id, challenge_id) DO UPDATE
                 SET best_score = 90""",
            (verified_user["id"], CHALLENGE_ID),
        )
    db.commit()
    yield verified_user
    with db.cursor() as cur:
        cur.execute(
            "DELETE FROM user_challenges WHERE user_id = %s AND challenge_id = %s",
            (verified_user["id"], CHALLENGE_ID),
        )
    db.commit()


# ---------------------------------------------------------------------------
# POST /challenges/:id/share
# ---------------------------------------------------------------------------


class TestShareSolution:
    async def test_unauthenticated_returns_401(self, client):
        resp = await client.post(
            f"/api/v1/challenges/{CHALLENGE_ID}/share",
            json={"code": GOOD_CODE, "language": LANGUAGE},
        )
        assert resp.status_code == 401

    async def test_share_without_attempt_returns_404(self, client, verified_user):
        token = await _login(client, verified_user)
        resp = await client.post(
            f"/api/v1/challenges/{CHALLENGE_ID}/share",
            json={"code": GOOD_CODE, "language": LANGUAGE},
            headers={"Authorization": f"Bearer {token}"},
        )
        assert resp.status_code == 404

    async def test_share_with_low_score_returns_403(self, client, user_with_low_score):
        token = await _login(client, user_with_low_score)
        resp = await client.post(
            f"/api/v1/challenges/{CHALLENGE_ID}/share",
            json={"code": GOOD_CODE, "language": LANGUAGE},
            headers={"Authorization": f"Bearer {token}"},
        )
        assert resp.status_code == 403

    async def test_share_with_high_score_returns_200(self, client, user_with_high_score):
        token = await _login(client, user_with_high_score)
        resp = await client.post(
            f"/api/v1/challenges/{CHALLENGE_ID}/share",
            json={"code": GOOD_CODE, "language": LANGUAGE},
            headers={"Authorization": f"Bearer {token}"},
        )
        assert resp.status_code == 200
        assert "message" in resp.json()

    async def test_share_is_idempotent(self, client, user_with_high_score):
        """Calling share twice should succeed without error."""
        token = await _login(client, user_with_high_score)
        headers = {"Authorization": f"Bearer {token}"}
        payload = {"code": GOOD_CODE, "language": LANGUAGE}
        r1 = await client.post(f"/api/v1/challenges/{CHALLENGE_ID}/share", json=payload, headers=headers)
        r2 = await client.post(f"/api/v1/challenges/{CHALLENGE_ID}/share", json=payload, headers=headers)
        assert r1.status_code == 200
        assert r2.status_code == 200


# ---------------------------------------------------------------------------
# DELETE /challenges/:id/share
# ---------------------------------------------------------------------------


class TestUnshareSolution:
    async def test_unauthenticated_returns_401(self, client):
        resp = await client.delete(f"/api/v1/challenges/{CHALLENGE_ID}/share")
        assert resp.status_code == 401

    async def test_unshare_without_attempt_returns_404(self, client, verified_user):
        token = await _login(client, verified_user)
        resp = await client.delete(
            f"/api/v1/challenges/{CHALLENGE_ID}/share",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert resp.status_code == 404

    async def test_unshare_after_share_succeeds(self, client, user_with_high_score):
        token = await _login(client, user_with_high_score)
        headers = {"Authorization": f"Bearer {token}"}
        await client.post(
            f"/api/v1/challenges/{CHALLENGE_ID}/share",
            json={"code": GOOD_CODE, "language": LANGUAGE},
            headers=headers,
        )
        resp = await client.delete(
            f"/api/v1/challenges/{CHALLENGE_ID}/share", headers=headers
        )
        assert resp.status_code == 200


# ---------------------------------------------------------------------------
# GET /challenges/:id/top-solutions
# ---------------------------------------------------------------------------


class TestTopSolutions:
    async def test_unauthenticated_returns_401(self, client):
        resp = await client.get(f"/api/v1/challenges/{CHALLENGE_ID}/top-solutions")
        assert resp.status_code == 401

    async def test_no_attempt_returns_403(self, client, verified_user):
        """User has not attempted the challenge — should be forbidden."""
        token = await _login(client, verified_user)
        resp = await client.get(
            f"/api/v1/challenges/{CHALLENGE_ID}/top-solutions",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert resp.status_code == 403

    async def test_after_attempt_returns_list(self, client, user_with_high_score):
        token = await _login(client, user_with_high_score)
        resp = await client.get(
            f"/api/v1/challenges/{CHALLENGE_ID}/top-solutions",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert resp.status_code == 200
        assert isinstance(resp.json(), list)

    async def test_shared_solution_appears_in_list(self, client, user_with_high_score):
        token = await _login(client, user_with_high_score)
        headers = {"Authorization": f"Bearer {token}"}
        # Share solution
        await client.post(
            f"/api/v1/challenges/{CHALLENGE_ID}/share",
            json={"code": GOOD_CODE, "language": LANGUAGE},
            headers=headers,
        )
        resp = await client.get(
            f"/api/v1/challenges/{CHALLENGE_ID}/top-solutions", headers=headers
        )
        assert resp.status_code == 200
        solutions = resp.json()
        assert len(solutions) >= 1
        mine = next((s for s in solutions if s["author"]["username"] == user_with_high_score["username"]), None)
        assert mine is not None
        assert mine["score"] == 90
        assert mine["language"] == LANGUAGE
        assert mine["code"] == GOOD_CODE

    async def test_solution_shape(self, client, user_with_high_score):
        token = await _login(client, user_with_high_score)
        headers = {"Authorization": f"Bearer {token}"}
        await client.post(
            f"/api/v1/challenges/{CHALLENGE_ID}/share",
            json={"code": GOOD_CODE, "language": LANGUAGE},
            headers=headers,
        )
        resp = await client.get(
            f"/api/v1/challenges/{CHALLENGE_ID}/top-solutions", headers=headers
        )
        sol = resp.json()[0]
        assert "id" in sol
        assert "author" in sol
        assert "username" in sol["author"]
        assert "xp" in sol["author"]
        assert "score" in sol
        assert "language" in sol
        assert "code" in sol
        assert "shared_at" in sol

    async def test_unshared_solution_not_in_list(self, client, user_with_high_score):
        token = await _login(client, user_with_high_score)
        headers = {"Authorization": f"Bearer {token}"}
        # Share then unshare
        await client.post(
            f"/api/v1/challenges/{CHALLENGE_ID}/share",
            json={"code": GOOD_CODE, "language": LANGUAGE},
            headers=headers,
        )
        await client.delete(f"/api/v1/challenges/{CHALLENGE_ID}/share", headers=headers)
        resp = await client.get(
            f"/api/v1/challenges/{CHALLENGE_ID}/top-solutions", headers=headers
        )
        solutions = resp.json()
        mine = next(
            (s for s in solutions if s["author"]["username"] == user_with_high_score["username"]),
            None,
        )
        assert mine is None
