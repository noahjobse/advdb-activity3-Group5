-- Three vector queries (Altesse's half). All use pgvector's cosine distance operator <=>:
-- 0 = same meaning, bigger = less alike. The HNSW index on titles.embedding
-- (vector_cosine_ops, built in 06_ca3_titles_vectors.sql) serves ORDER BY embedding <=> ... LIMIT k.
-- Run after 01-04, 06 and 07.

-- Q4 — Search by meaning.
-- Business question: a viewer types "something scary in the woods". Which 5 titles mean the closest thing?
-- PostgreSQL can't turn text into a vector, so the phrase was embedded by the notebook and stored in
-- search_phrases (phrase_id 4); we look it up by its text.
SELECT t.title_id, t.title, t.genre,
       round((t.embedding <=> p.embedding)::numeric, 3) AS distance
FROM titles t,
     search_phrases p
WHERE p.phrase = 'something scary in the woods'
ORDER BY t.embedding <=> p.embedding
LIMIT 5;

-- Q5 — "More like this".
-- Business question: a viewer just finished "Hollow Pines". Which 5 other titles are closest in meaning?
-- The chosen title is excluded, since it is always distance 0 from itself.
SELECT t.title_id, t.title, t.genre,
       round((t.embedding <=> src.embedding)::numeric, 3) AS distance
FROM titles t,
     titles src
WHERE src.title = 'Hollow Pines'
  AND t.title_id <> src.title_id
ORDER BY t.embedding <=> src.embedding
LIMIT 5;

-- Q6 — Vector search combined with a filter from our other data.
-- Business question: for user 16, recommend 5 titles similar to the last title they played,
-- leaving out every title they have already played.
-- The "last watched" title and the "already watched" list both come from activity_log
-- (event_type = 'play'); the similarity comes from titles.embedding.
WITH last_watched AS (
    SELECT a.title_id
    FROM activity_log a
    WHERE a.user_id = 16
      AND a.event_type = 'play'
    ORDER BY a.occurred_at DESC, a.event_id DESC
    LIMIT 1
)
SELECT src.title AS because_you_watched,
       t.title_id, t.title, t.genre,
       round((t.embedding <=> src.embedding)::numeric, 3) AS distance
FROM last_watched lw
JOIN titles src ON src.title_id = lw.title_id
CROSS JOIN titles t
WHERE NOT EXISTS (
          SELECT 1
          FROM activity_log seen
          WHERE seen.user_id = 16
            AND seen.event_type = 'play'
            AND seen.title_id = t.title_id)
ORDER BY t.embedding <=> src.embedding
LIMIT 5;
