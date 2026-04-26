"""
GET /api/v1/users/:username/profile  — public profile (no email, no private data)
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from datetime import datetime
from core.database import get_db
from fastapi import Depends
from models.user import UserBadgeOut

router = APIRouter(prefix="/users", tags=["users"])


class TopicStat(BaseModel):
    topic: str
    count: int
    best_score: int


class PublicProfileOut(BaseModel):
    username: str
    xp: int
    level: int
    streak_days: int
    challenges_completed: int
    member_since: datetime
    badges: list[UserBadgeOut]
    topic_breakdown: list[TopicStat]


@router.get("/{username}/profile", response_model=PublicProfileOut)
def get_public_profile(username: str, db=Depends(get_db)):
    """Public profile — safe fields only, no email or credentials."""
    with db.cursor() as cur:
        # Fetch core user fields
        cur.execute(
            """
            SELECT id, username, xp, streak_days, challenges_completed, created_at
              FROM users
             WHERE username = %s
               AND is_active = TRUE
            """,
            (username,),
        )
        row = cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="User not found")

        user_id = str(row["id"])
        level = row["xp"] // 100 + 1

        # Fetch earned badges
        cur.execute(
            """
            SELECT b.id, b.label, b.description, b.icon, ub.earned_at
              FROM user_badges ub
              JOIN badges b ON b.id = ub.badge_id
             WHERE ub.user_id = %s
             ORDER BY ub.earned_at
            """,
            (user_id,),
        )
        badges = [UserBadgeOut(**r) for r in cur.fetchall()]

        # Topic breakdown — count + best score per topic
        cur.execute(
            """
            SELECT c.topic, COUNT(*) AS count, MAX(uc.best_score) AS best_score
              FROM user_challenges uc
              JOIN challenges c ON c.id = uc.challenge_id
             WHERE uc.user_id = %s
             GROUP BY c.topic
             ORDER BY count DESC
            """,
            (user_id,),
        )
        topic_breakdown = [TopicStat(**r) for r in cur.fetchall()]

    return PublicProfileOut(
        username=row["username"],
        xp=row["xp"],
        level=level,
        streak_days=row["streak_days"],
        challenges_completed=row["challenges_completed"],
        member_since=row["created_at"],
        badges=badges,
        topic_breakdown=topic_breakdown,
    )
