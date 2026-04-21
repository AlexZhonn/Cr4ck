-- Migration 015: Badges / Achievements System
-- Creates badges catalog and user_badges join table, seeds 15 badges.

CREATE TABLE badges (
    id          VARCHAR(50) PRIMARY KEY,
    label       VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    icon        VARCHAR(10) NOT NULL,   -- emoji icon
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_badges (
    id         BIGSERIAL PRIMARY KEY,
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    badge_id   VARCHAR(50) NOT NULL REFERENCES badges(id),
    earned_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, badge_id)
);

CREATE INDEX idx_user_badges_user_id ON user_badges(user_id);

-- ─── Seed: 15 badges ─────────────────────────────────────────────────────────

INSERT INTO badges (id, label, description, icon) VALUES
  -- First actions
  ('first_solve',     'First Blood',        'Complete your first challenge.',                          '🩸'),
  ('first_perfect',   'Perfectionist',      'Score 100 on any challenge.',                             '💯'),

  -- Score milestones
  ('score_80',        'Sharp Eye',          'Score 80 or above on a challenge.',                       '🎯'),
  ('score_90',        'High Achiever',      'Score 90 or above on a challenge.',                       '🏆'),

  -- Volume milestones
  ('challenges_10',   'Getting Started',    'Complete 10 challenges.',                                 '🔟'),
  ('challenges_25',   'On a Roll',          'Complete 25 challenges.',                                 '🎲'),
  ('challenges_50',   'Half Century',       'Complete 50 challenges.',                                 '🌗'),
  ('challenges_100',  'Centurion',          'Complete 100 challenges.',                                '💯'),

  -- Streak milestones
  ('streak_3',        'Hat Trick',          'Maintain a 3-day streak.',                                '🔥'),
  ('streak_7',        'Week Warrior',       'Maintain a 7-day streak.',                                '📅'),
  ('streak_30',       'Monthly Grind',      'Maintain a 30-day streak.',                               '🗓️'),

  -- XP milestones
  ('xp_500',          'XP Climber',         'Earn 500 total XP.',                                      '⚡'),
  ('xp_1000',         'XP Hunter',          'Earn 1000 total XP.',                                     '⚡'),
  ('xp_5000',         'XP Legend',          'Earn 5000 total XP.',                                     '🌟'),

  -- Perfect streak
  ('perfect_streak',  'Flawless Run',       'Score 100 on 3 consecutive evaluations.',                 '✨')
;
