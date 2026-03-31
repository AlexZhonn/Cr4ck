"""
Auth endpoints:
  POST /auth/register             — create account
  POST /auth/login                — get access + refresh tokens
  POST /auth/refresh              — exchange refresh token for new access token
  POST /auth/logout               — revoke refresh token
  GET  /auth/verify               — verify email via token
  POST /auth/resend-verification  — resend verification email
  GET  /auth/me                   — get current user profile
"""

import logging
import secrets

from fastapi import APIRouter, Depends, HTTPException, Request, status
from pydantic import BaseModel as _BaseModel
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
logger = logging.getLogger(__name__)

from auth.dependencies import get_current_user
from auth.password import generate_salt, hash_password, verify_password, needs_rehash
from auth.tokens import create_access_token, create_refresh_token, decode_token
from core.database import get_db
from email_service import send_verification_email, send_password_reset_email
from models.user import (
    ForgotPasswordRequest,
    LoginRequest,
    RefreshRequest,
    RegisterRequest,
    ResetPasswordRequest,
    TokenResponse,
    UserInDB,
    UserPublic,
)

router = APIRouter(tags=["auth"])


@router.post("/register", response_model=UserPublic, status_code=status.HTTP_201_CREATED)
@limiter.limit("10/hour")
def register(request: Request, body: RegisterRequest, db=Depends(get_db)):
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
        user_id = str(row["id"])
        username = row["username"]

        verification_token = secrets.token_urlsafe(32)
        cur.execute(
            """
            UPDATE users
            SET verification_token = %s,
                verification_token_expires_at = NOW() + INTERVAL '24 hours'
            WHERE id = %s
            """,
            (verification_token, user_id),
        )

    send_verification_email(body.email, username, verification_token)

    return UserPublic(**row)


@router.post("/login", response_model=TokenResponse)
@limiter.limit("20/hour")
def login(request: Request, body: LoginRequest, db=Depends(get_db)):
    with db.cursor() as cur:
        cur.execute(
            "SELECT id, password_hash, salt, role, is_active, is_verified FROM users WHERE email = %s OR username = %s",
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
        logger.info("auth.login.failure", extra={"reason": "invalid_credentials"})
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    if not user["is_active"]:
        logger.info("auth.login.failure", extra={"reason": "account_disabled"})
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is disabled",
        )

    if not user["is_verified"]:
        logger.info("auth.login.failure", extra={"reason": "email_not_verified"})
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Email not verified. Check your inbox or request a new verification link.",
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

    logger.info("auth.login.success", extra={"user_id": user_id, "role": role})
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


@router.get("/verify")
def verify_email(token: str, db=Depends(get_db)):
    """Verify a user's email address via the token sent on registration."""
    with db.cursor() as cur:
        cur.execute(
            """
            SELECT id, verification_token FROM users
            WHERE verification_token_expires_at > NOW()
              AND is_verified = FALSE
              AND verification_token = %s
            """,
            (token,),
        )
        row = cur.fetchone()

    # Use compare_digest as a defence-in-depth measure against timing-based
    # brute-force attacks.  The stored token is compared against the received
    # token using a constant-time algorithm; a dummy value is used when no row
    # was found so the comparison always executes.
    _DUMMY = "x" * 43  # same length as secrets.token_urlsafe(32)
    stored = row["verification_token"] if row else _DUMMY
    if not secrets.compare_digest(token, stored) or not row:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired verification token",
        )

    with db.cursor() as cur:
        cur.execute(
            """
            UPDATE users
            SET is_verified = TRUE,
                verification_token = NULL,
                verification_token_expires_at = NULL,
                updated_at = NOW()
            WHERE id = %s
            """,
            (str(row["id"]),),
        )

    return {"message": "Email verified successfully"}


@router.post("/resend-verification", status_code=status.HTTP_204_NO_CONTENT)
@limiter.limit("5/hour")
def resend_verification(request: Request, body: LoginRequest, db=Depends(get_db)):
    """
    Resend a verification email. Accepts email (or username) + password so we
    can confirm the requester owns the account without issuing tokens.
    Always returns 204 to avoid leaking whether an email exists.
    """
    with db.cursor() as cur:
        cur.execute(
            "SELECT id, email, username, password_hash, salt, is_verified FROM users WHERE email = %s OR username = %s",
            (body.email, body.email),
        )
        user = cur.fetchone()

    _DUMMY_SALT = "0" * 64
    _DUMMY_HASH = "$argon2id$v=19$m=65536,t=3,p=2$deadbeefdeadbeef$deadbeefdeadbeefdeadbeefdeadbeefdeadbeef"
    stored_hash = user["password_hash"] if user else _DUMMY_HASH
    stored_salt = user["salt"] if user else _DUMMY_SALT
    password_ok = verify_password(body.password, stored_salt, stored_hash)

    # Silently do nothing if user not found, wrong password, or already verified
    if not user or not password_ok or user["is_verified"]:
        return

    user_id = str(user["id"])
    verification_token = secrets.token_urlsafe(32)

    with db.cursor() as cur:
        cur.execute(
            """
            UPDATE users
            SET verification_token = %s,
                verification_token_expires_at = NOW() + INTERVAL '24 hours',
                updated_at = NOW()
            WHERE id = %s
            """,
            (verification_token, user_id),
        )

    send_verification_email(user["email"], user["username"], verification_token)


