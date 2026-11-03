-- Load the 60-title catalogue provided by the instructor.
-- Run from the repo root:  psql ... -f sql/02_load_titles.sql
\copy titles(title_id, title, kind, release_year, genre, description) FROM 'data/ca3_titles.csv' WITH (FORMAT csv, HEADER true)
