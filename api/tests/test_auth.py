"""
Integration tests for /auth/* endpoints.

Requires a running PostgreSQL database (uses TEST_DATABASE_URL or DATABASE_URL).
Email sending is mocked so no external service is called.
"""

import uuid
from unittest.mock import patch

import pytest

from tests.conftest import db_required

pytestmark = pytest.mark.asyncio


# ── /auth/register ─────────────────────────────────────────────────────────────

@db_required
class TestRegister:
    async def test_register_success(self, client):
        suffix = uuid.uuid4().hex[:8]
        payload = {
            "username": f"newuser_{suffix}",
            "email": f"new_{suffix}@example.invalid",
            "password": "SecurePass1!",
        }
        with patch("routers.auth.send_verification_email"):
            resp = await client.post("/auth/register", json=payload)

        assert resp.status_code == 201
        body = resp.json()
        assert body["username"] == payload["username"]
        assert body["email"] == payload["email"]
        assert "password_hash" not in body
        assert "salt" not in body

    async def test_register_duplicate_email(self, client, verified_user):
        payload = {
            "username": f"other_{uuid.uuid4().hex[:8]}",
            "email": verified_user["email"],
            "password": "SecurePass1!",
        }
        with patch("routers.auth.send_verification_email"):
            resp = await client.post("/auth/register", json=payload)
        assert resp.status_code == 409

    async def test_register_duplicate_username(self, client, verified_user):
        payload = {
            "username": verified_user["username"],
            "email": f"other_{uuid.uuid4().hex[:8]}@example.invalid",
            "password": "SecurePass1!",
        }
        with patch("routers.auth.send_verification_email"):
            resp = await client.post("/auth/register", json=payload)
        assert resp.status_code == 409

    async def test_register_short_password(self, client):
        payload = {
            "username": f"user_{uuid.uuid4().hex[:8]}",
            "email": f"e_{uuid.uuid4().hex[:8]}@example.invalid",
            "password": "short",
        }
        with patch("routers.auth.send_verification_email"):
            resp = await client.post("/auth/register", json=payload)
        assert resp.status_code == 422

    async def test_register_invalid_username(self, client):
        """Username with spaces should fail validation."""
        payload = {
            "username": "has spaces",
            "email": f"e_{uuid.uuid4().hex[:8]}@example.invalid",
            "password": "SecurePass1!",
        }
        with patch("routers.auth.send_verification_email"):
            resp = await client.post("/auth/register", json=payload)
        assert resp.status_code == 422


# ── /auth/login ────────────────────────────────────────────────────────────────

@db_required
class TestLogin:
    async def test_login_with_email(self, client, verified_user):
        resp = await client.post(
            "/auth/login",
            json={"email": verified_user["email"], "password": verified_user["password"]},
        )
        assert resp.status_code == 200
        tokens = resp.json()
        assert "access_token" in tokens
        assert "refresh_token" in tokens
        assert tokens["token_type"] == "bearer"

    async def test_login_with_username(self, client, verified_user):
        resp = await client.post(
            "/auth/login",
            json={"email": verified_user["username"], "password": verified_user["password"]},
        )
        assert resp.status_code == 200
        assert "access_token" in resp.json()

    async def test_login_wrong_password(self, client, verified_user):
        resp = await client.post(
            "/auth/login",
            json={"email": verified_user["email"], "password": "wrongpassword"},
        )
        assert resp.status_code == 401

    async def test_login_nonexistent_user(self, client):
        resp = await client.post(
            "/auth/login",
            json={"email": "nobody@example.invalid", "password": "anything1!"},
        )
        assert resp.status_code == 401

    async def test_login_unverified_user(self, client, unverified_user):
        resp = await client.post(
            "/auth/login",
            json={"email": unverified_user["email"], "password": unverified_user["password"]},
        )
        assert resp.status_code == 403


# ── /auth/refresh & /auth/logout ──────────────────────────────────────────────

@db_required
class TestRefreshAndLogout:
    async def test_refresh_returns_new_tokens(self, client, verified_user):
        login = await client.post(
            "/auth/login",
            json={"email": verified_user["email"], "password": verified_user["password"]},
        )
        original = login.json()

        refresh = await client.post(
            "/auth/refresh",
            json={"refresh_token": original["refresh_token"]},
        )
        assert refresh.status_code == 200
        new_tokens = refresh.json()
        assert new_tokens["access_token"] != original["access_token"]
        assert new_tokens["refresh_token"] != original["refresh_token"]

    async def test_refresh_invalid_token(self, client):
        resp = await client.post("/auth/refresh", json={"refresh_token": "not.a.valid.token"})
        assert resp.status_code == 401

    async def test_logout_revokes_refresh_token(self, client, verified_user):
        login = await client.post(
            "/auth/login",
            json={"email": verified_user["email"], "password": verified_user["password"]},
        )
        refresh_token = login.json()["refresh_token"]

        logout = await client.post("/auth/logout", json={"refresh_token": refresh_token})
        assert logout.status_code == 204

        # Using the revoked refresh token should now fail
        retry = await client.post("/auth/refresh", json={"refresh_token": refresh_token})
        assert retry.status_code == 401


# ── /auth/me ──────────────────────────────────────────────────────────────────

@db_required
class TestMe:
    async def test_me_returns_user(self, client, verified_user):
        login = await client.post(
            "/auth/login",
            json={"email": verified_user["email"], "password": verified_user["password"]},
        )
        token = login.json()["access_token"]

        resp = await client.get("/auth/me", headers={"Authorization": f"Bearer {token}"})
        assert resp.status_code == 200
        body = resp.json()
        assert body["username"] == verified_user["username"]
        assert body["email"] == verified_user["email"]
        assert "password_hash" not in body

    async def test_me_unauthenticated(self, client):
        resp = await client.get("/auth/me")
        assert resp.status_code == 403

    async def test_me_invalid_token(self, client):
        resp = await client.get("/auth/me", headers={"Authorization": "Bearer bad.token.here"})
        assert resp.status_code == 401
