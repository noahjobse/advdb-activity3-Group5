-- 24 synthetic users. Each preferences document holds an array (favourite_genres) plus a
-- varying-per-user subtitle language and parental-controls flag. Deterministic (seeded).
SELECT setseed(0.42);

INSERT INTO users (name, email, country, plan, preferences)
SELECT
    'User ' || g,
    'user' || g || '@example.com',
    (ARRAY['CA','US','UK','AU','IN','DE'])[1 + (g % 6)],
    (ARRAY['Free','Standard','Premium'])[1 + (g % 3)],
    jsonb_build_object(
        'favourite_genres', to_jsonb(ARRAY[
            (ARRAY['Drama','Sci-fi','Mystery','Comedy','Documentary','Thriller','Reality'])[1 + (g % 7)],
            (ARRAY['Drama','Sci-fi','Mystery','Comedy','Documentary','Thriller','Reality'])[1 + ((g + 3) % 7)]
        ]),
        'subtitle_language', (ARRAY['en','fr','es','de'])[1 + (g % 4)],
        'parental_controls', (g % 4 = 0)
    )
FROM generate_series(1, 24) AS g;
