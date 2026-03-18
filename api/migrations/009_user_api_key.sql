-- Migration 009: per-user AI provider + encrypted API key
-- Supports: anthropic, openai, google
-- Key is AES-256-GCM encrypted server-side via API_KEY_SECRET env var.
-- api_key_enc is NEVER returned in any API response.

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS ai_provider   VARCHAR(20) DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS api_key_enc   TEXT        DEFAULT NULL;

-- ai_provider must be one of the supported values when set
ALTER TABLE users
    ADD CONSTRAINT chk_ai_provider
    CHECK (ai_provider IS NULL OR ai_provider IN ('anthropic', 'openai', 'google'));
