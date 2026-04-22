"""
GET /api/v1/paths                   — list all learning paths (public)
GET /api/v1/paths/:slug             — path detail with ordered challenges (public)
GET /api/v1/paths/:slug/progress    — user progress for a path (auth required)
"""

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from auth.dependencies import get_current_user
from core.database import get_db
from routers.challenges import ChallengeOut, _row_to_challenge

router = APIRouter(prefix="/paths", tags=["paths"])


# ── Response models ───────────────────────────────────────────────────────────


class PathSummary(BaseModel):
    id: int
    slug: str
    title: str
    description: str
    topic: str | None
    icon: str | None
    order_index: int
    challenge_count: int
    difficulty_tags: list[str]  # e.g. ["Easy", "Medium"]


class PathDetail(BaseModel):
    id: int
    slug: str
    title: str
    description: str
    topic: str | None
    icon: str | None
    order_index: int
    challenge_count: int
    difficulty_tags: list[str]
    challenges: list[ChallengeOut]


class ChallengeProgress(BaseModel):
    challenge_id: str
    step_order: int
    attempted: bool
    best_score: int


class PathProgress(BaseModel):
    path_id: int
    slug: str
    total: int
    completed: int          # challenges with at least one attempt
    challenges: list[ChallengeProgress]


# ── Helpers ───────────────────────────────────────────────────────────────────

_DIFFICULTY_ORDER = {"Easy": 0, "Medium": 1, "Hard": 2}


def _difficulty_tags(difficulties: list[str]) -> list[str]:
    """Return sorted, deduplicated difficulty labels present in a path."""
    seen: set[str] = set()
    tags: list[str] = []
    for d in sorted(set(difficulties), key=lambda x: _DIFFICULTY_ORDER.get(x, 99)):
        if d not in seen:
            seen.add(d)
            tags.append(d)
    return tags


# ── Routes ────────────────────────────────────────────────────────────────────


@router.get("", response_model=list[PathSummary])
def list_paths(db=Depends(get_db)):
    """Return all learning paths ordered by order_index."""
    with db.cursor() as cur:
        cur.execute(
            """
            SELECT
                p.id, p.slug, p.title, p.description, p.topic::text, p.icon, p.order_index,
                COUNT(pc.challenge_id)                                            AS challenge_count,
                ARRAY_AGG(DISTINCT c.difficulty::text ORDER BY c.difficulty::text) AS difficulties
            FROM paths p
            LEFT JOIN path_challenges pc ON pc.path_id = p.id
            LEFT JOIN challenges c       ON c.id = pc.challenge_id
            GROUP BY p.id
            ORDER BY p.order_index
            """
        )
        rows = cur.fetchall()

    result: list[PathSummary] = []
    for row in rows:
        difficulties: list[str] = [d for d in (row["difficulties"] or []) if d]
        result.append(
            PathSummary(
                id=row["id"],
                slug=row["slug"],
                title=row["title"],
                description=row["description"],
                topic=row["topic"],
                icon=row["icon"],
                order_index=row["order_index"],
                challenge_count=int(row["challenge_count"] or 0),
                difficulty_tags=_difficulty_tags(difficulties),
            )
        )
    return result


@router.get("/{slug}", response_model=PathDetail)
def get_path(slug: str, db=Depends(get_db)):
    """Return a single learning path with its challenges in step order."""
    with db.cursor() as cur:
        cur.execute(
            "SELECT id, slug, title, description, topic::text, icon, order_index FROM paths WHERE slug = %s",
            (slug,),
        )
        path_row = cur.fetchone()

    if not path_row:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Path not found")

    with db.cursor() as cur:
        cur.execute(
            """
            SELECT
                c.id, c.title, c.topic, c.difficulty, c.language, c.framework,
                c.description, c.starter_code, c.starter_codes, c.test_cases,
                pc.step_order
            FROM path_challenges pc
            JOIN challenges c ON c.id = pc.challenge_id
            WHERE pc.path_id = %s
            ORDER BY pc.step_order
            """,
            (path_row["id"],),
        )
        challenge_rows = cur.fetchall()

    challenges = [_row_to_challenge(r) for r in challenge_rows]
    difficulties = [c.difficulty for c in challenges]

    return PathDetail(
        id=path_row["id"],
        slug=path_row["slug"],
        title=path_row["title"],
        description=path_row["description"],
        topic=path_row["topic"],
        icon=path_row["icon"],
        order_index=path_row["order_index"],
        challenge_count=len(challenges),
        difficulty_tags=_difficulty_tags(difficulties),
        challenges=challenges,
    )


@router.get("/{slug}/progress", response_model=PathProgress)
def path_progress(
    slug: str,
    current_user=Depends(get_current_user),
    db=Depends(get_db),
):
    """Return the authenticated user's completion status for every challenge in a path."""
    with db.cursor() as cur:
        cur.execute("SELECT id, slug FROM paths WHERE slug = %s", (slug,))
        path_row = cur.fetchone()

    if not path_row:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Path not found")

    path_id: int = path_row["id"]

    with db.cursor() as cur:
        cur.execute(
            """
            SELECT pc.challenge_id, pc.step_order
            FROM path_challenges pc
            WHERE pc.path_id = %s
            ORDER BY pc.step_order
            """,
            (path_id,),
        )
        path_steps = cur.fetchall()

    if not path_steps:
        return PathProgress(
            path_id=path_id, slug=slug, total=0, completed=0, challenges=[]
        )

    challenge_ids = [r["challenge_id"] for r in path_steps]

    # Fetch user's attempt data for these challenges in one query
    with db.cursor() as cur:
        cur.execute(
            """
            SELECT challenge_id, best_score
            FROM user_challenges
            WHERE user_id = %s AND challenge_id = ANY(%s)
            """,
            (str(current_user.id), challenge_ids),
        )
        attempt_rows = cur.fetchall()

    attempts_by_id: dict[str, int] = {r["challenge_id"]: r["best_score"] for r in attempt_rows}

    progress_list: list[ChallengeProgress] = []
    completed = 0
    for step in path_steps:
        cid = step["challenge_id"]
        best = attempts_by_id.get(cid, 0)
        attempted = cid in attempts_by_id
        if attempted:
            completed += 1
        progress_list.append(
            ChallengeProgress(
                challenge_id=cid,
                step_order=step["step_order"],
                attempted=attempted,
                best_score=best,
            )
        )

    return PathProgress(
        path_id=path_id,
        slug=slug,
        total=len(path_steps),
        completed=completed,
        challenges=progress_list,
    )
