"""
FastAPI dependency: get the currently authenticated user from the Bearer token.

Usage in a route:
    @router.get("/me")
    def get_me(current_user: UserInDB = Depends(get_current_user)):
        ...

    # Require admin role:
    @router.delete("/users/{user_id}")
    def delete_user(current_user: UserInDB = Depends(require_admin)):
        ...
"""

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import psycopg2
from psycopg2.extras import RealDictCursor

from auth.tokens import decode_token
from core.database import get_db
from models.user import UserInDB, UserRole

_bearer_scheme = HTTPBearer()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(_bearer_scheme),
    db=Depends(get_db),
) -> UserInDB:
    """Decode the access token and load the user from the DB."""
    payload = decode_token(credentials.credentials, expected_type="access")
    user_id: str = payload["sub"]

    with db.cursor() as cur:
        cur.execute(
            """
            SELECT id, username, email, password_hash, salt, role,
                   is_active, is_verified, created_at, updated_at,
                   last_login_at, xp, streak_days, challenges_completed
            FROM users
            WHERE id = %s
            """,
            (user_id,),
        )
        row = cur.fetchone()

    if row is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")

    if not row["is_active"]:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account is disabled")

    return UserInDB(**row)


def require_admin(current_user: UserInDB = Depends(get_current_user)) -> UserInDB:
    if current_user.role != UserRole.admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin access required")
    return current_user
