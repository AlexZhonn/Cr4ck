"""
GET /api/challenges          — list all active challenges
GET /api/challenges/:id      — single challenge detail
"""

from fastapi import APIRouter, HTTPException, status, Depends
from pydantic import BaseModel

from core.database import get_db
from core.redis import cache_get, cache_set, CHALLENGES_KEY, CHALLENGES_TTL

router = APIRouter(prefix="/api", tags=["challenges"])


class TestCase(BaseModel):
    input: str
    expected_output: str
    description: str


class ChallengeOut(BaseModel):
    id: str
    title: str
    topic: str
    difficulty: str
    language: str
    framework: str
    description: str
    starter_code: str
    test_cases: list[TestCase] = []


def _row_to_challenge(row: dict) -> ChallengeOut:
    raw_test_cases = row.get("test_cases") or []
    test_cases = [TestCase(**tc) for tc in raw_test_cases]
    return ChallengeOut(
        id=row["id"],
        title=row["title"],
        topic=row["topic"],
        difficulty=row["difficulty"],
        language=row["language"],
        framework=row["framework"],
        description=row["description"],
        starter_code=row["starter_code"],
        test_cases=test_cases,
    )


@router.get("/challenges", response_model=list[ChallengeOut])
def list_challenges(db=Depends(get_db)):
    cached = cache_get(CHALLENGES_KEY)
    if cached is not None:
        return [ChallengeOut(**c) for c in cached]

    with db.cursor() as cur:
        cur.execute(
            """
            SELECT id, title, topic, difficulty, language, framework, description, starter_code, test_cases
            FROM challenges
            WHERE is_active = TRUE
            ORDER BY topic, difficulty, id
            """
        )
        rows = cur.fetchall()
    challenges = [_row_to_challenge(r) for r in rows]
    cache_set(CHALLENGES_KEY, [c.model_dump() for c in challenges], CHALLENGES_TTL)
    return challenges


@router.get("/challenges/{challenge_id}", response_model=ChallengeOut)
def get_challenge(challenge_id: str, db=Depends(get_db)):
    with db.cursor() as cur:
        cur.execute(
            """
            SELECT id, title, topic, difficulty, language, framework, description, starter_code, test_cases
            FROM challenges
            WHERE id = %s AND is_active = TRUE
            """,
            (challenge_id,),
        )
        row = cur.fetchone()
    if not row:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Challenge not found")
    return _row_to_challenge(row)
