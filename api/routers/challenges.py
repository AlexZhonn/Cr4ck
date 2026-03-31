"""
GET /api/challenges          — list all active challenges (paginated)
GET /api/challenges/:id      — single challenge detail
"""

import math
from datetime import datetime
from fastapi import APIRouter, HTTPException, Query, status, Depends
from pydantic import BaseModel

from auth.dependencies import get_current_user
from core.database import get_db
from core.redis import cache_get, cache_set, CHALLENGES_KEY, CHALLENGES_TTL

router = APIRouter(tags=["challenges"])


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


class ChallengesPage(BaseModel):
    items: list[ChallengeOut]
    total: int
    page: int
    limit: int
    pages: int


@router.get("/challenges", response_model=ChallengesPage)
def list_challenges(
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=200),
    db=Depends(get_db),
):
    # Full list is cached; slice in Python to avoid per-page cache complexity
    cached = cache_get(CHALLENGES_KEY)
    if cached is not None:
        all_challenges = [ChallengeOut(**c) for c in cached]
    else:
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
        all_challenges = [_row_to_challenge(r) for r in rows]
        cache_set(CHALLENGES_KEY, [c.model_dump() for c in all_challenges], CHALLENGES_TTL)

    total = len(all_challenges)
    start = (page - 1) * limit
    items = all_challenges[start: start + limit]
    return ChallengesPage(items=items, total=total, page=page, limit=limit, pages=math.ceil(total / limit))


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


class SubmissionOut(BaseModel):
    id: int
    score: int
    language: str
    code: str
    submitted_at: datetime


@router.get("/challenges/{challenge_id}/my-submissions", response_model=list[SubmissionOut])
def my_submissions(
    challenge_id: str,
    current_user=Depends(get_current_user),
    db=Depends(get_db),
):
    with db.cursor() as cur:
        cur.execute(
            """SELECT id, score, language, code, submitted_at
               FROM submissions
               WHERE user_id = %s AND challenge_id = %s
               ORDER BY submitted_at DESC
               LIMIT 50""",
            (str(current_user.id), challenge_id),
        )
        rows = cur.fetchall()
    return [SubmissionOut(**r) for r in rows]
