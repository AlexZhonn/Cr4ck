# Cr4ck — CLAUDE.md

> **Always update this file when completing work items, discovering bugs, or making architectural decisions.**
> Completed work is logged in [CHANGELOG.md](CHANGELOG.md).

## On Completing Any Work Item

When you finish a feature, fix, or infrastructure change, you **must** do all of the following before committing:

1. **Update [README.md](README.md)** — reflect any new endpoints in the API Reference table, new env vars in the Environment Variables table, new migrations in the Database Migrations table, new routes in any relevant section, and remove items from Known Issues / Roadmap if they are now done.
2. **Update [CHANGELOG.md](CHANGELOG.md)** — add an entry under the appropriate category (Features, Bug Fixes, Audit Items, etc.) describing what was done.
3. **Update this file (CLAUDE.md)** — mark the item done in What's Next, move any completed audit items out, and update Known Issues / Tech Debt if relevant.
4. **Update or add tests** — every backend change needs a corresponding test in `api/tests/`; every frontend service or component change needs a spec update in `ui/src/app/**/*.spec.ts`. If a new endpoint is added, add at minimum an unauthenticated guard test and a happy-path integration test.

## Project Overview

**Cr4ck** is an AI-powered coding challenge platform focused on Object-Oriented Programming (OOP) and System Design. Users write code in a browser-based Monaco Editor and receive instant AI architectural feedback.

**Stack:**

- Frontend: Angular 21 + Tailwind CSS 4 + Monaco Editor (port 4200 dev)
- Backend: FastAPI + PostgreSQL (Supabase) (port 8000 dev)
- Auth: JWT (access 15min / refresh 30d) + Argon2id password hashing
- AI: Claude API for code evaluation via `/api/evaluate` (ANTHROPIC_API_KEY in `api/.env`)
- Cache: Redis (optional) — challenges cached 5 min, leaderboard 60 s; silently disabled if Redis unavailable
- Realtime: WebSocket at `ws://host/ws` — broadcasts `solve_event` + `leaderboard_update` on XP award

---

## Dev Setup

### Backend

