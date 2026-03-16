"""
POST /api/evaluate

Accepts a code submission + challenge context and returns AI architectural feedback
using the Anthropic Claude API.
"""

import asyncio
import os
from fastapi import APIRouter, HTTPException, status, Depends
from pydantic import BaseModel
import anthropic

from auth.dependencies import get_current_user
from core.database import get_db
from core.redis import cache_delete, LEADERBOARD_KEY
from models.user import UserInDB

router = APIRouter(prefix="/api", tags=["evaluate"])

_client: anthropic.Anthropic | None = None


def _get_client() -> anthropic.Anthropic:
    global _client
    if _client is None:
        api_key = os.getenv("ANTHROPIC_API_KEY")
        if not api_key:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="AI evaluation service is not configured",
            )
        _client = anthropic.Anthropic(api_key=api_key)
    return _client


class EvaluateRequest(BaseModel):
    challenge_id: str
    challenge_title: str
    language: str
    code: str
    problem_description: str = ""


class EvaluationFeedback(BaseModel):
    score: int  # 0-100
    summary: str
    strengths: list[str]
    improvements: list[str]
    oop_feedback: str
    architecture_feedback: str
    xp_earned: int = 0        # populated server-side after saving
    is_first_completion: bool = True  # False if challenge was already completed


SYSTEM_PROMPT = """You are an expert software architect and OOP educator reviewing student code submissions on the Cr4ck platform.

Your role is to give honest, specific, and constructive architectural feedback. You evaluate:
1. Object-Oriented Design: encapsulation, inheritance, polymorphism, abstraction, SOLID principles
2. Code quality: readability, naming, separation of concerns
3. Correctness: does it solve the problem as described
4. Language idioms: proper use of the chosen language's features

Respond ONLY with a valid JSON object matching this exact schema (no markdown, no extra text):
{
  "score": <integer 0-100>,
  "summary": "<1-2 sentence overall assessment>",
  "strengths": ["<strength 1>", "<strength 2>", ...],
  "improvements": ["<improvement 1>", "<improvement 2>", ...],
  "oop_feedback": "<specific OOP/design patterns feedback>",
  "architecture_feedback": "<system design / architecture feedback>"
}"""


def _xp_for_score(score: int) -> int:
    if score >= 80:
        return 50
    if score >= 60:
        return 30
    if score >= 40:
        return 15
    return 5


@router.post("/evaluate", response_model=EvaluationFeedback)
def evaluate(
    body: EvaluateRequest,
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    if not body.code.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Code cannot be empty",
        )

    user_message = f"""Challenge: {body.challenge_title} (ID: {body.challenge_id})
Language: {body.language}

Problem Description:
{body.problem_description or "Not provided"}

Student Code:
```{body.language.lower()}
{body.code}
```

Please evaluate this submission."""

    client = _get_client()
    try:
        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1024,
            system=SYSTEM_PROMPT,
            messages=[{"role": "user", "content": user_message}],
        )
    except anthropic.APIError as e:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"AI service error: {str(e)}",
        )

    raw = response.content[0].text.strip()

    import json
    try:
        data = json.loads(raw)
        feedback = EvaluationFeedback(**data)
    except (json.JSONDecodeError, ValueError):
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="AI returned malformed response — please try again",
        )

    from datetime import date, timezone
    xp_earned = _xp_for_score(feedback.score)
    user_id = str(current_user.id)

    with db.cursor() as cur:
        # Check if this challenge was already completed by this user
        cur.execute(
            "SELECT best_score, attempts FROM user_challenges WHERE user_id = %s AND challenge_id = %s",
            (user_id, body.challenge_id),
        )
        existing = cur.fetchone()
        is_first_completion = existing is None

        if is_first_completion:
            # First submission — record it and award full XP
            cur.execute(
                """
                INSERT INTO user_challenges (user_id, challenge_id, best_score, attempts)
                VALUES (%s, %s, %s, 1)
                """,
                (user_id, body.challenge_id, feedback.score),
            )
        else:
            # Subsequent submission — update best score and attempt count, no XP
            xp_earned = 0
            new_best = max(existing["best_score"], feedback.score)
            cur.execute(
                """
                UPDATE user_challenges
                SET best_score = %s, attempts = attempts + 1, last_attempted_at = NOW()
                WHERE user_id = %s AND challenge_id = %s
                """,
                (new_best, user_id, body.challenge_id),
            )

        # Update streak and user stats
        cur.execute(
            "SELECT last_login_at, streak_days FROM users WHERE id = %s",
            (user_id,),
        )
        row = cur.fetchone()
        last_login = row["last_login_at"]
        current_streak = row["streak_days"] or 0

        today = date.today()
        if last_login is None:
            new_streak = 1
        else:
            last_date = last_login.astimezone(timezone.utc).date()
            delta = (today - last_date).days
            if delta == 0:
                new_streak = current_streak
            elif delta == 1:
                new_streak = current_streak + 1
            else:
                new_streak = 1

        cur.execute(
            """
            UPDATE users
            SET xp = xp + %s,
                challenges_completed = challenges_completed + %s,
                streak_days = %s,
                last_login_at = NOW(),
                updated_at = NOW()
            WHERE id = %s
            """,
            (xp_earned, 1 if is_first_completion else 0, new_streak, user_id),
        )

    feedback.xp_earned = xp_earned
    feedback.is_first_completion = is_first_completion

    # Bust leaderboard cache and broadcast real-time events
    if xp_earned > 0:
        cache_delete(LEADERBOARD_KEY)
        try:
            from routers.ws import manager
            asyncio.create_task(manager.broadcast({
                "type": "solve_event",
                "username": current_user.username,
                "challenge_title": body.challenge_title,
                "xp_earned": xp_earned,
                "score": feedback.score,
            }))
            asyncio.create_task(manager.broadcast({"type": "leaderboard_update"}))
        except Exception:
            pass  # WS broadcast failure must never break the evaluate response

    return feedback
