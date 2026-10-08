-- Preserve AI feedback for each attempt; older submissions have no saved feedback.
ALTER TABLE submissions ADD COLUMN IF NOT EXISTS feedback JSONB;
