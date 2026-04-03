-- Migration 013: test_harness (hidden driver) + starter_codes (multi-language)
--
-- test_harness: nullable TEXT; when present, the run endpoint concatenates it
--   with user-submitted code before passing to Judge0/Docker. The harness is
--   the sole entry point (public class Main / run_harness() / int main()).
--   Never returned to the client.
--
-- starter_codes: JSONB dict of { "language": "starter code string" }.
--   Returned to the client to support language selection in the sandbox.
--   Backfilled from the existing language + starter_code for all challenges.

ALTER TABLE challenges ADD COLUMN IF NOT EXISTS test_harness  TEXT;
ALTER TABLE challenges ADD COLUMN IF NOT EXISTS starter_codes JSONB;

-- Backfill starter_codes from existing single language + starter_code
UPDATE challenges
SET starter_codes = jsonb_build_object(language, starter_code)
WHERE starter_codes IS NULL;
