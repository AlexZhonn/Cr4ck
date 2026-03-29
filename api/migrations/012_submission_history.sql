-- Migration 012: submission history — store code + score for every evaluation
-- Enables users to review past attempts and see how they improved over time.

-- Add last submission columns to user_challenges for quick "most recent" access
ALTER TABLE user_challenges
  ADD COLUMN IF NOT EXISTS last_code    TEXT,
  ADD COLUMN IF NOT EXISTS last_score   INTEGER,
  ADD COLUMN IF NOT EXISTS last_language VARCHAR(20);

-- Full submission history table (one row per evaluate call)
CREATE TABLE IF NOT EXISTS submissions (
    id           BIGSERIAL    PRIMARY KEY,
    user_id      UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    challenge_id VARCHAR(50)  NOT NULL,
    score        INTEGER      NOT NULL,
    language     VARCHAR(20)  NOT NULL,
    code         TEXT         NOT NULL,
    submitted_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_submissions_user_challenge
    ON submissions (user_id, challenge_id, submitted_at DESC);
