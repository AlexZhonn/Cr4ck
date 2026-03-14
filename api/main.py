from fastapi import FastAPI
from core.config import setup_cors
from routers import auth as auth_router
from routers import challenges as challenges_router
from routers import evaluate as evaluate_router
from routers import leaderboard as leaderboard_router

app = FastAPI(title="Cr4ck API")

setup_cors(app)

app.include_router(auth_router.router)
app.include_router(challenges_router.router)
app.include_router(evaluate_router.router)
app.include_router(leaderboard_router.router)


@app.get("/")
def root():
    return {"message": "Cr4ck API is running"}
