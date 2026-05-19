"""
Solution Showcase endpoints.

POST /api/v1/challenges/:id/share
    Opt-in: share your solution publicly (score must be ≥ 80).
    Idempotent — calling it again updates the stored public code.

GET  /api/v1/challenges/:id/top-solutions
    Top 20 public solutions sorted by best_score desc.
    Only callable by users who have attempted the challenge (auth required).
"""

from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

from auth.dependencies import get_current_user
from core.database import get_db
from models.user import UserInDB

router = APIRouter(tags=["solutions"])

# ---------------------------------------------------------------------------
# Schemas
# ---------------------------------------------------------------------------

MIN_SHARE_SCORE = 80


class ShareRequest(BaseModel):
    code: str = Field(..., min_length=1, max_length=100_000)
    language: str = Field(..., min_length=1, max_length=20)


class ShareResponse(BaseModel):
    message: str


class SolutionAuthor(BaseModel):
    username: str
    xp: int


class TopSolutionOut(BaseModel):
    id: int
    author: SolutionAuthor
    score: int
    language: str
    code: str
    shared_at: datetime


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------


@router.post(
    "/challenges/{challenge_id}/share",
    response_model=ShareResponse,
    status_code=status.HTTP_200_OK,
)
def share_solution(
    challenge_id: str,
    body: ShareRequest,
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    """Opt-in to share the user's solution for a challenge publicly."""
    user_id = str(current_user.id)

    with db.cursor() as cur:
        cur.execute(
            "SELECT best_score FROM user_challenges WHERE user_id = %s AND challenge_id = %s",
            (user_id, challenge_id),
        )
        row = cur.fetchone()

    if row is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="You have not attempted this challenge yet.",
        )

    best_score: int = row["best_score"]
    if best_score < MIN_SHARE_SCORE:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"You need a score of at least {MIN_SHARE_SCORE} to share your solution (your best: {best_score}).",
        )

    with db.cursor() as cur:
        cur.execute(
            """UPDATE user_challenges
               SET is_public       = TRUE,
                   public_code     = %s,
                   public_language = %s
               WHERE user_id = %s AND challenge_id = %s""",
            (body.code, body.language, user_id, challenge_id),
        )

    return ShareResponse(message="Solution shared successfully.")


@router.delete(
    "/challenges/{challenge_id}/share",
    status_code=status.HTTP_200_OK,
)
def unshare_solution(
    challenge_id: str,
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    """Remove a previously shared solution."""
    user_id = str(current_user.id)

    with db.cursor() as cur:
        cur.execute(
            """UPDATE user_challenges
               SET is_public       = FALSE,
                   public_code     = NULL,
                   public_language = NULL
               WHERE user_id = %s AND challenge_id = %s""",
            (user_id, challenge_id),
        )
        if cur.rowcount == 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No attempt found for this challenge.",
            )

    return {"message": "Solution unshared."}


@router.get(
    "/challenges/{challenge_id}/top-solutions",
    response_model=list[TopSolutionOut],
)
def get_top_solutions(
    challenge_id: str,
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    """Return up to 20 top public solutions. Caller must have attempted the challenge."""
    user_id = str(current_user.id)

    with db.cursor() as cur:
        cur.execute(
            "SELECT 1 FROM user_challenges WHERE user_id = %s AND challenge_id = %s",
            (user_id, challenge_id),
        )
        if cur.fetchone() is None:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Attempt the challenge first to unlock top solutions.",
            )

        cur.execute(
            """SELECT
                uc.id,
                u.username,
                u.xp,
                uc.best_score     AS score,
                uc.public_language AS language,
                uc.public_code    AS code,
                uc.last_attempted_at AS shared_at
               FROM user_challenges uc
               JOIN users u ON u.id = uc.user_id
               WHERE uc.challenge_id = %s
                 AND uc.is_public = TRUE
                 AND uc.public_code IS NOT NULL
               ORDER BY uc.best_score DESC, uc.last_attempted_at DESC
               LIMIT 20""",
            (challenge_id,),
        )
        rows = cur.fetchall()

    return [
        TopSolutionOut(
            id=row["id"],
            author=SolutionAuthor(username=row["username"], xp=row["xp"]),
            score=row["score"],
            language=row["language"] or "python",
            code=row["code"],
            shared_at=row["shared_at"],
        )
        for row in rows
    ]
