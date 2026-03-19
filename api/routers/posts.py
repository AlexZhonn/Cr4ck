"""
Community discussion endpoints.

GET    /api/challenges/:id/posts          — paginated post list (public)
POST   /api/challenges/:id/posts          — create post or reply (auth)
PUT    /api/posts/:id                     — edit own post (auth)
DELETE /api/posts/:id                     — soft-delete own post (auth)
POST   /api/posts/:id/vote                — upvote / downvote (auth)
"""

from datetime import datetime
from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field

from auth.dependencies import get_current_user
from core.database import get_db
from models.user import UserInDB

router = APIRouter(prefix="/api", tags=["posts"])


# ---------------------------------------------------------------------------
# Schemas
# ---------------------------------------------------------------------------

class PostCreate(BaseModel):
    body: str = Field(..., min_length=1, max_length=10000)
    parent_id: Optional[UUID] = None


class PostUpdate(BaseModel):
    body: str = Field(..., min_length=1, max_length=10000)


class VoteRequest(BaseModel):
    value: int = Field(..., ge=-1, le=1)  # 1 = upvote, -1 = downvote, 0 = remove


class PostAuthor(BaseModel):
    id: int
    username: str
    xp: int


class PostOut(BaseModel):
    id: UUID
    challenge_id: str
    parent_id: Optional[UUID]
    author: PostAuthor
    body: str
    is_deleted: bool
    vote_score: int
    user_vote: Optional[int]   # viewer's own vote (1/-1/None)
    reply_count: int
    created_at: datetime
    updated_at: datetime
    replies: list["PostOut"] = []


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _fetch_posts(db, challenge_id: str, parent_id, limit: int, offset: int, viewer_id: str | None) -> list[PostOut]:
    with db.cursor() as cur:
        cur.execute(
            """
            SELECT
                p.id, p.challenge_id, p.parent_id,
                p.body, p.is_deleted, p.created_at, p.updated_at,
                u.id   AS author_id,
                u.username,
                u.xp,
                COALESCE(SUM(v.value), 0)::int AS vote_score,
                (SELECT value FROM post_votes
                 WHERE post_id = p.id AND user_id = %s) AS user_vote,
                (SELECT COUNT(*) FROM posts r
                 WHERE r.parent_id = p.id AND r.is_deleted = FALSE)::int AS reply_count
            FROM posts p
            JOIN users u ON u.id = p.user_id
            LEFT JOIN post_votes v ON v.post_id = p.id
            WHERE p.challenge_id = %s
              AND p.parent_id IS NOT DISTINCT FROM %s
            GROUP BY p.id, u.id
            ORDER BY vote_score DESC, p.created_at ASC
            LIMIT %s OFFSET %s
            """,
            (viewer_id, challenge_id, parent_id, limit, offset),
        )
        rows = cur.fetchall()

    posts = []
    for row in rows:
        body = "[deleted]" if row["is_deleted"] else row["body"]
        posts.append(PostOut(
            id=row["id"],
            challenge_id=row["challenge_id"],
            parent_id=row["parent_id"],
            author=PostAuthor(id=row["author_id"], username=row["username"], xp=row["xp"]),
            body=body,
            is_deleted=row["is_deleted"],
            vote_score=row["vote_score"],
            user_vote=row["user_vote"],
            reply_count=row["reply_count"],
            created_at=row["created_at"],
            updated_at=row["updated_at"],
        ))
    return posts


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

from fastapi.security import HTTPBearer as _HTTPBearer
_optional_bearer = _HTTPBearer(auto_error=False)


def _get_optional_user(
    credentials=Depends(_optional_bearer),
    db=Depends(get_db),
) -> Optional[UserInDB]:
    return _optional_user(credentials, db)


@router.get("/challenges/{challenge_id}/posts", response_model=list[PostOut])
def list_posts(
    challenge_id: str,
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    db=Depends(get_db),
    viewer: Optional[UserInDB] = Depends(_get_optional_user),
):
    viewer_id = str(viewer.id) if viewer else None
    top_level = _fetch_posts(db, challenge_id, None, limit, offset, viewer_id)

    # Attach one level of replies (up to 50 per post)
    for post in top_level:
        if post.reply_count > 0:
            post.replies = _fetch_posts(db, challenge_id, post.id, 50, 0, viewer_id)

    return top_level


