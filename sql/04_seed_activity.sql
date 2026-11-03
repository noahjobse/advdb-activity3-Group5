-- 120 synthetic activity events across four event types whose `details` differ by type.
-- Deterministic (seeded). play/pause/rate reference a title; search does not.
SELECT setseed(0.7);

INSERT INTO activity_log (user_id, title_id, event_type, occurred_at, details)
SELECT
    1 + (floor(random() * 24))::int                                   AS user_id,
    CASE WHEN et = 'search' THEN NULL
         ELSE 1 + (floor(random() * 60))::int END                     AS title_id,
    et,
    now() - (floor(random() * 30) || ' days')::interval               AS occurred_at,
    CASE et
        WHEN 'play'   THEN jsonb_build_object(
                              'minutes_watched', 5 + (floor(random() * 110))::int,
                              'device', (ARRAY['web','ios','android','tv'])[1 + (floor(random() * 4))::int])
        WHEN 'pause'  THEN jsonb_build_object('at_minute', (floor(random() * 90))::int)
        WHEN 'rate'   THEN jsonb_build_object('stars', 1 + (floor(random() * 5))::int)
        WHEN 'search' THEN jsonb_build_object(
                              'query', (ARRAY['scary woods','space survival','cozy mystery',
                                              'prairie comedy','true crime','nature documentary'])[1 + (floor(random() * 6))::int],
                              'results', (floor(random() * 12))::int)
    END                                                               AS details
FROM (
    SELECT (ARRAY['play','play','play','rate','search','pause'])[1 + (floor(random() * 6))::int] AS et
    FROM generate_series(1, 120)
) s;
