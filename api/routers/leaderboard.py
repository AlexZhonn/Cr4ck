"""
GET /api/leaderboard

Returns the top users ranked by XP. Public endpoint — no auth required.
"""

from fastapi import APIRouter, Depends
from pydantic import BaseModel

from core.database import get_db
from core.redis import cache_get, cache_set, LEADERBOARD_KEY, LEADERBOARD_TTL

router = APIRouter(tags=["leaderboard"])

LEADERBOARD_LIMIT = 50


class LeaderboardEntry(BaseModel):
    rank: int
    username: str
    xp: int
    level: int
    challenges_completed: int
    streak_days: int


@router.get("/leaderboard", response_model=list[LeaderboardEntry])
def get_leaderboard(db=Depends(get_db)):
    cached = cache_get(LEADERBOARD_KEY)
    if cached is not None:
        return [LeaderboardEntry(**e) for e in cached]

    with db.cursor() as cur:
        cur.execute(
            """
            SELECT username, xp, challenges_completed, streak_days
            FROM users
            WHERE is_active = TRUE
            ORDER BY xp DESC, challenges_completed DESC
            LIMIT %s
            """,
            (LEADERBOARD_LIMIT,),
        )
        rows = cur.fetchall()

    entries = [
        LeaderboardEntry(
            rank=i + 1,
            username=row["username"],
            xp=row["xp"],
            level=row["xp"] // 100 + 1,
            challenges_completed=row["challenges_completed"],
            streak_days=row["streak_days"],
        )
        for i, row in enumerate(rows)
    ]
    cache_set(LEADERBOARD_KEY, [e.model_dump() for e in entries], LEADERBOARD_TTL)
    return entries
