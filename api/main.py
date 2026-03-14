from fastapi import FastAPI
from core.config import setup_cors
from routers import auth as auth_router

app = FastAPI(title="Cr4ck API")

setup_cors(app)

app.include_router(auth_router.router)


@app.get("/")
def root():
    return {"message": "Cr4ck API is running"}
