-- Migration 002: track per-user challenge completions
-- Prevents duplicate XP farming and enables leaderboard per-challenge stats.

CREATE TABLE IF NOT EXISTS user_challenges (
    id           BIGSERIAL    PRIMARY KEY,
    user_id      UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    challenge_id VARCHAR(50)  NOT NULL,
    best_score   INTEGER      NOT NULL DEFAULT 0,
    attempts     INTEGER      NOT NULL DEFAULT 1,
    first_completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_attempted_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, challenge_id)
);

CREATE INDEX IF NOT EXISTS idx_user_challenges_user_id ON user_challenges (user_id);
CREATE INDEX IF NOT EXISTS idx_user_challenges_challenge_id ON user_challenges (challenge_id);
