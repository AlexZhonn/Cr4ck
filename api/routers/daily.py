"""
GET  /api/v1/daily                  — today's challenge (public, Redis-cached)
POST /api/admin/generate-daily      — generate a new daily challenge via Claude
                                      Protected by X-Admin-Secret header.

Daily challenge generation flow:
  1. Build a prompt that includes the last 7 days' topics/difficulties.
  2. Ask Claude to return a strict JSON challenge document.
  3. Validate the JSON, retry up to MAX_RETRIES on malformed output.
  4. Fall back to a random previously-unshown challenge if all retries fail.
  5. INSERT into challenges (is_ai_generated=TRUE) + daily_challenges, cache in Redis.

Weekly rotation schedule (weekday of the *generation* date, UTC):
  Mon → Easy  design_patterns
  Tue → Medium solid_principles
  Wed → Hard  concurrency
  Thu → Easy  creational_patterns
  Fri → Medium structural_patterns
  Sat → Hard  behavioral_patterns
  Sun → free pick (varied topic, medium difficulty)
"""

import json
import logging
import os
import secrets
from datetime import date, timedelta

from fastapi import APIRouter, Depends, Header, HTTPException, Request, status
from pydantic import BaseModel
from slowapi import Limiter
from slowapi.util import get_remote_address

from core.database import get_db
from core.redis import DAILY_KEY_PREFIX, cache_get, cache_set
from routers.challenges import ChallengeOut, _row_to_challenge

logger = logging.getLogger(__name__)
limiter = Limiter(key_func=get_remote_address)

# Two separate routers so main.py can mount them at different prefixes
# without double-registering both routes under both prefixes.
router = APIRouter(tags=["daily"])           # mounted at /api/v1  → GET  /api/v1/daily
admin_router = APIRouter(tags=["admin"])     # mounted at /api/admin → POST /api/admin/generate-daily

router = APIRouter(tags=["daily"])

MAX_RETRIES = 3

# Seconds until the next midnight UTC from *now* — used as Redis TTL.
def _seconds_until_midnight() -> int:
    from datetime import datetime, timezone

    now = datetime.now(tz=timezone.utc)
    tomorrow = (now + timedelta(days=1)).replace(
        hour=0, minute=0, second=0, microsecond=0
    )
    return max(int((tomorrow - now).total_seconds()), 1)


# ── Weekly rotation ────────────────────────────────────────────────────────────

_WEEKLY_ROTATION = {
    0: ("design_patterns", "Easy"),       # Monday
    1: ("solid_principles", "Medium"),    # Tuesday
    2: ("concurrency", "Hard"),           # Wednesday
    3: ("creational_patterns", "Easy"),   # Thursday
    4: ("structural_patterns", "Medium"), # Friday
    5: ("behavioral_patterns", "Hard"),   # Saturday
    6: ("design_patterns", "Medium"),     # Sunday — free pick
}

_TOPICS = [
    "design_patterns",
    "solid_principles",
    "concurrency",
    "creational_patterns",
    "structural_patterns",
    "behavioral_patterns",
    "data_structures",
    "system_design",
]


def _rotation_for(target_date: date) -> tuple[str, str]:
    """Return (topic, difficulty) for the given date's weekday."""
    return _WEEKLY_ROTATION[target_date.weekday()]


# ── Claude generation ──────────────────────────────────────────────────────────

_CHALLENGE_SCHEMA = """{
  "title": "<string — concise, descriptive>",
  "topic": "<one of: design_patterns|solid_principles|concurrency|creational_patterns|structural_patterns|behavioral_patterns|data_structures|system_design>",
  "difficulty": "<Easy|Medium|Hard>",
  "language": "java",
  "framework": "none",
  "description": "<full problem statement, 150-400 words, includes requirements and constraints>",
  "starter_code": "<compilable Java starter code with TODO comments>",
  "starter_codes": {
    "java": "<same as starter_code>",
    "python": "<equivalent Python starter>",
    "typescript": "<equivalent TypeScript starter>",
    "cpp": "<equivalent C++ starter>"
  },
  "test_cases": [
    {"input": "<stdin string>", "expected_output": "<stdout string>", "description": "<what this tests>"},
    {"input": "<stdin string>", "expected_output": "<stdout string>", "description": "<what this tests>"},
    {"input": "<stdin string>", "expected_output": "<stdout string>", "description": "<what this tests>"}
  ]
}"""

