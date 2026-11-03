# Schema diagram

Renders on GitHub. For the submission, export this as a PDF/image (GitHub's rendered view,
mermaid.live, or redraw in draw.io). **JSONB** columns: `users.preferences`, `activity_log.details`.
**Vector** column: `titles.embedding` (added by the vector half).

```mermaid
erDiagram
    users ||--o{ activity_log : logs
    titles ||--o{ activity_log : about

    users {
        bigint user_id PK
        text   name
        text   email
        text   country
        text   plan
        jsonb  preferences "JSONB — favourite_genres[], subtitle_language, parental_controls"
    }
    titles {
        bigint title_id PK
        text   title
        text   kind
        int    release_year
        text   genre
        text   description
        vector embedding "VECTOR — declared here, filled by the vector half"
    }
    activity_log {
        bigint      event_id PK
        bigint      user_id FK
        bigint      title_id FK
        text        event_type
        timestamptz occurred_at
        jsonb       details "JSONB — varies by event_type"
    }
    search_phrases {
        bigint id PK
        text   phrase
        vector embedding "VECTOR — vector half"
    }
```

## Example JSON documents

`users.preferences`:
```json
{ "favourite_genres": ["Mystery", "Thriller"], "subtitle_language": "es", "parental_controls": false }
```

`activity_log.details` (shape varies by `event_type`):
```json
{ "minutes_watched": 72, "device": "tv" }      // play
{ "stars": 4 }                                  // rate
{ "query": "scary woods", "results": 5 }        // search
{ "at_minute": 18 }                             // pause
```
