"""
POST /api/evaluate

Accepts a code submission + challenge context and returns AI architectural feedback
using the Anthropic Claude API.
"""

import os
from fastapi import APIRouter, HTTPException, status, Depends
from pydantic import BaseModel
import anthropic

from auth.dependencies import get_current_user
from core.database import get_db
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
    xp_earned: int = 0  # populated server-side after saving


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

    # Award XP and increment challenges_completed
    xp_earned = _xp_for_score(feedback.score)
    with db.cursor() as cur:
        cur.execute(
            """
            UPDATE users
            SET xp = xp + %s,
                challenges_completed = challenges_completed + 1,
                updated_at = NOW()
            WHERE id = %s
            """,
            (xp_earned, str(current_user.id)),
        )

    feedback.xp_earned = xp_earned
    return feedback
