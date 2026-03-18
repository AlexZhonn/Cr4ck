-- Migration 008: community discussion posts per challenge

CREATE TABLE IF NOT EXISTS posts (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_id VARCHAR(32) NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_id   UUID REFERENCES posts(id) ON DELETE CASCADE,  -- NULL = top-level post
    body        TEXT NOT NULL CHECK (char_length(body) BETWEEN 1 AND 10000),
    is_deleted  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_posts_challenge ON posts(challenge_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_parent    ON posts(parent_id) WHERE parent_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_posts_user      ON posts(user_id);

CREATE TABLE IF NOT EXISTS post_votes (
    user_id  UUID    NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id  UUID    NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    value    SMALLINT NOT NULL CHECK (value IN (1, -1)),
    PRIMARY KEY (user_id, post_id)
);

CREATE INDEX IF NOT EXISTS idx_post_votes_post ON post_votes(post_id);
