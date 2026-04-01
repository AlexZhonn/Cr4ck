"""
Pytest fixtures shared across the test suite.

Database strategy: tests use TEST_DATABASE_URL if set, otherwise DATABASE_URL.
Each test fixture that creates DB rows cleans up after itself.
The FastAPI `get_db` dependency is overridden to use a plain per-request connection
(no pool) so tests are isolated from the production connection pool.

IMPORTANT: pytest.skip() must NOT be called inside a FastAPI dependency — it raises
BaseException which propagates through the ASGI middleware and crashes it.  Instead,
DB availability is checked at the fixture / mark level.
"""

import os
import uuid

import psycopg2
import pytest
from httpx import ASGITransport, AsyncClient
from psycopg2.extras import RealDictCursor

# Prefer a dedicated test DB; fall back to DATABASE_URL if nothing else is set.
_TEST_DB_URL: str = os.getenv("TEST_DATABASE_URL", os.getenv("DATABASE_URL", ""))

# Convenience marker: apply to any test class / module that requires the DB.
db_required = pytest.mark.skipif(
    not _TEST_DB_URL,
    reason="No DATABASE_URL configured — skipping DB integration test",
)


# ── Low-level DB helper ────────────────────────────────────────────────────────

def _open_conn() -> psycopg2.extensions.connection:
    """Open a raw psycopg2 connection for test fixtures (NOT for ASGI dependencies)."""
    if not _TEST_DB_URL:
        pytest.skip("No DATABASE_URL configured — skipping DB test")
    return psycopg2.connect(
        _TEST_DB_URL,
        cursor_factory=RealDictCursor,
        options="-c client_encoding=UTF8",
    )


def _get_test_db():
    """
    FastAPI dependency override for tests.

    Raises RuntimeError (not pytest.skip) when no DB is configured so that
    BaseException doesn't escape into the ASGI middleware layer.
    Tests that need the DB should use the `db_required` marker to skip early.
    """
    if not _TEST_DB_URL:
        raise RuntimeError("TEST_DATABASE_URL not configured — cannot open test DB connection")
    conn = psycopg2.connect(
        _TEST_DB_URL,
        cursor_factory=RealDictCursor,
        options="-c client_encoding=UTF8",
    )
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


# ── App + HTTP client fixtures ─────────────────────────────────────────────────

@pytest.fixture(scope="session")
def app():
    """FastAPI app with the DB dependency pointed at the test database."""
    from core.database import get_db
    from main import app as fastapi_app

    fastapi_app.dependency_overrides[get_db] = _get_test_db
    yield fastapi_app
    fastapi_app.dependency_overrides.clear()


@pytest.fixture
async def client(app):
    """Async HTTP client wired to the FastAPI ASGI app."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as ac:
        yield ac


# ── Direct DB fixture (for setup / teardown) ──────────────────────────────────

@pytest.fixture
def db():
    """Raw psycopg2 connection for direct DB manipulation in test fixtures."""
    conn = _open_conn()
    yield conn
    conn.rollback()
    conn.close()


# ── User fixtures ──────────────────────────────────────────────────────────────

@pytest.fixture
def verified_user(db):
    """
    Insert a verified user into the DB, yield credentials, then delete the user.
    is_verified=TRUE so login tests pass the email-verification gate.
    """
    from auth.password import generate_salt, hash_password

    suffix = uuid.uuid4().hex[:8]
    username = f"testuser_{suffix}"
    email = f"test_{suffix}@example.com"
    password = "TestP@ss1234!"
    salt = generate_salt()
    pw_hash = hash_password(password, salt)

    with db.cursor() as cur:
        cur.execute(
            """
            INSERT INTO users (
                username, email, password_hash, salt,
                role, is_active, is_verified,
                created_at, updated_at,
                xp, streak_days, challenges_completed
            ) VALUES (
                %s, %s, %s, %s,
                'user', TRUE, TRUE,
                NOW(), NOW(),
                0, 0, 0
            ) RETURNING id
            """,
            (username, email, pw_hash, salt),
        )
        user_id = str(cur.fetchone()["id"])
    db.commit()

    yield {"id": user_id, "username": username, "email": email, "password": password}

    with db.cursor() as cur:
        cur.execute("DELETE FROM refresh_tokens WHERE user_id = %s", (user_id,))
        cur.execute("DELETE FROM users WHERE id = %s", (user_id,))
    db.commit()


@pytest.fixture
def unverified_user(db):
    """Insert an unverified user (is_verified=FALSE)."""
    from auth.password import generate_salt, hash_password

    suffix = uuid.uuid4().hex[:8]
    username = f"unverified_{suffix}"
    email = f"unverified_{suffix}@example.com"
    password = "TestP@ss1234!"
    salt = generate_salt()
    pw_hash = hash_password(password, salt)

    with db.cursor() as cur:
        cur.execute(
            """
            INSERT INTO users (
                username, email, password_hash, salt,
                role, is_active, is_verified,
                created_at, updated_at,
                xp, streak_days, challenges_completed
            ) VALUES (
                %s, %s, %s, %s,
                'user', TRUE, FALSE,
                NOW(), NOW(),
                0, 0, 0
            ) RETURNING id
            """,
            (username, email, pw_hash, salt),
        )
        user_id = str(cur.fetchone()["id"])
    db.commit()

    yield {"id": user_id, "username": username, "email": email, "password": password}

    with db.cursor() as cur:
        cur.execute("DELETE FROM refresh_tokens WHERE user_id = %s", (user_id,))
        cur.execute("DELETE FROM users WHERE id = %s", (user_id,))
    db.commit()
