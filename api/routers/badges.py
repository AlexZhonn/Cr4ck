"""
GET /api/v1/badges        — full badge catalog (public)
GET /api/v1/badges/me     — badges earned by the current user (auth required)
"""

from fastapi import APIRouter, Depends
from core.database import get_db
from auth.dependencies import get_current_user
from models.user import BadgeOut, UserBadgeOut, UserInDB

router = APIRouter(prefix="/badges", tags=["badges"])


@router.get("", response_model=list[BadgeOut])
def list_badges(db=Depends(get_db)):
    """Return the full badge catalog."""
    with db.cursor() as cur:
        cur.execute("SELECT id, label, description, icon FROM badges ORDER BY id")
        return [BadgeOut(**row) for row in cur.fetchall()]


@router.get("/me", response_model=list[UserBadgeOut])
def my_badges(
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    """Return all badges earned by the authenticated user."""
    with db.cursor() as cur:
        cur.execute(
            """
            SELECT b.id, b.label, b.description, b.icon, ub.earned_at
              FROM user_badges ub
              JOIN badges b ON b.id = ub.badge_id
             WHERE ub.user_id = %s
             ORDER BY ub.earned_at
            """,
            (str(current_user.id),),
        )
        return [UserBadgeOut(**row) for row in cur.fetchall()]
