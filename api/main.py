from fastapi import FastAPI
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

app = FastAPI(title="Cr4ck API")

setup_cors(app)

app.include_router(auth_router.router)
app.include_router(challenges_router.router)
app.include_router(evaluate_router.router)
app.include_router(leaderboard_router.router)
app.include_router(run_router.router)
app.include_router(ws_router.router)
app.include_router(posts_router.router)
app.include_router(profile_router.router)
app.include_router(apikey_router.router)


@app.on_event("startup")
async def startup():
    # Eagerly probe Redis so the first request doesn't pay the connect cost
    get_redis()


@app.get("/")
def root():
    return {"message": "Cr4ck API is running"}
