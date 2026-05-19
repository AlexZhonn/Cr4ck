-- Migration 019: Solution Showcase
-- Adds opt-in public sharing columns to user_challenges so users who score ≥ 80
-- can share their solution. Top solutions are surfaced in the Community tab.

ALTER TABLE user_challenges
    ADD COLUMN IF NOT EXISTS is_public       BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS public_code     TEXT,
    ADD COLUMN IF NOT EXISTS public_language VARCHAR(20);

-- Index to quickly fetch top solutions per challenge
CREATE INDEX IF NOT EXISTS idx_user_challenges_public
    ON user_challenges (challenge_id, is_public, best_score DESC)
    WHERE is_public = TRUE;
