from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime
from uuid import UUID
from enum import Enum


class BadgeOut(BaseModel):
    id: str
    label: str
    description: str
    icon: str


class UserBadgeOut(BadgeOut):
    earned_at: datetime


class UserRole(str, Enum):
    user = "user"
    admin = "admin"


# --- DB row representation (what comes out of postgres) ---

class UserInDB(BaseModel):
    id: UUID
    username: str
    email: str
    password_hash: str
    salt: str
    role: UserRole
    is_active: bool
    is_verified: bool
    created_at: datetime
    updated_at: datetime
    last_login_at: Optional[datetime]
    xp: int
    streak_days: int
    challenges_completed: int


# --- Request / Response schemas ---

class RegisterRequest(BaseModel):
    username: str = Field(..., min_length=3, max_length=50, pattern=r"^[a-zA-Z0-9_]+$")
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=128)


class LoginRequest(BaseModel):
    email: str = Field(..., min_length=1, max_length=254)  # accepts email or username
    password: str = Field(..., min_length=1, max_length=128)


class UserPublic(BaseModel):
    """Safe user object — never exposes password_hash or salt."""
    id: UUID
    username: str
    email: str
    role: UserRole
    is_active: bool
    is_verified: bool
    created_at: datetime
    xp: int
    streak_days: int
    challenges_completed: int
    badges: list[UserBadgeOut] = []


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class RefreshRequest(BaseModel):
    refresh_token: str


class ForgotPasswordRequest(BaseModel):
    email: str = Field(..., min_length=1, max_length=254)


class ResetPasswordRequest(BaseModel):
    token: str
    password: str = Field(..., min_length=8, max_length=128)
