"""
POST /api/evaluate

Accepts a code submission + challenge context and returns AI architectural feedback.
Uses the authenticated user's stored AI provider + API key.
Falls back to the server's ANTHROPIC_API_KEY if the user has no key configured
(useful for dev/demo; set ALLOW_SERVER_KEY=false in prod to disable fallback).
"""

import asyncio
import os
import json
from fastapi import APIRouter, HTTPException, Depends, Request
from pydantic import BaseModel
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

from auth.dependencies import get_current_user
from auth.apikey import decrypt_key
from core.database import get_db
from core.redis import cache_delete, LEADERBOARD_KEY
from models.user import UserInDB

router = APIRouter(prefix="/api", tags=["evaluate"])


class EvaluateRequest(BaseModel):
    challenge_id: str
    challenge_title: str
    language: str
    code: str
    problem_description: str = ""


class EvaluationFeedback(BaseModel):
    score: int          # 0-100
    summary: str
    strengths: list[str]
    improvements: list[str]
    oop_feedback: str
    architecture_feedback: str
    xp_earned: int = 0
    is_first_completion: bool = True


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


def _call_anthropic(api_key: str, user_message: str) -> dict:
    import anthropic
    client = anthropic.Anthropic(api_key=api_key)
    try:
        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1024,
            system=SYSTEM_PROMPT,
            messages=[{"role": "user", "content": user_message}],
        )
    except anthropic.AuthenticationError:
        raise HTTPException(status_code=402, detail="Invalid Anthropic API key — please update it in your profile settings.")
    except anthropic.APIError as e:
        raise HTTPException(status_code=502, detail=f"Anthropic API error: {e}")
    return json.loads(response.content[0].text.strip())


def _call_openai(api_key: str, user_message: str) -> dict:
    try:
        import openai
    except ImportError:
        raise HTTPException(status_code=503, detail="OpenAI provider not available on this server.")
    client = openai.OpenAI(api_key=api_key)
    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            max_tokens=1024,
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": user_message},
            ],
            response_format={"type": "json_object"},
        )
    except openai.AuthenticationError:
        raise HTTPException(status_code=402, detail="Invalid OpenAI API key — please update it in your profile settings.")
    except openai.APIError as e:
        raise HTTPException(status_code=502, detail=f"OpenAI API error: {e}")
    return json.loads(response.choices[0].message.content)


def _call_google(api_key: str, user_message: str) -> dict:
    try:
        import google.generativeai as genai
    except ImportError:
        raise HTTPException(status_code=503, detail="Google provider not available on this server.")
    genai.configure(api_key=api_key)
    model = genai.GenerativeModel(
        "gemini-1.5-pro",
        system_instruction=SYSTEM_PROMPT,
        generation_config={"response_mime_type": "application/json"},
    )
    try:
        response = model.generate_content(user_message)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Google AI error: {e}")
    return json.loads(response.text)


def _run_evaluation(provider: str, api_key: str, user_message: str) -> dict:
    if provider == "anthropic":
        return _call_anthropic(api_key, user_message)
    if provider == "openai":
        return _call_openai(api_key, user_message)
    if provider == "google":
        return _call_google(api_key, user_message)
    raise HTTPException(status_code=400, detail=f"Unknown provider: {provider}")


@router.post("/evaluate", response_model=EvaluationFeedback)
@limiter.limit("30/hour")
def evaluate(
    request: Request,
    body: EvaluateRequest,
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    if not body.code.strip():
        raise HTTPException(status_code=400, detail="Code cannot be empty")

    # Resolve the API key: prefer user's stored key, fall back to server key
    with db.cursor() as cur:
        cur.execute(
            "SELECT ai_provider, api_key_enc FROM users WHERE id = %s",
            (str(current_user.id),),
        )
        row = cur.fetchone()

    provider: str | None = row["ai_provider"] if row else None
    api_key_enc: str | None = row["api_key_enc"] if row else None

    if api_key_enc and provider:
        try:
            api_key = decrypt_key(api_key_enc)
        except Exception:
            raise HTTPException(status_code=500, detail="Failed to decrypt stored API key.")
    else:
        # Fall back to server key (Anthropic only) if configured
        server_key = os.getenv("ANTHROPIC_API_KEY")
        allow_fallback = os.getenv("ALLOW_SERVER_KEY", "true").lower() != "false"
        if server_key and allow_fallback:
            provider = "anthropic"
            api_key = server_key
        else:
            raise HTTPException(
                status_code=402,
                detail="No AI API key configured. Please add your API key in profile settings.",
            )

    user_message = (
        f"Challenge: {body.challenge_title} (ID: {body.challenge_id})\n"
        f"Language: {body.language}\n\n"
        f"Problem Description:\n{body.problem_description or 'Not provided'}\n\n"
        f"Student Code:\n```{body.language.lower()}\n{body.code}\n```\n\n"
        f"Please evaluate this submission."
    )

    try:
        data = _run_evaluation(provider, api_key, user_message)
        feedback = EvaluationFeedback(**data)
    except HTTPException:
        raise
    except (json.JSONDecodeError, ValueError):
        raise HTTPException(status_code=502, detail="AI returned malformed response — please try again")

    # Record attempt and award XP
    from datetime import date, timezone
    xp_earned = _xp_for_score(feedback.score)
    user_id = str(current_user.id)

    with db.cursor() as cur:
        cur.execute(
            "SELECT best_score, attempts FROM user_challenges WHERE user_id = %s AND challenge_id = %s",
            (user_id, body.challenge_id),
        )
        existing = cur.fetchone()
        is_first_completion = existing is None

        if is_first_completion:
            cur.execute(
                "INSERT INTO user_challenges (user_id, challenge_id, best_score, attempts) VALUES (%s, %s, %s, 1)",
                (user_id, body.challenge_id, feedback.score),
            )
        else:
            xp_earned = 0
            new_best = max(existing["best_score"], feedback.score)
            cur.execute(
                "UPDATE user_challenges SET best_score = %s, attempts = attempts + 1, last_attempted_at = NOW() WHERE user_id = %s AND challenge_id = %s",
                (new_best, user_id, body.challenge_id),
            )

        cur.execute("SELECT last_login_at, streak_days FROM users WHERE id = %s", (user_id,))
        urow = cur.fetchone()
        last_login = urow["last_login_at"]
        current_streak = urow["streak_days"] or 0
        today = date.today()
        if last_login is None:
            new_streak = 1
        else:
            last_date = last_login.astimezone(timezone.utc).date()
            delta = (today - last_date).days
            new_streak = current_streak if delta == 0 else (current_streak + 1 if delta == 1 else 1)

        cur.execute(
            "UPDATE users SET xp = xp + %s, challenges_completed = challenges_completed + %s, streak_days = %s, last_login_at = NOW(), updated_at = NOW() WHERE id = %s",
            (xp_earned, 1 if is_first_completion else 0, new_streak, user_id),
        )

    feedback.xp_earned = xp_earned
    feedback.is_first_completion = is_first_completion

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
            pass

    return feedback
