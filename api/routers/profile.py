"""
GET /api/profile/completed  — list of challenges the current user has submitted,
                              joined with challenge title/topic/difficulty.
"""

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

from auth.dependencies import get_current_user
from core.database import get_db
from models.user import UserInDB

router = APIRouter(prefix="/api/profile", tags=["profile"])


class CompletedChallenge(BaseModel):
    challenge_id: str
    title: str
    topic: str
    difficulty: str
    language: str
    best_score: int
    attempts: int
    first_completed_at: datetime
    last_attempted_at: datetime


@router.get("/completed", response_model=list[CompletedChallenge])
def get_completed(
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    with db.cursor() as cur:
        cur.execute(
            """
            SELECT
                uc.challenge_id,
                c.title,
                c.topic,
                c.difficulty,
                c.language,
                uc.best_score,
                uc.attempts,
                uc.first_completed_at,
                uc.last_attempted_at
            FROM user_challenges uc
            JOIN challenges c ON c.id = uc.challenge_id
            WHERE uc.user_id = %s
            ORDER BY uc.last_attempted_at DESC
            """,
            (str(current_user.id),),
        )
        rows = cur.fetchall()
    return [CompletedChallenge(**row) for row in rows]