@router.post("/forgot-password", status_code=status.HTTP_204_NO_CONTENT)
@limiter.limit("5/hour")
def forgot_password(request: Request, body: ForgotPasswordRequest, db=Depends(get_db)):
    """
    Send a password reset link. Always returns 204 regardless of whether the
    email exists — prevents user enumeration.
    """
    with db.cursor() as cur:
        cur.execute(
            "SELECT id, email, username FROM users WHERE email = %s AND is_active = TRUE",
            (body.email,),
        )
        user = cur.fetchone()

    if not user:
        return

    reset_token = secrets.token_urlsafe(32)
    with db.cursor() as cur:
        cur.execute(
            """
            UPDATE users
            SET reset_token = %s,
                reset_token_expires_at = NOW() + INTERVAL '1 hour',
                updated_at = NOW()
            WHERE id = %s
            """,
            (reset_token, str(user["id"])),
        )

    send_password_reset_email(user["email"], user["username"], reset_token)


@router.post("/reset-password", status_code=status.HTTP_204_NO_CONTENT)
def reset_password(body: ResetPasswordRequest, db=Depends(get_db)):
    """Verify reset token and update the user's password."""
    with db.cursor() as cur:
        cur.execute(
            """
            SELECT id, salt, reset_token FROM users
            WHERE reset_token_expires_at > NOW()
              AND is_active = TRUE
              AND reset_token = %s
            """,
            (body.token,),
        )
        user = cur.fetchone()

    # Constant-time comparison prevents timing-based token brute-force.
    _DUMMY = "x" * 43
    stored = user["reset_token"] if user else _DUMMY
    if not secrets.compare_digest(body.token, stored) or not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired reset token",
        )

    new_hash = hash_password(body.password, user["salt"])
    with db.cursor() as cur:
        cur.execute(
            """
            UPDATE users
            SET password_hash = %s,
                reset_token = NULL,
                reset_token_expires_at = NULL,
                updated_at = NOW()
            WHERE id = %s
            """,
            (new_hash, str(user["id"])),
        )


# ── Test-only endpoint (disabled in production) ────────────────────────────────
import os as _os

if _os.getenv("TEST_MODE", "").lower() == "true":
    from fastapi import Header

    @router.post("/test/verify-bypass", status_code=status.HTTP_204_NO_CONTENT)
    def test_verify_bypass(
        email: str,
        x_test_secret: str = Header(alias="X-Test-Secret"),
        db=Depends(get_db),
    ):
        """
        TESTING ONLY — marks a user as verified without email confirmation.
        Only active when TEST_MODE=true. Gated by X-Test-Secret header.
        """
        expected = _os.getenv("TEST_SECRET", "test-secret")
        if not secrets.compare_digest(x_test_secret, expected):
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")
        with db.cursor() as cur:
            cur.execute(
                "UPDATE users SET is_verified = TRUE WHERE email = %s",
                (email,),
            )


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


class ChangePasswordRequest(_BaseModel):
    current_password: str
    new_password: str


@router.put("/password", status_code=status.HTTP_204_NO_CONTENT)
def change_password(
    body: ChangePasswordRequest,
    current_user: UserInDB = Depends(get_current_user),
    db=Depends(get_db),
):
    if len(body.new_password) < 8:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="New password must be at least 8 characters",
        )

    with db.cursor() as cur:
        cur.execute(
            "SELECT password_hash, password_salt FROM users WHERE id = %s",
            (str(current_user.id),),
        )
        row = cur.fetchone()

    if not verify_password(body.current_password, row["password_hash"], row["password_salt"]):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Current password is incorrect")

    new_salt = generate_salt()
    new_hash = hash_password(body.new_password, new_salt)
    with db.cursor() as cur:
        cur.execute(
            "UPDATE users SET password_hash = %s, password_salt = %s, updated_at = NOW() WHERE id = %s",
            (new_hash, new_salt, str(current_user.id)),
        )
