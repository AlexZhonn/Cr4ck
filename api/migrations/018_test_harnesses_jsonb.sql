-- Migration 018: per-language test harnesses
-- Adds test_harnesses JSONB column keyed by language name.
-- run.py uses test_harnesses[lang] in preference to the legacy test_harness TEXT column.

ALTER TABLE challenges
    ADD COLUMN IF NOT EXISTS test_harnesses JSONB;
