-- Migration 010: add email verification token columns to users
-- Run once against your Supabase PostgreSQL instance.

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS verification_token          TEXT,
    ADD COLUMN IF NOT EXISTS verification_token_expires_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_users_verification_token
    ON users (verification_token)
    WHERE verification_token IS NOT NULL;
