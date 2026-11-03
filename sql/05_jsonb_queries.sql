-- Three JSONB queries (Noah's half). Each shows a different JSONB technique.

-- Q1 — Containment (@>), served by the jsonb_path_ops GIN index on users.preferences.
-- Business question: which users count "Mystery" among their favourite genres?
SELECT user_id, name, preferences->'favourite_genres' AS favourite_genres
FROM users
WHERE preferences @> '{"favourite_genres": ["Mystery"]}'
ORDER BY user_id;

-- Q2 — Extract (->>) + aggregate.
-- Business question: total minutes watched per title (play events only), top 10.
SELECT a.title_id, t.title,
       SUM((a.details->>'minutes_watched')::int) AS total_minutes,
       COUNT(*)                                  AS play_events
FROM activity_log a
JOIN titles t ON t.title_id = a.title_id
WHERE a.event_type = 'play'
GROUP BY a.title_id, t.title
ORDER BY total_minutes DESC
LIMIT 10;

-- Q3 — jsonb_array_elements_text: unnest a JSON array into rows.
-- Business question: which favourite genres are most common across all users?
SELECT genre, COUNT(*) AS fans
FROM users, jsonb_array_elements_text(preferences->'favourite_genres') AS genre
GROUP BY genre
ORDER BY fans DESC;
