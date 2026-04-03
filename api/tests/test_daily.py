"""
Tests for the daily challenge endpoints.

GET  /api/v1/daily            — public; returns 404 when no daily is set
POST /api/admin/generate-daily — protected by X-Admin-Secret; idempotent

DB tests require a running PostgreSQL instance; the db_required mark skips them
when DATABASE_URL is not configured.
"""

import os
import uuid

import pytest

from tests.conftest import db_required

pytestmark = [pytest.mark.asyncio, db_required]


class TestGetDaily:
    async def test_returns_404_when_no_daily_set(self, client, db):
        # Ensure today has no daily challenge row (clean any leftover)
        from datetime import date

        today = date.today().isoformat()
        with db.cursor() as cur:
            cur.execute("DELETE FROM daily_challenges WHERE date = %s", (today,))
        db.commit()

        resp = await client.get("/api/v1/daily")
        assert resp.status_code == 404

    async def test_returns_challenge_when_daily_set(self, client, db):
        from datetime import date

        today = date.today().isoformat()

        # Grab an existing active challenge to pin as today's daily
        with db.cursor() as cur:
            cur.execute("SELECT id FROM challenges WHERE is_active = TRUE LIMIT 1")
            row = cur.fetchone()

        if not row:
            pytest.skip("No active challenges in test DB")

        challenge_id = str(row["id"])

        # Insert daily row (or skip if already exists)
        with db.cursor() as cur:
            cur.execute(
                "INSERT INTO daily_challenges (date, challenge_id) VALUES (%s, %s) ON CONFLICT DO NOTHING",
                (today, challenge_id),
            )
        db.commit()

        try:
            resp = await client.get("/api/v1/daily")
            assert resp.status_code == 200
            body = resp.json()
            for field in ("id", "title", "topic", "difficulty", "language", "description"):
                assert field in body, f"Missing field: {field}"
        finally:
            with db.cursor() as cur:
                cur.execute("DELETE FROM daily_challenges WHERE date = %s", (today,))
            db.commit()

    async def test_public_no_auth_required(self, client):
        resp = await client.get("/api/v1/daily")
        # 200 or 404 — either is fine; the endpoint must not require auth
        assert resp.status_code in (200, 404)


class TestGenerateDaily:
    async def test_rejects_missing_secret(self, client):
        resp = await client.post("/api/admin/generate-daily", json={})
        assert resp.status_code == 401

    async def test_rejects_wrong_secret(self, client):
        resp = await client.post(
            "/api/admin/generate-daily",
            json={},
            headers={"X-Admin-Secret": "wrong-secret"},
        )
        assert resp.status_code == 401

    async def test_rejects_invalid_date_format(self, client, monkeypatch):
        monkeypatch.setenv("ADMIN_SECRET", "test-admin-secret")
        resp = await client.post(
            "/api/admin/generate-daily",
            json={"date": "not-a-date"},
            headers={"X-Admin-Secret": "test-admin-secret"},
        )
        assert resp.status_code == 400

    async def test_idempotent_when_already_exists(self, client, db, monkeypatch):
        """Calling generate-daily twice for the same date returns created=False the second time."""
        from datetime import date

        monkeypatch.setenv("ADMIN_SECRET", "test-admin-secret")

        today = date.today().isoformat()

        # Make sure we have a challenge to use
        with db.cursor() as cur:
            cur.execute("SELECT id FROM challenges WHERE is_active = TRUE LIMIT 1")
            row = cur.fetchone()

        if not row:
            pytest.skip("No active challenges in test DB")

        challenge_id = str(row["id"])

        # Pre-insert daily row
        with db.cursor() as cur:
            cur.execute(
                "INSERT INTO daily_challenges (date, challenge_id) VALUES (%s, %s) ON CONFLICT DO NOTHING",
                (today, challenge_id),
            )
        db.commit()

        try:
            resp = await client.post(
                "/api/admin/generate-daily",
                json={"date": today},
                headers={"X-Admin-Secret": "test-admin-secret"},
            )
            # Already exists → 201 with created=False
            assert resp.status_code == 201
            body = resp.json()
            assert body["created"] is False
            assert body["date"] == today
        finally:
            with db.cursor() as cur:
                cur.execute("DELETE FROM daily_challenges WHERE date = %s", (today,))
            db.commit()
