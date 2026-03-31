"""
Integration tests for /api/v1/challenges endpoints.

Requires a running PostgreSQL database seeded with challenges
(migrations 001-004b create the challenge rows).
"""

import pytest

from tests.conftest import db_required

pytestmark = [pytest.mark.asyncio, db_required]


class TestListChallenges:
    async def test_returns_paginated_response(self, client):
        resp = await client.get("/api/v1/challenges")
        assert resp.status_code == 200
        body = resp.json()
        assert "items" in body
        assert "total" in body
        assert "page" in body
        assert "limit" in body
        assert "pages" in body

    async def test_pagination_params(self, client):
        resp = await client.get("/api/v1/challenges?page=1&limit=5")
        assert resp.status_code == 200
        body = resp.json()
        assert len(body["items"]) <= 5
        assert body["limit"] == 5
        assert body["page"] == 1

    async def test_items_have_required_fields(self, client):
        resp = await client.get("/api/v1/challenges?limit=1")
        assert resp.status_code == 200
        items = resp.json()["items"]
        if not items:
            pytest.skip("No challenges seeded in test DB")
        ch = items[0]
        for field in ("id", "title", "topic", "difficulty"):
            assert field in ch, f"Missing field: {field}"

    async def test_public_endpoint_no_auth_required(self, client):
        resp = await client.get("/api/v1/challenges")
        assert resp.status_code == 200


class TestGetChallenge:
    async def test_get_existing_challenge(self, client):
        list_resp = await client.get("/api/v1/challenges?limit=1")
        items = list_resp.json().get("items", [])
        if not items:
            pytest.skip("No challenges seeded in test DB")

        challenge_id = items[0]["id"]
        resp = await client.get(f"/api/v1/challenges/{challenge_id}")
        assert resp.status_code == 200
        body = resp.json()
        assert body["id"] == challenge_id

    async def test_get_nonexistent_challenge(self, client):
        fake_id = "00000000-0000-0000-0000-000000000000"
        resp = await client.get(f"/api/v1/challenges/{fake_id}")
        assert resp.status_code == 404

    async def test_public_endpoint_no_auth_required(self, client):
        list_resp = await client.get("/api/v1/challenges?limit=1")
        items = list_resp.json().get("items", [])
        if not items:
            pytest.skip("No challenges seeded in test DB")
        challenge_id = items[0]["id"]
        resp = await client.get(f"/api/v1/challenges/{challenge_id}")
        assert resp.status_code == 200
