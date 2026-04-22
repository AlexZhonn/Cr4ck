"""
Integration tests for the Learning Paths feature.

Covers:
- GET /api/v1/paths         — public list of all paths
- GET /api/v1/paths/:slug   — path detail with ordered challenges
- GET /api/v1/paths/:slug/progress — auth-gated user progress
"""

import pytest
from tests.conftest import db_required

pytestmark = [pytest.mark.asyncio, db_required]


async def _login(client, user) -> str:
    resp = await client.post(
        "/auth/v1/login",
        json={"email": user["email"], "password": user["password"]},
    )
    return resp.json()["access_token"]


# ── GET /api/v1/paths ─────────────────────────────────────────────────────────


class TestListPaths:
    async def test_returns_list_without_auth(self, client):
        """Path list must be public."""
        resp = await client.get("/api/v1/paths")
        assert resp.status_code == 200
        data = resp.json()
        assert isinstance(data, list)

    async def test_returns_eight_paths(self, client):
        """Exactly 8 curated paths are seeded."""
        resp = await client.get("/api/v1/paths")
        assert resp.status_code == 200
        assert len(resp.json()) == 8

    async def test_path_summary_shape(self, client):
        """Each path summary must include required fields."""
        resp = await client.get("/api/v1/paths")
        path = resp.json()[0]
        for field in ("id", "slug", "title", "description", "challenge_count", "difficulty_tags"):
            assert field in path, f"Missing field: {field}"

    async def test_paths_ordered_by_order_index(self, client):
        """Paths must be returned in ascending order_index order."""
        resp = await client.get("/api/v1/paths")
        indices = [p["order_index"] for p in resp.json()]
        assert indices == sorted(indices)

    async def test_challenge_counts_are_positive(self, client):
        """Every path must contain at least one challenge."""
        resp = await client.get("/api/v1/paths")
        for path in resp.json():
            assert path["challenge_count"] > 0, (
                f"Path '{path['slug']}' has no challenges"
            )

    async def test_difficulty_tags_are_valid(self, client):
        """difficulty_tags must only contain known difficulty values."""
        valid = {"Easy", "Medium", "Hard"}
        resp = await client.get("/api/v1/paths")
        for path in resp.json():
            for tag in path["difficulty_tags"]:
                assert tag in valid, f"Unexpected difficulty tag '{tag}' in {path['slug']}"


# ── GET /api/v1/paths/:slug ───────────────────────────────────────────────────


class TestGetPath:
    async def test_valid_slug_returns_path(self, client):
        """Known slug must return 200 with challenges list."""
        resp = await client.get("/api/v1/paths/oop-foundations")
        assert resp.status_code == 200
        data = resp.json()
        assert data["slug"] == "oop-foundations"
        assert "challenges" in data
        assert isinstance(data["challenges"], list)
        assert len(data["challenges"]) > 0

    async def test_challenges_in_step_order(self, client):
        """Challenges must be returned in ascending step order."""
        resp = await client.get("/api/v1/paths/oop-foundations")
        challenges = resp.json()["challenges"]
        # Step order is implicit from list position; verify IDs are the expected OOP Easy set
        ids = [c["id"] for c in challenges]
        assert "oop_001" in ids
        assert ids.index("oop_001") < ids.index("oop_009")  # oop_001 is step 1, oop_009 is step 2

    async def test_all_eight_slugs_resolve(self, client):
        """Every seeded slug must resolve to a 200 response."""
        slugs = [
            "oop-foundations",
            "oop-in-practice",
            "advanced-oop",
            "creational-patterns",
            "structural-patterns",
            "behavioral-patterns",
            "system-design-foundations",
            "distributed-systems",
        ]
        for slug in slugs:
            resp = await client.get(f"/api/v1/paths/{slug}")
            assert resp.status_code == 200, f"Slug '{slug}' returned {resp.status_code}"

    async def test_unknown_slug_returns_404(self, client):
        resp = await client.get("/api/v1/paths/does-not-exist")
        assert resp.status_code == 404

    async def test_challenge_shape_in_detail(self, client):
        """Each challenge inside a path detail must have the ChallengeOut fields."""
        resp = await client.get("/api/v1/paths/creational-patterns")
        challenge = resp.json()["challenges"][0]
        for field in ("id", "title", "topic", "difficulty", "language", "description"):
            assert field in challenge, f"Missing field: {field}"

    async def test_oop_foundations_has_only_easy_challenges(self, client):
        """OOP Foundations path must contain only Easy challenges."""
        resp = await client.get("/api/v1/paths/oop-foundations")
        difficulties = {c["difficulty"] for c in resp.json()["challenges"]}
        assert difficulties == {"Easy"}, f"Unexpected difficulties: {difficulties}"

    async def test_distributed_systems_has_only_hard_challenges(self, client):
        """Distributed Systems Deep Dive must contain only Hard challenges."""
        resp = await client.get("/api/v1/paths/distributed-systems")
        difficulties = {c["difficulty"] for c in resp.json()["challenges"]}
        assert difficulties == {"Hard"}, f"Unexpected difficulties: {difficulties}"

    async def test_creational_patterns_covers_all_five_patterns(self, client):
        """Creational patterns path must include representatives of all 5 patterns."""
        resp = await client.get("/api/v1/paths/creational-patterns")
        ids = {c["id"] for c in resp.json()["challenges"]}
        # Builder, Singleton, Prototype, Factory Method, Abstract Factory
        assert "dp_003" in ids  # Builder
        assert "dp_033" in ids  # Singleton
        assert "dp_048" in ids  # Prototype
        assert "dp_051" in ids  # Factory Method
        assert "dp_069" in ids  # Abstract Factory


# ── GET /api/v1/paths/:slug/progress ─────────────────────────────────────────


class TestPathProgress:
    async def test_unauthenticated_returns_401(self, client):
        resp = await client.get("/api/v1/paths/oop-foundations/progress")
        assert resp.status_code in (401, 403)

    async def test_authenticated_new_user_has_zero_completed(self, client, verified_user):
        token = await _login(client, verified_user)
        resp = await client.get(
            "/api/v1/paths/oop-foundations/progress",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["completed"] == 0
        assert data["total"] > 0

    async def test_progress_shape(self, client, verified_user):
        """Progress response must include all required fields."""
        token = await _login(client, verified_user)
        resp = await client.get(
            "/api/v1/paths/creational-patterns/progress",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert "path_id" in data
        assert "slug" in data
        assert "total" in data
        assert "completed" in data
        assert "challenges" in data
        for item in data["challenges"]:
            assert "challenge_id" in item
            assert "step_order" in item
            assert "attempted" in item
            assert "best_score" in item

    async def test_total_matches_path_challenge_count(self, client, verified_user):
        """Progress total must equal the number of challenges in the path."""
        token = await _login(client, verified_user)

        detail_resp = await client.get("/api/v1/paths/behavioral-patterns")
        expected_total = detail_resp.json()["challenge_count"]

        progress_resp = await client.get(
            "/api/v1/paths/behavioral-patterns/progress",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert progress_resp.json()["total"] == expected_total

    async def test_unknown_slug_progress_returns_404(self, client, verified_user):
        token = await _login(client, verified_user)
        resp = await client.get(
            "/api/v1/paths/nonexistent/progress",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert resp.status_code == 404
