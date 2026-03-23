import logging
import time
import uuid

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

from core.config import setup_cors
from core.redis import get_redis
from routers import auth as auth_router
from routers import challenges as challenges_router
from routers import evaluate as evaluate_router
from routers import leaderboard as leaderboard_router
from routers import run as run_router
from routers import ws as ws_router
from routers import posts as posts_router
from routers import profile as profile_router
from routers import apikey as apikey_router

# ── Structured JSON logging ────────────────────────────────────────────────────
try:
    from pythonjsonlogger import jsonlogger

    handler = logging.StreamHandler()
    handler.setFormatter(
        jsonlogger.JsonFormatter("%(asctime)s %(name)s %(levelname)s %(message)s")
    )
    logging.root.handlers = [handler]
except ImportError:
    # Graceful degradation: fall back to plain text if package is absent
    logging.basicConfig(level=logging.INFO)

logging.root.setLevel(logging.INFO)
logger = logging.getLogger(__name__)

# ── App setup ─────────────────────────────────────────────────────────────────
limiter = Limiter(key_func=get_remote_address, headers_enabled=True)

app = FastAPI(title="Cr4ck API")
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

setup_cors(app)


# ── Request logging middleware ─────────────────────────────────────────────────
@app.middleware("http")
async def request_logger(request: Request, call_next):
    request_id = str(uuid.uuid4())
    start = time.monotonic()

    # Extract user_id from Bearer token when present (best-effort — no DB hit)
    user_id = None
    auth_header = request.headers.get("Authorization", "")
    if auth_header.startswith("Bearer "):
        try:
            from auth.tokens import decode_token

            payload = decode_token(auth_header[7:], expected_type="access")
            user_id = payload.get("sub")
        except Exception:
            pass

    response = await call_next(request)
    duration_ms = round((time.monotonic() - start) * 1000, 1)

    logger.info(
        "http_request",
        extra={
            "request_id": request_id,
            "method": request.method,
            "path": request.url.path,
            "status_code": response.status_code,
            "duration_ms": duration_ms,
            "user_id": user_id,
        },
    )
    return response


# ── Routers ───────────────────────────────────────────────────────────────────
app.include_router(auth_router.router)
app.include_router(challenges_router.router)
app.include_router(evaluate_router.router)
app.include_router(leaderboard_router.router)
app.include_router(run_router.router)
app.include_router(ws_router.router)
app.include_router(posts_router.router)
app.include_router(profile_router.router)
app.include_router(apikey_router.router)


# ── Startup ───────────────────────────────────────────────────────────────────
@app.on_event("startup")
async def startup():
    # Eagerly probe Redis so the first request doesn't pay the connect cost
    get_redis()


# ── Health check ──────────────────────────────────────────────────────────────
@app.get("/health")
def health():
    """
    Returns dependency status.  Used by load-balancers and orchestrators.

    Response:
      200 — all critical deps healthy
      503 — one or more deps are degraded
    """
    import psycopg2
    import os

    db_status = "error"
    try:
        conn = psycopg2.connect(
            os.getenv("DATABASE_URL"),
            options="-c statement_timeout=2000",
            connect_timeout=2,
        )
        with conn.cursor() as cur:
            cur.execute("SELECT 1")
        conn.close()
        db_status = "ok"
    except Exception as exc:
        logger.warning("Health check DB failed: %s", exc)

    redis_status = "disabled"
    r = get_redis()
    if r is not None:
        try:
            r.ping()
            redis_status = "ok"
        except Exception as exc:
            logger.warning("Health check Redis failed: %s", exc)
            redis_status = "error"

    overall = "ok" if db_status == "ok" else "degraded"
    return JSONResponse(
        status_code=200 if overall == "ok" else 503,
        content={"status": overall, "db": db_status, "redis": redis_status},
    )


@app.get("/")
def root():
    return {"message": "Cr4ck API is running"}