```bash
cd api
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

Requires `.env` in `api/`:

```env
DATABASE_URL=postgresql://...
SECRET_KEY=...
ALLOWED_ORIGINS=http://localhost:4200
ANTHROPIC_API_KEY=...
REDIS_URL=redis://localhost:6379/0   # optional
```

### Frontend

```bash
cd ui
npm install
ng serve   # runs on http://localhost:4200
```

Angular proxies `/auth/*`, `/api/*`, and `/ws` → `http://localhost:8000` via `proxy.conf.json` (WebSocket proxy uses `"ws": true`).

> **Monaco Editor**: `angular.json` copies `node_modules/monaco-editor/min/vs` → `assets/monaco/min/vs` at build time. `ngx-monaco-editor-v2` loads from that path by default. If the editor is read-only/non-interactive, check that the dev server was restarted after `angular.json` changes.

---

## Architecture

```text
ui/src/app/
  LandingPage/      Hero + CTA
  Header/           Nav (logo, links, auth state)
  ProblemSet/       Topic hub — 2-col grid of topic cards → /problems/topic/:topic
  TopicProblems/    Topic detail page — filtered challenge list with difficulty tabs
  Problem/          Individual problem detail (description + starter code + CTA)
  sandbox/          Main IDE: sidebar + Monaco + AI feedback pane
  Login/            JWT login form
  Register/         Registration form
  Paths/            Learning path grid — /paths
  PathDetail/       Sequential challenge list + progress bar — /paths/:slug
  Profile/          User stats: XP, level, streak, challenges completed
  About/            Static about page
  data/challenges   Challenge[] + Topic type + TOPICS metadata (icons, labels, descriptions)
  services/         AuthService (JWT lifecycle), ChallengesService (fetch + cache), WebSocketService (live events)
  guards/           authGuard (CanActivateFn, protects /sandbox)

api/
  main.py           FastAPI entry, CORS, router mounting, Redis startup probe
  core/config.py    Env vars, JWT config, CORS origins
  core/database.py  psycopg2 connection pool
  core/redis.py     Redis client + cache_get/cache_set/cache_delete helpers (REDIS_URL)
  auth/             tokens.py, password.py, dependencies.py
  models/user.py    Pydantic schemas + enums
  routers/auth.py   /auth/* endpoints
  routers/challenges.py  GET /api/challenges, GET /api/challenges/:id (Redis-cached)
  routers/evaluate.py    POST /api/evaluate — Claude API, XP award, streak, WS broadcast
  routers/leaderboard.py GET /api/leaderboard (Redis-cached, cache-busted on XP award)
  routers/paths.py       GET /api/paths, /paths/:slug, /paths/:slug/progress (learning paths)
  routers/run.py         POST /api/run — Docker-sandboxed code execution
  routers/ws.py          WS /ws — ConnectionManager, solve_event + leaderboard_update broadcasts
  migrations/       Raw SQL migration files (001–012)
```

---

## API Endpoints

| Method | Path                             | Description                                                                     |
| ------ | -------------------------------- | ------------------------------------------------------------------------------- |
| GET    | /health                          | Health check — reports DB + Redis status                                        |
| POST   | /auth/v1/register                | Create account                                                                  |
| POST   | /auth/v1/login                   | Get tokens (accepts email or username)                                          |
| POST   | /auth/v1/refresh                 | Rotate refresh token                                                            |
| POST   | /auth/v1/logout                  | Revoke refresh token                                                            |
| GET    | /auth/v1/verify                  | Verify email via token                                                          |
| POST   | /auth/v1/resend-verification     | Resend verification email                                                       |
| POST   | /auth/v1/forgot-password         | Send password reset link                                                        |
| POST   | /auth/v1/reset-password          | Reset password via token                                                        |
| PUT    | /auth/v1/password                | Change password (auth required)                                                 |
| GET    | /auth/v1/me                      | Current user profile                                                            |
| PUT    | /auth/v1/api-key                 | Save/update user's AI provider + encrypted API key (auth required)              |
| DELETE | /auth/v1/api-key                 | Remove stored API key (auth required)                                           |
| GET    | /auth/v1/api-key/status          | Returns `{ has_key, provider, provider_label }` — never the key (auth required) |
| GET    | /api/v1/challenges               | All active challenges, paginated (public)                                       |
| GET    | /api/v1/challenges/:id           | Single challenge detail (public)                                                |
| GET    | /api/v1/challenges/:id/my-submissions | Submission history for current user (auth required)                        |
| POST   | /api/v1/evaluate                 | AI code evaluation (auth required)                                              |
| GET    | /api/v1/leaderboard              | Top 50 users ranked by XP (public)                                              |
| GET    | /api/v1/profile/completed        | Challenges the current user has attempted (auth required)                       |
| POST   | /api/v1/run                      | Run code against test cases (auth required)                                     |
| GET    | /api/v1/daily                    | Today's daily challenge (public, Redis-cached until midnight UTC)               |
| POST   | /api/admin/generate-daily        | Generate today's challenge via Claude (X-Admin-Secret required)                 |
| GET    | /api/v1/paths                    | All learning paths with challenge counts + difficulty tags (public)             |
| GET    | /api/v1/paths/:slug              | Path detail with ordered challenges (public)                                    |
| GET    | /api/v1/paths/:slug/progress     | Per-challenge completion status for current user (auth required)                |
| GET    | /api/v1/challenges/:id/posts     | Paginated post list for a challenge (public)                                    |
| POST   | /api/v1/challenges/:id/posts     | Create top-level post or reply (auth required)                                  |
| PUT    | /api/v1/posts/:id                | Edit own post (auth required)                                                   |
| DELETE | /api/v1/posts/:id                | Soft-delete own post (auth required)                                            |
| POST   | /api/v1/posts/:id/vote           | Upvote (+1) / downvote (-1) / remove (0) a post (auth required)                 |
| WS     | /ws                              | WebSocket — real-time solve events + leaderboard updates                        |

---

## Key Decisions

- Argon2id with per-user salt + server-side pepper (not stored in DB)
- Refresh tokens stored in DB with JTI for per-token revocation
- Angular standalone components (no NgModules)
- Tailwind v4 (CSS-first config, no tailwind.config.js)
- Monaco editor for in-browser code editing across Java, Python, TypeScript, C++
- Challenges served from DB (300 seeded via migrations 001–004b); `data/challenges.ts` only holds type definitions and TOPICS UI metadata
- FastAPI 422 validation errors return `detail` as an array — `AuthService` flattens these to readable strings
- Login accepts email OR username — `LoginRequest.email` is plain `str`, query does `WHERE email = %s OR username = %s`
- All routes versioned under `/api/v1/` and `/auth/v1/`; unversioned aliases kept for one deprecation cycle

---

## Routes

| Path                     | Component              | Notes                                             |
| ------------------------ | ---------------------- | ------------------------------------------------- |
| `/`                      | LandingPageComponent   | Hero + CTA                                        |
| `/problems`              | ProblemSetComponent    | Topic hub                                         |
| `/problems/topic/:topic` | TopicProblemsComponent | Topic detail + difficulty filter                  |
| `/problems/:id`          | ProblemComponent       | Problem detail, shows loading/error states        |
| `/sandbox`               | SandboxComponent       | Auth-guarded; 401 mid-session redirects to /login |
| `/paths`                 | PathsComponent         | Public; grid of all learning path cards           |
| `/paths/:slug`           | PathDetailComponent    | Public; sequential challenge list + progress bar  |
| `/leaderboard`           | LeaderboardComponent   | Public, fetches /api/leaderboard                  |
| `/login`                 | LoginComponent         | GitHub OAuth button shows "coming soon" notice    |
| `/register`              | RegisterComponent      | GitHub OAuth button shows "coming soon" notice    |
| `/about`                 | AboutComponent         |                                                   |
| `/profile`               | ProfileComponent       |                                                   |
| `/verify-email`          | VerifyEmailComponent   |                                                   |
| `/forgot-password`       | ForgotPasswordComponent|                                                   |
| `/reset-password`        | ResetPasswordComponent |                                                   |

> **Route order matters:** `problems/topic/:topic` must appear before `problems/:id` in `app.routes.ts` or Angular will match "topic" as a problem ID.

---

## Dev Convenience

```bash
make install    # install all frontend + backend deps
make dev        # run API (port 8000) + UI (port 4200) in parallel
make dev-api    # API only
make dev-ui     # UI only
make check      # tsc --noEmit + Python import check
```

---

## Pre-Commit CI Mirror (run before every commit)

**Always run these commands after completing a task and before committing.** They mirror the GitHub Actions pipeline exactly so failures are caught locally.

### Backend (from `api/`, with venv activated)

```bash
python -m ruff check .
mypy . --ignore-missing-imports
bandit -r . -ll --exclude ./venv,./tests -q
python -c "import main"
```

### Frontend (from `ui/`)

```bash
npx tsc --noEmit
npm run format:check
npm run lint
npm run test:ci
npm run build -- --configuration production
```

> If `format:check` fails, run `npx prettier --write "src/**/*.{ts,html,css}"` to auto-fix, then re-check.
> Backend tests (`pytest`) require a running Postgres — skip locally if no DB available, but CI will catch them.

