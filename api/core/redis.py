"""
Redis client + cache helpers.

REDIS_URL defaults to redis://localhost:6379/0.
If Redis is unavailable, all cache operations silently no-op so the app
continues to work without a Redis instance.
"""

import json
import logging
import os
from typing import Any

import redis

logger = logging.getLogger(__name__)

_client: redis.Redis | None = None

CHALLENGES_KEY = "cr4ck:challenges"
CHALLENGES_TTL = 300  # 5 minutes

LEADERBOARD_KEY = "cr4ck:leaderboard"
LEADERBOARD_TTL = 60  # 1 minute

DAILY_KEY_PREFIX = "cr4ck:daily:"  # + YYYY-MM-DD suffix


def get_redis() -> redis.Redis | None:
    global _client
    if _client is not None:
        return _client
    url = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    try:
        _client = redis.from_url(url, decode_responses=True, socket_connect_timeout=2)
        _client.ping()
        logger.info("Redis connected: %s", url)
    except Exception as exc:
        logger.warning("Redis unavailable (%s) — caching disabled", exc)
        _client = None
    return _client


# ── Generic helpers ───────────────────────────────────────────────────────────

def cache_get(key: str) -> Any | None:
    r = get_redis()
    if r is None:
        return None
    try:
        raw = r.get(key)
        return json.loads(raw) if raw else None
    except Exception as exc:
        logger.warning("cache_get %s failed: %s", key, exc)
        return None


def cache_set(key: str, value: Any, ttl: int) -> None:
    r = get_redis()
    if r is None:
        return
    try:
        r.setex(key, ttl, json.dumps(value))
    except Exception as exc:
        logger.warning("cache_set %s failed: %s", key, exc)


def cache_delete(*keys: str) -> None:
    r = get_redis()
    if r is None:
        return
    try:
        r.delete(*keys)
    except Exception as exc:
        logger.warning("cache_delete failed: %s", exc)