_GENERATION_SYSTEM_PROMPT = (
    "You are an expert OOP and system-design educator creating daily coding challenges "
    "for the Cr4ck platform. Produce one challenge strictly matching the JSON schema below. "
    "Return ONLY valid JSON — no markdown fences, no prose, no trailing commas.\n\n"
    "Schema:\n" + _CHALLENGE_SCHEMA
)


def _build_generation_prompt(
    topic: str,
    difficulty: str,
    recent: list[dict],
) -> str:
    recent_str = (
        "\n".join(
            f"  - {r['topic']} / {r['difficulty']} ({r['date']})" for r in recent
        )
        or "  (none)"
    )
    return (
        f"Generate a NEW {difficulty} challenge on topic '{topic}'.\n\n"
        f"Recent daily challenges (avoid repeating these exact topics/difficulties):\n"
        f"{recent_str}\n\n"
        "Requirements:\n"
        "- The challenge must be solvable in under 45 minutes.\n"
        "- Starter code must compile / parse without errors.\n"
        "- Include exactly 3 test cases with stdin/stdout pairs.\n"
        "- Description must be self-contained (no external references).\n"
        "- Do NOT reuse any challenge from the recent list above."
    )


def _call_claude(prompt: str) -> dict:
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        raise RuntimeError("ANTHROPIC_API_KEY not set; cannot generate daily challenge")
    import anthropic

    client = anthropic.Anthropic(api_key=api_key)
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=2048,
        system=_GENERATION_SYSTEM_PROMPT,
        messages=[{"role": "user", "content": prompt}],
    )
    raw = response.content[0].text.strip()
    return json.loads(raw)


def _validate_challenge_data(data: dict) -> None:
    """Raise ValueError with a descriptive message if required fields are missing/invalid."""
    required = ["title", "topic", "difficulty", "language", "framework", "description", "starter_code"]
    for field in required:
        if not data.get(field):
            raise ValueError(f"Missing required field: {field}")
    if data["topic"] not in _TOPICS:
        raise ValueError(f"Invalid topic: {data['topic']}")
    if data["difficulty"] not in ("Easy", "Medium", "Hard"):
        raise ValueError(f"Invalid difficulty: {data['difficulty']}")
    test_cases = data.get("test_cases", [])
    if not isinstance(test_cases, list) or len(test_cases) < 1:
        raise ValueError("test_cases must be a non-empty list")
    for i, tc in enumerate(test_cases):
        if not isinstance(tc, dict):
            raise ValueError(f"test_cases[{i}] must be an object")
        for key in ("input", "expected_output", "description"):
            if key not in tc:
                raise ValueError(f"test_cases[{i}] missing key '{key}'")


# ── Endpoints ──────────────────────────────────────────────────────────────────

class GenerateDailyRequest(BaseModel):
    date: str | None = None  # YYYY-MM-DD; defaults to today (UTC)


@router.get("/daily", response_model=ChallengeOut)
def get_daily(db=Depends(get_db)):
    """Return today's daily challenge. Cached until midnight UTC."""
    today = date.today().isoformat()
    cache_key = DAILY_KEY_PREFIX + today

    cached = cache_get(cache_key)
    if cached is not None:
        return ChallengeOut(**cached)

    with db.cursor() as cur:
        cur.execute(
            """
            SELECT c.id, c.title, c.topic, c.difficulty, c.language, c.framework,
                   c.description, c.starter_code, c.starter_codes, c.test_cases
            FROM daily_challenges dc
            JOIN challenges c ON c.id = dc.challenge_id
            WHERE dc.date = %s AND c.is_active = TRUE
            """,
            (today,),
        )
        row = cur.fetchone()

    if not row:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No daily challenge has been set for today yet.",
        )

    challenge = _row_to_challenge(row)
    cache_set(cache_key, challenge.model_dump(), _seconds_until_midnight())
    return challenge