---

## What's Next (Priority Order)

### 1. ✅ Learning Paths / Challenge Sequences — DONE (migration 016)

- **Migration 016** — `paths` table + `path_challenges` join table (step_order)
- **8 curated paths seeded**: OOP Foundations (9 Easy), OOP in Practice (9 Medium), Advanced OOP Systems (8 Hard), Creational Patterns (10), Structural Patterns (10), Behavioral Patterns (12), System Design Foundations (9), Distributed Systems Deep Dive (8)
- **`GET /api/v1/paths`** (public), **`GET /api/v1/paths/:slug`** (public), **`GET /api/v1/paths/:slug/progress`** (auth)
- **Angular `/paths`** — `PathsComponent` 2-column grid of path cards with topic badge + difficulty tags
- **Angular `/paths/:slug`** — `PathDetailComponent` sequential challenge list, step indicators, best-score badges, progress bar

#### ✅ Improvement: Path-scoped sandbox sidebar — DONE

- `PathDetailComponent.openChallenge()` passes `?challenge=:id&path=:slug` to `/sandbox`
- `SandboxComponent` reads `path` query param on `ngOnInit`; fetches `/api/v1/paths/:slug` and stores `pathSlug`, `pathTitle`, `pathChallengeIds` signals
- `challenges` computed returns path-ordered subset (no filters) when `pathChallengeIds` is non-empty
- Sidebar shows path title + "Exit path" chevron link in path mode; search/topic/difficulty filters are hidden
- `exitPath()` clears path signals and navigates back to `/paths/:slug`
- `_syncParams` preserves the `path` query param so page refresh stays in path mode

