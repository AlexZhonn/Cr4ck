"""
Integration tests for public user profile endpoint.

Covers:
- GET /api/v1/users/:username/profile  — public, no auth required
- 404 for non-existent users
- Response shape: username, xp, level, streak_days, challenges_completed,
  member_since, badges, topic_breakdown
"""

import pytest
from tests.conftest import db_required

pytestmark = [pytest.mark.asyncio, db_required]


class TestPublicProfile:
    async def test_returns_200_for_existing_user(self, client, verified_user):
        """Public profile endpoint returns 200 for a known user without auth."""
        resp = await client.get(f"/api/v1/users/{verified_user['username']}/profile")
        assert resp.status_code == 200

    async def test_profile_shape(self, client, verified_user):
        """Response must include all required public fields."""
        resp = await client.get(f"/api/v1/users/{verified_user['username']}/profile")
        data = resp.json()
        assert data["username"] == verified_user["username"]
        assert "xp" in data
        assert "level" in data
        assert "streak_days" in data
        assert "challenges_completed" in data
        assert "member_since" in data
        assert isinstance(data["badges"], list)
        assert isinstance(data["topic_breakdown"], list)

    async def test_no_email_in_response(self, client, verified_user):
        """Email must never appear in the public profile response."""
        resp = await client.get(f"/api/v1/users/{verified_user['username']}/profile")
        data = resp.json()
        assert "email" not in data
        assert "password_hash" not in data

    async def test_level_computed_from_xp(self, client, verified_user):
        """Level should be floor(xp / 100) + 1."""
        resp = await client.get(f"/api/v1/users/{verified_user['username']}/profile")
        data = resp.json()
        expected_level = data["xp"] // 100 + 1
        assert data["level"] == expected_level

    async def test_404_for_nonexistent_user(self, client):
        """Requesting a username that does not exist returns 404."""
        resp = await client.get("/api/v1/users/this_user_definitely_does_not_exist_xyz/profile")
        assert resp.status_code == 404

    async def test_no_auth_required(self, client, verified_user):
        """No Authorization header needed — profile is fully public."""
        resp = await client.get(
            f"/api/v1/users/{verified_user['username']}/profile",
            # Explicitly no Authorization header
        )
        assert resp.status_code == 200