@admin_router.post("/generate-daily", status_code=201)
def generate_daily(
    body: GenerateDailyRequest,
    x_admin_secret: str | None = Header(default=None, alias="X-Admin-Secret"),
    db=Depends(get_db),
):
    """
    Generate (or assign) today's daily challenge.
    Protected by X-Admin-Secret header — must match ADMIN_SECRET env var.
    """
    admin_secret = os.getenv("ADMIN_SECRET")
    if not admin_secret:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="ADMIN_SECRET is not configured on this server.",
        )
    if not x_admin_secret or not secrets.compare_digest(x_admin_secret, admin_secret):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing X-Admin-Secret.",
        )

    # Resolve target date
    if body.date:
        try:
            target = date.fromisoformat(body.date)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD.")
    else:
        target = date.today()

    target_str = target.isoformat()

    # Idempotency — return existing record if already generated
    with db.cursor() as cur:
        cur.execute(
            "SELECT challenge_id FROM daily_challenges WHERE date = %s",
            (target_str,),
        )
        existing = cur.fetchone()

    if existing:
        logger.info("daily.already_exists", extra={"date": target_str, "challenge_id": str(existing["challenge_id"])})
        return {"date": target_str, "challenge_id": str(existing["challenge_id"]), "created": False}

    # Gather last 7 days' context
    with db.cursor() as cur:
        cur.execute(
            """
            SELECT dc.date::text, c.topic, c.difficulty
            FROM daily_challenges dc
            JOIN challenges c ON c.id = dc.challenge_id
            WHERE dc.date >= %s
            ORDER BY dc.date DESC
            LIMIT 7
            """,
            ((target - timedelta(days=7)).isoformat(),),
        )
        recent = [{"date": r["date"], "topic": r["topic"], "difficulty": r["difficulty"]} for r in cur.fetchall()]

    topic, difficulty = _rotation_for(target)
    prompt = _build_generation_prompt(topic, difficulty, recent)

    # Try Claude up to MAX_RETRIES times, fall back to random unshown challenge
    challenge_id: str | None = None
    ai_generated = True

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            data = _call_claude(prompt)
            _validate_challenge_data(data)

            starter_codes = data.get("starter_codes") or {data["language"]: data["starter_code"]}
            test_cases = data.get("test_cases", [])

            with db.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO challenges
                      (title, topic, difficulty, language, framework, description,
                       starter_code, starter_codes, test_cases, is_active,
                       is_ai_generated, generated_at)
                    VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,TRUE,TRUE,NOW())
                    RETURNING id
                    """,
                    (
                        data["title"],
                        data["topic"],
                        data["difficulty"],
                        data["language"],
                        data.get("framework", "none"),
                        data["description"],
                        data["starter_code"],
                        json.dumps(starter_codes),
                        json.dumps(test_cases),
                    ),
                )
                row = cur.fetchone()
                challenge_id = str(row["id"])

            logger.info("daily.generated", extra={"date": target_str, "challenge_id": challenge_id, "attempt": attempt})
            break

        except (json.JSONDecodeError, ValueError) as exc:
            logger.warning("daily.malformed_response", extra={"attempt": attempt, "error": str(exc)})
        except Exception as exc:
            logger.warning("daily.generation_error", extra={"attempt": attempt, "error": str(exc)})

    # Fall back: pick a random challenge that has never been a daily challenge
    if challenge_id is None:
        ai_generated = False
        with db.cursor() as cur:
            cur.execute(
                """
                SELECT id FROM challenges
                WHERE is_active = TRUE
                  AND id NOT IN (SELECT challenge_id FROM daily_challenges)
                ORDER BY RANDOM()
                LIMIT 1
                """
            )
            fallback = cur.fetchone()

        if not fallback:
            # All challenges have been used; just pick any random active one
            with db.cursor() as cur:
                cur.execute(
                    "SELECT id FROM challenges WHERE is_active = TRUE ORDER BY RANDOM() LIMIT 1"
                )
                fallback = cur.fetchone()

        if not fallback:
            raise HTTPException(status_code=500, detail="No active challenges available for fallback.")

        challenge_id = str(fallback["id"])
        logger.warning("daily.used_fallback", extra={"date": target_str, "challenge_id": challenge_id})

    # Insert daily_challenges row
    with db.cursor() as cur:
        cur.execute(
            "INSERT INTO daily_challenges (date, challenge_id) VALUES (%s, %s)",
            (target_str, challenge_id),
        )

    # Bust the Redis cache for this date so GET /daily returns the new challenge
    from core.redis import cache_delete
    cache_delete(DAILY_KEY_PREFIX + target_str)

    return {"date": target_str, "challenge_id": challenge_id, "created": True, "ai_generated": ai_generated}
