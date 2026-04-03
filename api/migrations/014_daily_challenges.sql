-- Migration 014: Daily challenge support
--
-- Adds is_ai_generated + generated_at to challenges so we can distinguish
-- AI-generated daily challenges from the seeded corpus.
--
-- Creates daily_challenges table mapping one date → one challenge.

ALTER TABLE challenges
  ADD COLUMN IF NOT EXISTS is_ai_generated BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS generated_at    TIMESTAMPTZ;

CREATE TABLE IF NOT EXISTS daily_challenges (
  date         DATE         PRIMARY KEY,
  challenge_id VARCHAR(50)  NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_daily_challenges_challenge_id
  ON daily_challenges(challenge_id);
