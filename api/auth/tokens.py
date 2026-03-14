"""
JWT token creation and verification.

Two-token strategy:
  - Access token:  short-lived (15 min), used on every API request via Authorization header.
  - Refresh token: long-lived (30 days), stored securely by client, used only to mint
                   a new access token. Stored in the DB so it can be revoked.

Payload claims:
  sub  — user UUID (string)
  role — user role (for fast authz without a DB hit on every request)
  type — "access" | "refresh"  (prevents refresh tokens being used as access tokens)
  jti  — unique token ID (UUID), enables per-token revocation for refresh tokens
  exp  — expiry (set by python-jose automatically via timedelta)
  iat  — issued at
"""

import os
import uuid
from datetime import datetime, timedelta, timezone
from typing import Literal

from jose import JWTError, jwt
from fastapi import HTTPException, status

SECRET_KEY: str = os.getenv("SECRET_KEY", "")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 15
REFRESH_TOKEN_EXPIRE_DAYS = 30

_CREDENTIALS_EXCEPTION = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="Could not validate credentials",
    headers={"WWW-Authenticate": "Bearer"},
)


def _build_payload(
    user_id: str,
    role: str,
    token_type: Literal["access", "refresh"],
    expires_delta: timedelta,
) -> dict:
    now = datetime.now(timezone.utc)
    return {
        "sub": user_id,
        "role": role,
        "type": token_type,
        "jti": str(uuid.uuid4()),
        "iat": now,
        "exp": now + expires_delta,
    }


def create_access_token(user_id: str, role: str) -> str:
    payload = _build_payload(
        user_id, role, "access", timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def create_refresh_token(user_id: str, role: str) -> tuple[str, str]:
    """Returns (encoded_token, jti) — store the jti in the DB for revocation."""
    payload = _build_payload(
        user_id, role, "refresh", timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    )
    token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
    return token, payload["jti"]


def decode_token(token: str, expected_type: Literal["access", "refresh"]) -> dict:
    """
    Decode and validate a JWT. Raises HTTP 401 on any failure.

    Checks:
      - Signature validity
      - Expiry
      - token type claim matches expected_type
    """
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError:
        raise _CREDENTIALS_EXCEPTION

    if payload.get("type") != expected_type:
        raise _CREDENTIALS_EXCEPTION

    if not payload.get("sub"):
        raise _CREDENTIALS_EXCEPTION

    return payload
