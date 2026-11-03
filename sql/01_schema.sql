-- CA3 schema — Group 5. Three storage styles in one PostgreSQL database.
-- Noah's half (this file): structured columns + JSONB (users.preferences, activity_log.details)
--   + the titles catalogue, with a GIN index on each JSONB column.
-- Altesse's vector half extends `titles` with an `embedding vector(384)` column and adds the
-- `search_phrases` table + pgvector (see notebooks/ and CA3_Making_the_Embeddings).

DROP TABLE IF EXISTS activity_log, search_phrases, users, titles CASCADE;

-- Structured profile columns + a JSONB column for preferences that vary per user.
CREATE TABLE users (
    user_id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name         text NOT NULL,
    email        text NOT NULL UNIQUE,
    country      text NOT NULL,
    plan         text NOT NULL CHECK (plan IN ('Free','Standard','Premium')),
    preferences  jsonb NOT NULL          -- {favourite_genres:[...], subtitle_language, parental_controls}
);

-- The title catalogue (loaded from data/ca3_titles.csv). Altesse adds `embedding vector(384)`.
CREATE TABLE titles (
    title_id     bigint PRIMARY KEY,
    title        text NOT NULL,
    kind         text NOT NULL,
    release_year int,
    genre        text,
    description  text NOT NULL
);

-- Semi-structured events: each row is one event, its shape varies by type -> stored as JSONB.
CREATE TABLE activity_log (
    event_id     bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id      bigint NOT NULL REFERENCES users(user_id),
    title_id     bigint REFERENCES titles(title_id),   -- nullable: a search event has no title
    event_type   text NOT NULL CHECK (event_type IN ('play','pause','rate','search')),
    occurred_at  timestamptz NOT NULL DEFAULT now(),
    details      jsonb NOT NULL                         -- differs by event_type
);

-- GIN index on each JSONB column (required). jsonb_path_ops: smaller + faster for the `@>`
-- containment queries we run, at the cost of not supporting key-exists (`?`) lookups.
CREATE INDEX idx_users_preferences_gin   ON users        USING gin (preferences jsonb_path_ops);
CREATE INDEX idx_activity_details_gin    ON activity_log USING gin (details     jsonb_path_ops);
