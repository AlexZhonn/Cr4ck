"""
API key management endpoints:
  PUT    /auth/api-key       — save or update user's AI provider + key
  DELETE /auth/api-key       — remove stored key
  GET    /auth/api-key/status — returns { has_key, provider } only (never the key)
"""

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from typing import Literal, Optional

from auth.dependencies import get_current_user
from auth.apikey import encrypt_key
from core.database import get_db
from models.user import UserInDB

router = APIRouter(prefix="/auth", tags=["api-key"])

AIProvider = Literal["anthropic", "openai", "google"]

PROVIDER_LABELS = {
    "anthropic": "Anthropic (Claude)",
    "openai": "OpenAI (GPT-4)",
    "google": "Google (Gemini)",
}


class SaveKeyRequest(BaseModel):
    provider: AIProvider
    api_key: str


class KeyStatusResponse(BaseModel):
    has_key: bool
    provider: Optional[str] = None
    provider_label: Optional[str] = None


@router.put("/api-key", status_code=status.HTTP_204_NO_CONTENT)
def save_api_key(
    body: SaveKeyRequest,
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    if not body.api_key.strip():
        raise HTTPException(status_code=400, detail="API key cannot be empty")

    try:
        enc = encrypt_key(body.api_key.strip())
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=str(e))

    with db.cursor() as cur:
        cur.execute(
            "UPDATE users SET ai_provider = %s, api_key_enc = %s WHERE id = %s",
            (body.provider, enc, str(current_user.id)),
        )


@router.delete("/api-key", status_code=status.HTTP_204_NO_CONTENT)
def delete_api_key(
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    with db.cursor() as cur:
        cur.execute(
            "UPDATE users SET ai_provider = NULL, api_key_enc = NULL WHERE id = %s",
            (str(current_user.id),),
        )


@router.get("/api-key/status", response_model=KeyStatusResponse)
def get_api_key_status(
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    with db.cursor() as cur:
        cur.execute(
            "SELECT ai_provider, api_key_enc FROM users WHERE id = %s",
            (str(current_user.id),),
        )
        row = cur.fetchone()

    if not row or not row["api_key_enc"]:
        return KeyStatusResponse(has_key=False)

    provider = row["ai_provider"]
    return KeyStatusResponse(
        has_key=True,
        provider=provider,
        provider_label=PROVIDER_LABELS.get(provider, provider),
    )
