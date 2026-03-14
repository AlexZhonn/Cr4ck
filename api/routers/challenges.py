"""
GET /api/challenges          — list all active challenges
GET /api/challenges/:id      — single challenge detail
"""

from fastapi import APIRouter, HTTPException, status, Depends
from pydantic import BaseModel

from core.database import get_db

router = APIRouter(prefix="/api", tags=["challenges"])


class ChallengeOut(BaseModel):
    id: str
    title: str
    topic: str
    difficulty: str
    language: str
    framework: str
    description: str
    starter_code: str


def _row_to_challenge(row: dict) -> ChallengeOut:
    return ChallengeOut(
        id=row["id"],
        title=row["title"],
        topic=row["topic"],
        difficulty=row["difficulty"],
        language=row["language"],
        framework=row["framework"],
        description=row["description"],
        starter_code=row["starter_code"],
    )


@router.get("/challenges", response_model=list[ChallengeOut])
def list_challenges(db=Depends(get_db)):
    with db.cursor() as cur:
        cur.execute(
            """
            SELECT id, title, topic, difficulty, language, framework, description, starter_code
            FROM challenges
            WHERE is_active = TRUE
            ORDER BY topic, difficulty, id
            """
        )
        rows = cur.fetchall()
    return [_row_to_challenge(r) for r in rows]


@router.get("/challenges/{challenge_id}", response_model=ChallengeOut)
def get_challenge(challenge_id: str, db=Depends(get_db)):
    with db.cursor() as cur:
        cur.execute(
            """
            SELECT id, title, topic, difficulty, language, framework, description, starter_code
            FROM challenges
            WHERE id = %s AND is_active = TRUE
            """,
            (challenge_id,),
        )
        row = cur.fetchone()
    if not row:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Challenge not found")
    return _row_to_challenge(row)
