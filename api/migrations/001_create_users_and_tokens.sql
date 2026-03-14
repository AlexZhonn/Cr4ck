-- Migration 001: users table + refresh_tokens table
-- Run once against your Supabase PostgreSQL instance.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";  -- for gen_random_uuid()

-- ─── Users ───────────────────────────────────────────────────────────────────

CREATE TYPE user_role AS ENUM ('user', 'admin');

CREATE TABLE IF NOT EXISTS users (
    id                   UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    username             VARCHAR(50)   NOT NULL UNIQUE,
    email                VARCHAR(255)  NOT NULL UNIQUE,
    password_hash        TEXT          NOT NULL,
    salt                 TEXT          NOT NULL,         -- 64-char hex, per-user
    role                 user_role     NOT NULL DEFAULT 'user',
    is_active            BOOLEAN       NOT NULL DEFAULT TRUE,
    is_verified          BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at           TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    last_login_at        TIMESTAMPTZ,
    -- Gamification / progress
    xp                   INTEGER       NOT NULL DEFAULT 0,
    streak_days          INTEGER       NOT NULL DEFAULT 0,
    challenges_completed INTEGER       NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_users_email    ON users (email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users (username);

-- ─── Refresh Tokens ──────────────────────────────────────────────────────────
-- Stores JTI (JWT ID) of every issued refresh token so we can revoke them.

CREATE TABLE IF NOT EXISTS refresh_tokens (
    id         BIGSERIAL    PRIMARY KEY,
    jti        UUID         NOT NULL UNIQUE,   -- matches "jti" claim in JWT
    user_id    UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ  NOT NULL,
    revoked    BOOLEAN      NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_jti     ON refresh_tokens (jti);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens (user_id);
