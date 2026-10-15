## Quotes From Underground

Personal quote archive (Sinatra + Sequel + Postgres). Dark theme only.

#### TODO

**access**

 * ~~open public signup~~ — `/user/new` shows closed message; site requires login
 * usage tracking / quotas if the site stays reachable anonymously (anti-bot)

**features**

 * quote links — wire `quote_links` table + UI (related quotes; e.g. link qid 1218 ↔ 209)
 * daily metrics + simple dashboard
 * Telegram (or similar) error reporting

**ops / hosting**

 * migrate off Heroku → self-hosted on your server (Postgres, Puma, reverse proxy, deploy story)
 * document env vars and production runbook (`.env.sample` is the start)

**schema (optional)**

 * `created_at` / `updated_at` on models — only meaningful going forward, not historical truth

#### Won’t do / done

 * ~~UUID for publications & quotes~~ — integer `uid` / `publication_uid` is fine
 * ~~gateways / use cases / ServiceFactory~~ — v2 Sequel models + `lib/queries/`
 * ~~integration / e2e test suite~~ — current unit + import specs are enough for now
 * ~~dark/light mode toggle~~ — dark only
 * ~~public FAQ~~ — not needed for a private site
 * ~~move `app/` to repo root~~ — done (`server.rb`, `views/`, `public/`, `helpers/`)

#### v2 refactor (done)

 * `migrations/` at repo root; PG sequences for new quote/publication ids
 * `quote_tags` + `content_tsv` search; normalized `\n` in quote content
 * Kindle import via `KindleImport`; users PK is UUID

#### Database

```bash
rake db:migrate
ruby scripts/import_from_json.rb --migrate --truncate   # empty DB + prod JSON
```

After schema changes on an existing DB: `rake db:migrate` (backfills in migrations) or re-import.