@router.post("/challenges/{challenge_id}/posts", response_model=PostOut, status_code=status.HTTP_201_CREATED)
def create_post(
    challenge_id: str,
    payload: PostCreate,
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    # Validate challenge exists
    with db.cursor() as cur:
        cur.execute("SELECT id FROM challenges WHERE id = %s AND is_active = TRUE", (challenge_id,))
        if not cur.fetchone():
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Challenge not found")

        # Validate parent belongs to same challenge
        if payload.parent_id:
            cur.execute(
                "SELECT challenge_id FROM posts WHERE id = %s AND is_deleted = FALSE",
                (str(payload.parent_id),),
            )
            parent = cur.fetchone()
            if not parent or parent["challenge_id"] != challenge_id:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid parent post")

        cur.execute(
            """
            INSERT INTO posts (challenge_id, user_id, parent_id, body)
            VALUES (%s, %s, %s, %s)
            RETURNING id, challenge_id, parent_id, body, is_deleted, created_at, updated_at
            """,
            (challenge_id, str(current_user.id), str(payload.parent_id) if payload.parent_id else None, payload.body),
        )
        row = cur.fetchone()
        db.commit()

    return PostOut(
        id=row["id"],
        challenge_id=row["challenge_id"],
        parent_id=row["parent_id"],
        author=PostAuthor(id=current_user.id, username=current_user.username, xp=current_user.xp),
        body=row["body"],
        is_deleted=row["is_deleted"],
        vote_score=0,
        user_vote=None,
        reply_count=0,
        created_at=row["created_at"],
        updated_at=row["updated_at"],
    )


@router.put("/posts/{post_id}", response_model=PostOut)
def edit_post(
    post_id: UUID,
    payload: PostUpdate,
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    with db.cursor() as cur:
        cur.execute(
            "SELECT user_id, is_deleted FROM posts WHERE id = %s",
            (str(post_id),),
        )
        row = cur.fetchone()

    if not row:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")
    if row["is_deleted"]:
        raise HTTPException(status_code=status.HTTP_410_GONE, detail="Post has been deleted")
    if str(row["user_id"]) != str(current_user.id):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Cannot edit another user's post")

    with db.cursor() as cur:
        cur.execute(
            """
            UPDATE posts SET body = %s, updated_at = NOW()
            WHERE id = %s
            RETURNING id
            """,
            (payload.body, str(post_id)),
        )
        db.commit()

    # Re-fetch full post with vote data
    posts = _fetch_posts_by_id(db, str(post_id), str(current_user.id))
    return posts


@router.delete("/posts/{post_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_post(
    post_id: UUID,
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    with db.cursor() as cur:
        cur.execute("SELECT user_id, is_deleted FROM posts WHERE id = %s", (str(post_id),))
        row = cur.fetchone()

    if not row:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")
    if row["is_deleted"]:
        return  # idempotent
    if str(row["user_id"]) != str(current_user.id):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Cannot delete another user's post")

    with db.cursor() as cur:
        cur.execute(
            "UPDATE posts SET is_deleted = TRUE, updated_at = NOW() WHERE id = %s",
            (str(post_id),),
        )
        db.commit()


@router.post("/posts/{post_id}/vote", response_model=PostOut)
def vote_post(
    post_id: UUID,
    payload: VoteRequest,
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    with db.cursor() as cur:
        cur.execute("SELECT id FROM posts WHERE id = %s AND is_deleted = FALSE", (str(post_id),))
        if not cur.fetchone():
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")

        if payload.value == 0:
            cur.execute(
                "DELETE FROM post_votes WHERE user_id = %s AND post_id = %s",
                (str(current_user.id), str(post_id)),
            )
        else:
            cur.execute(
                """
                INSERT INTO post_votes (user_id, post_id, value)
                VALUES (%s, %s, %s)
                ON CONFLICT (user_id, post_id) DO UPDATE SET value = EXCLUDED.value
                """,
                (str(current_user.id), str(post_id), payload.value),
            )
        db.commit()

    return _fetch_posts_by_id(db, str(post_id), str(current_user.id))


# ---------------------------------------------------------------------------
# Internal helper — fetch a single post by id with vote aggregation
# ---------------------------------------------------------------------------

def _fetch_posts_by_id(db, post_id: str, viewer_id: str | None) -> PostOut:
    with db.cursor() as cur:
        cur.execute(
            """
            SELECT
                p.id, p.challenge_id, p.parent_id,
                p.body, p.is_deleted, p.created_at, p.updated_at,
                u.id AS author_id, u.username, u.xp,
                COALESCE(SUM(v.value), 0)::int AS vote_score,
                (SELECT value FROM post_votes WHERE post_id = p.id AND user_id = %s) AS user_vote,
                (SELECT COUNT(*) FROM posts r WHERE r.parent_id = p.id AND r.is_deleted = FALSE)::int AS reply_count
            FROM posts p
            JOIN users u ON u.id = p.user_id
            LEFT JOIN post_votes v ON v.post_id = p.id
            WHERE p.id = %s
            GROUP BY p.id, u.id
            """,
            (viewer_id, post_id),
        )
        row = cur.fetchone()

    if not row:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")

    return PostOut(
        id=row["id"],
        challenge_id=row["challenge_id"],
        parent_id=row["parent_id"],
        author=PostAuthor(id=row["author_id"], username=row["username"], xp=row["xp"]),
        body="[deleted]" if row["is_deleted"] else row["body"],
        is_deleted=row["is_deleted"],
        vote_score=row["vote_score"],
        user_vote=row["user_vote"],
        reply_count=row["reply_count"],
        created_at=row["created_at"],
        updated_at=row["updated_at"],
    )


# ---------------------------------------------------------------------------
# Optional auth helper (for public list endpoint)
# ---------------------------------------------------------------------------

def _optional_user(credentials, db) -> Optional[UserInDB]:
    """Return the authenticated user if a valid Bearer token is present, else None."""
    if credentials is None:
        return None
    try:
        from auth.tokens import decode_token
        payload = decode_token(credentials.credentials, expected_type="access")
        user_id = payload["sub"]
        with db.cursor() as cur:
            cur.execute(
                "SELECT id, username, email, password_hash, salt, role, is_active, is_verified, "
                "created_at, updated_at, last_login_at, xp, streak_days, challenges_completed "
                "FROM users WHERE id = %s",
                (user_id,),
            )
            row = cur.fetchone()
        if row and row["is_active"]:
            return UserInDB(**row)
    except Exception:
        pass
    return None