### 2. ✅ Sandbox Problem Description — Markdown Rendering — DONE

- Replaced raw `{{ activeChallenge.description }}` with `[innerHTML]="renderMarkdown(activeChallenge.description)"` in `sandbox.html:245`
- Added `.prose-desc` CSS class in `sandbox.css` — scoped styles for headings (h1/h2/h3), paragraphs, bold/em, inline code, fenced code blocks, blockquotes, lists, links, and hr
- Reused existing `renderMarkdown()` (marked.parse) — no new TS logic needed
- Added `ViewEncapsulation.None` to `SandboxComponent` so `sandbox.css` rules reach `[innerHTML]`-injected nodes (Tailwind Preflight + Angular's emulated encapsulation both blocked component-scoped styles from applying to dynamically injected DOM)

### 3. Public User Profiles `/profile/:username`

Currently `/profile` is auth-gated and self-only. Making profiles public creates social competition and organic word-of-mouth.

- `GET /api/v1/users/:username/profile` — public endpoint returning XP, level, streak, challenges completed, topic breakdown, badges (no email)
- Angular `/profile/:username` route — public stats, topic radar/bar chart, recent activity, badge shelf
- Link to profile from leaderboard rows and community post author names

### 3. ✅ Badges / Achievements System — DONE (migration 015)

- `badges` catalog + `user_badges` join table (migration 015); 15 badges seeded
- Award logic in `routers/evaluate.py` — `_check_and_award_badges()` after every XP update
- `GET /api/v1/badges` (public catalog), `GET /api/v1/badges/me` (auth required)
- `/auth/v1/me` returns `badges: UserBadgeOut[]`
- WebSocket `badge_earned` event broadcast to authenticated clients
- Profile badge shelf (emoji grid); sandbox slide-up toast on first earn

### 4. ✅ Daily Challenge (AI-Generated) — DONE (migration 014)

A new challenge generated by Claude every 24 hours, shown on the landing page. The single biggest driver of DAU.

#### Architecture

```text
Midnight UTC → GitHub Actions cron hits POST /api/admin/generate-daily
                         ↓
              Claude generates challenge JSON (validated, retried up to 3x)
                         ↓
              INSERT into challenges (is_ai_generated = TRUE)
              INSERT into daily_challenges (date, challenge_id)
              Write to Redis: daily:{date} TTL = seconds until next midnight
```

#### DB (migration 013)

```sql
ALTER TABLE challenges
  ADD COLUMN is_ai_generated BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN generated_at    TIMESTAMPTZ;

CREATE TABLE daily_challenges (
  date         DATE PRIMARY KEY,
  challenge_id UUID NOT NULL REFERENCES challenges(id)
);
```

#### Backend (`api/routers/daily.py`)

- `GET /api/v1/daily` — public; Redis-cached; returns full `ChallengeOut`
- `POST /api/admin/generate-daily` — protected by `X-Admin-Secret` header (`ADMIN_SECRET` env); retries up to 3× on malformed output; falls back to random unshown challenge

#### Prompt rules

- Pass last 7 days' topics + difficulties to avoid repetition
- Weekly rotation: Mon=Easy design pattern, Tue=Medium SOLID, Wed=Hard concurrency, Thu=Easy creational, Fri=Medium structural, Sat=Hard behavioral, Sun=free pick
- Return strict JSON matching challenges schema; validate all test_cases before inserting

#### GitHub Actions (`.github/workflows/daily-challenge.yml`)

```yaml
on:
  schedule:
    - cron: "0 0 * * *"
  workflow_dispatch:
jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger daily challenge generation
        run: |
          curl -X POST ${{ secrets.API_URL }}/api/admin/generate-daily \
            -H "X-Admin-Secret: ${{ secrets.ADMIN_SECRET }}" --fail
```

#### Frontend

- "Today's Challenge" card on landing page — title, topic, difficulty badge, "Solve it" deep-link to `/sandbox?challenge=:id`
- `isDaily()` signal badges matching challenge in sidebar

### 5. Solution Showcase

After scoring ≥ 80, prompt users to opt-in to share their solution publicly.

- Add `is_public BOOLEAN DEFAULT FALSE` + `public_code TEXT` to `user_challenges`
- `POST /api/v1/challenges/:id/share` — sets `is_public = TRUE`, stores code
- `GET /api/v1/challenges/:id/top-solutions` — top public solutions sorted by score; visible only after user has attempted the challenge
- Community tab in sandbox: "Top Solutions" section below posts

### 6. Admin Panel for Challenge Management

As challenge count grows, managing via SQL migrations becomes a bottleneck.

- Protected `/admin` route in Angular — only renders for `role = 'admin'`
- Backend: `GET/POST /api/admin/challenges`, `PUT/DELETE /api/admin/challenges/:id` — gated by `role = 'admin'` dependency
- Simple form: title, description, topic, difficulty, language, starter code, is_active toggle

### 7. GitHub OAuth

Backend flow not wired. Frontend shows "coming soon". Use Supabase Auth or custom OAuth flow.

### 8. ✅ Multi-Language Support per Challenge — DONE (migration 013)

`starter_codes` JSONB column added. `ChallengeOut` returns it; frontend sandbox has a language dropdown. Harness generation script (`api/scripts/generate_harnesses.py`) populates additional language variants via migration 013b.

---

## Incomplete Audit Items

### ⬜ AUDIT-I2: Add automated database backup

No backup strategy exists. A bad migration or accidental `DELETE` without `WHERE` causes permanent data loss.

- Supabase: enable Point-in-Time Recovery (PITR) in the dashboard
- Self-hosted: daily `pg_dump` cron (GitHub Actions or system cron) uploading to S3/R2 with 30-day retention
- Document the restore procedure here once implemented

---

## Known Issues / Tech Debt

- **Challenges served from DB only**: `data/challenges.ts` holds type definitions and `TOPICS` metadata only. To add a challenge, write a migration SQL.
- **Challenge type `testCases` is optional**: `Challenge` interface has `testCases?` optional — actual test cases come from DB. Don't make it required.
- **Sandbox template visibility**: Services injected in `SandboxComponent` referenced in template must be `readonly` (not `private`). Angular templates cannot access private members.
- **Angular route matching**: `problems/topic/:topic` must appear before `problems/:id` in `app.routes.ts`.
- **Monaco assets**: `angular.json` copies `node_modules/monaco-editor/min/vs` → `assets/monaco/min/vs`. Restart dev server after any `angular.json` change.
- **API_KEY_SECRET required**: `auth/apikey.py` will raise `RuntimeError` on startup if `API_KEY_SECRET` is not a 64-char hex string. Add to `.env`.
- **ALLOW_SERVER_KEY=true by default**: Dev fallback uses server's `ANTHROPIC_API_KEY`. Set `ALLOW_SERVER_KEY=false` in prod to force BYOK.
- **ADMIN_SECRET required for daily generation**: `POST /api/admin/generate-daily` returns 503 if `ADMIN_SECRET` env var is not set. Add to `.env` in prod.
- **Daily challenge not auto-generated in dev**: The GitHub Actions cron only runs against the deployed API. Trigger manually: `curl -X POST http://localhost:8000/api/admin/generate-daily -H "X-Admin-Secret: $ADMIN_SECRET" -H "Content-Type: application/json" -d '{}'`
- **OpenAI + Google BYOK dispatch**: packages added to `requirements.txt`; provider-dispatch logic in `routers/evaluate.py` still routes everything through Anthropic — needs conditional branching for OpenAI/Google providers.
- **Test harness required for Run Tests to work**: `POST /api/v1/run` concatenates `test_harness` from DB with user code before execution. Challenges with `test_harness IS NULL` fall back to raw user code (old behaviour — tests will fail). Run `api/scripts/generate_harnesses.py` and apply `013b_harness_data.sql` to populate harnesses for all 300 challenges.
- **Harness conflicts stripped per language**: Java `public` stripped from user type declarations; C++ `int main()` stripped; Python `if __name__ == '__main__':` stripped. TypeScript harness must use `readline close` handler. See `routers/run.py` helpers.
- **[HIGH] `generate_starter_codes.py` exposes unexecutable languages**: The backfill script (`api/scripts/generate_starter_codes.py:327-354`) populates `starter_codes` for all 4 languages, but `test_harness` is still a single-language blob. The sandbox surfaces every `starter_codes` key as a selectable language and sends it to `/api/v1/run`, which concatenates the original-language harness against wrong-language user code. Do not apply the generated SQL migration until `/api/v1/run` and harness storage are keyed per language, or restrict the backfill to the native language only.
- **[HIGH] `generate_starter_codes.py` accepts raw Gemini output without validation**: At lines 174-187, any non-empty `response.text` is written into the migration after only stripping fences when the response starts with ` ``` `. Leading prose, trailing notes, wrong-language output, or syntactically invalid code all pass through. Add structured output enforcement or robust fenced-code extraction, then compile/smoke-test each snippet before writing an `UPDATE`.
- **[HIGH] 96 challenges have placeholder descriptions**: `004_backfill_challenges.sql` contains 96 entries with the generic description `"Design an object‑oriented system modeling scenario #N. Focus on encapsulation, inheritance, and polymorphism."` These show verbatim in the sandbox description panel now that markdown rendering is live. Need a backfill script (similar to `generate_starter_codes.py`) that calls Claude to generate proper descriptions — with **Requirements** and **Constraints** sections — for each affected challenge and produces a migration SQL. Affected challenges are all in `004_backfill_challenges.sql`; grep for `"modeling scenario"` to find all 96.
- **[MEDIUM] `generate_starter_codes.py` emits full-blob JSONB overwrites**: `write_sql` (lines 216-228) emits `SET starter_codes = ...::jsonb` for the entire JSON object. Because the script supports long-running resumable generation (`--offset`, `--append`), any manual fix or newer variant added after the snapshot is taken will be silently replaced when the SQL is applied. Change to a merge-style update: `starter_codes = COALESCE(starter_codes, '{}'::jsonb) || $new_blob::jsonb`, or add a guard that aborts if the live row no longer matches the snapshot.
