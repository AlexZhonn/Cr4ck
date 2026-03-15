"""
Auth endpoints:
  POST /auth/register  — create account
  POST /auth/login     — get access + refresh tokens
  POST /auth/refresh   — exchange refresh token for new access token
  POST /auth/logout    — revoke refresh token
  GET  /auth/me        — get current user profile
"""

from fastapi import APIRouter, Depends, HTTPException, status

from auth.dependencies import get_current_user
from auth.password import generate_salt, hash_password, verify_password, needs_rehash
from auth.tokens import create_access_token, create_refresh_token, decode_token
from core.database import get_db
from models.user import (
    LoginRequest,
    RefreshRequest,
    RegisterRequest,
    TokenResponse,
    UserInDB,
    UserPublic,
)

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=UserPublic, status_code=status.HTTP_201_CREATED)
def register(body: RegisterRequest, db=Depends(get_db)):
    with db.cursor() as cur:
        cur.execute(
            "SELECT id FROM users WHERE email = %s OR username = %s",
            (body.email, body.username),
        )
        if cur.fetchone():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email or username already taken",
            )

        salt = generate_salt()
        password_hash = hash_password(body.password, salt)

        cur.execute(
            """
            INSERT INTO users
                (username, email, password_hash, salt, role, is_active, is_verified,
                 created_at, updated_at, xp, streak_days, challenges_completed)
            VALUES
                (%s, %s, %s, %s, 'user', TRUE, FALSE,
                 NOW(), NOW(), 0, 0, 0)
            RETURNING id, username, email, role, is_active, is_verified, created_at,
                      xp, streak_days, challenges_completed
            """,
            (body.username, body.email, password_hash, salt),
        )
        row = cur.fetchone()

    return UserPublic(**row)


@router.post("/login", response_model=TokenResponse)
def login(body: LoginRequest, db=Depends(get_db)):
    with db.cursor() as cur:
        cur.execute(
            "SELECT id, password_hash, salt, role, is_active FROM users WHERE email = %s OR username = %s",
            (body.email, body.email),
        )
        user = cur.fetchone()

    # Always run verify_password even if user doesn't exist to prevent timing-based
    # user enumeration (see auth/password.py for the dummy values explanation).
    _DUMMY_SALT = "0" * 64
    _DUMMY_HASH = "$argon2id$v=19$m=65536,t=3,p=2$deadbeefdeadbeef$deadbeefdeadbeefdeadbeefdeadbeefdeadbeef"

    stored_hash = user["password_hash"] if user else _DUMMY_HASH
    stored_salt = user["salt"] if user else _DUMMY_SALT

    password_ok = verify_password(body.password, stored_salt, stored_hash)

    if not user or not password_ok:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    if not user["is_active"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is disabled",
        )

    user_id = str(user["id"])
    role = user["role"]

    # Transparent rehash if Argon2 params are outdated
    if needs_rehash(user["password_hash"]):
        new_hash = hash_password(body.password, user["salt"])
        with db.cursor() as cur:
            cur.execute(
                "UPDATE users SET password_hash = %s, updated_at = NOW() WHERE id = %s",
                (new_hash, user_id),
            )

    with db.cursor() as cur:
        cur.execute("UPDATE users SET last_login_at = NOW() WHERE id = %s", (user_id,))

    access_token = create_access_token(user_id, role)
    refresh_token, jti = create_refresh_token(user_id, role)

    with db.cursor() as cur:
        cur.execute(
            """
            INSERT INTO refresh_tokens (jti, user_id, expires_at)
            VALUES (%s, %s, NOW() + INTERVAL '30 days')
            """,
            (jti, user_id),
        )

    return TokenResponse(access_token=access_token, refresh_token=refresh_token)


@router.post("/refresh", response_model=TokenResponse)
def refresh(body: RefreshRequest, db=Depends(get_db)):
    payload = decode_token(body.refresh_token, expected_type="refresh")
    jti = payload["jti"]
    user_id = payload["sub"]
    role = payload["role"]

    with db.cursor() as cur:
        cur.execute(
            """
            SELECT id FROM refresh_tokens
            WHERE jti = %s AND revoked = FALSE AND expires_at > NOW()
            """,
            (jti,),
        )
        if not cur.fetchone():
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Refresh token is invalid or expired",
            )

    # Token rotation: revoke old, issue new (prevents replay attacks)
    with db.cursor() as cur:
        cur.execute("UPDATE refresh_tokens SET revoked = TRUE WHERE jti = %s", (jti,))

    new_access = create_access_token(user_id, role)
    new_refresh, new_jti = create_refresh_token(user_id, role)

    with db.cursor() as cur:
        cur.execute(
            """
            INSERT INTO refresh_tokens (jti, user_id, expires_at)
            VALUES (%s, %s, NOW() + INTERVAL '30 days')
            """,
            (new_jti, user_id),
        )

    return TokenResponse(access_token=new_access, refresh_token=new_refresh)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(body: RefreshRequest, db=Depends(get_db)):
    """Revoke the refresh token. Client discards the access token locally."""
    try:
        payload = decode_token(body.refresh_token, expected_type="refresh")
        with db.cursor() as cur:
            cur.execute(
                "UPDATE refresh_tokens SET revoked = TRUE WHERE jti = %s",
                (payload["jti"],),
            )
    except Exception:
        pass  # Idempotent — silently succeed even if token is already gone


@router.get("/me", response_model=UserPublic)
def me(current_user: UserInDB = Depends(get_current_user)):
    return UserPublic(
        id=current_user.id,
        username=current_user.username,
        email=current_user.email,
        role=current_user.role,
        is_active=current_user.is_active,
        is_verified=current_user.is_verified,
        created_at=current_user.created_at,
        xp=current_user.xp,
        streak_days=current_user.streak_days,
        challenges_completed=current_user.challenges_completed,
    )
