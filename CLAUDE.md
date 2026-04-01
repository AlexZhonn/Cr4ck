# Cr4ck — CLAUDE.md

> **Always update this file when completing work items, discovering bugs, or making architectural decisions.**

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
  routers/run.py         POST /api/run — Docker-sandboxed code execution
  routers/ws.py          WS /ws — ConnectionManager, solve_event + leaderboard_update broadcasts
  migrations/       Raw SQL migration files (001–008; 007 backfills test cases for 288 challenges, 008 adds posts/post_votes)
```

---

## API Endpoints

| Method | Path                      | Description                                                                     |
| ------ | ------------------------- | ------------------------------------------------------------------------------- |
| GET    | /                         | Health check                                                                    |
| POST   | /auth/register            | Create account                                                                  |
| POST   | /auth/login               | Get tokens (accepts email or username)                                          |
| POST   | /auth/refresh             | Rotate refresh token                                                            |
| POST   | /auth/logout              | Revoke refresh token                                                            |
| GET    | /auth/me                  | Current user profile                                                            |
| GET    | /api/challenges           | All active challenges (public)                                                  |
| GET    | /api/challenges/:id       | Single challenge detail (public)                                                |
| POST   | /api/evaluate             | AI code evaluation (auth required)                                              |
| GET    | /api/leaderboard          | Top 50 users ranked by XP (public)                                              |
| GET    | /api/profile/completed    | Challenges the current user has attempted (auth required)                       |
| PUT    | /auth/api-key             | Save/update user's AI provider + encrypted API key (auth required)              |
| DELETE | /auth/api-key             | Remove stored API key (auth required)                                           |
| GET    | /auth/api-key/status      | Returns `{ has_key, provider, provider_label }` — never the key (auth required) |
| WS     | /ws                       | WebSocket — real-time solve events + leaderboard updates                        |
| GET    | /api/challenges/:id/posts | Paginated post list for a challenge (public, viewer's vote included if authed)  |
| POST   | /api/challenges/:id/posts | Create top-level post or reply (auth required)                                  |
| PUT    | /api/posts/:id            | Edit own post (auth required)                                                   |
| DELETE | /api/posts/:id            | Soft-delete own post (auth required)                                            |
| POST   | /api/posts/:id/vote       | Upvote (+1) / downvote (-1) / remove (0) a post (auth required)                 |

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

---

## Routes

| Path                     | Component              | Notes                                             |
| ------------------------ | ---------------------- | ------------------------------------------------- |
| `/`                      | LandingPageComponent   | Hero + CTA                                        |
| `/problems`              | ProblemSetComponent    | Topic hub                                         |
| `/problems/topic/:topic` | TopicProblemsComponent | Topic detail + difficulty filter                  |
| `/problems/:id`          | ProblemComponent       | Problem detail, shows loading/error states        |
| `/sandbox`               | SandboxComponent       | Auth-guarded; 401 mid-session redirects to /login |
| `/leaderboard`           | LeaderboardComponent   | Public, fetches /api/leaderboard                  |
| `/login`                 | LoginComponent         | GitHub OAuth button shows "coming soon" notice    |
| `/register`              | RegisterComponent      | GitHub OAuth button shows "coming soon" notice    |
| `/about`                 | AboutComponent         |                                                   |
| `/profile`               | ProfileComponent       |                                                   |

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

### ~~Completed~~ ✅

- Wire `/api/run` — Docker-sandboxed code execution (Python/Java/TypeScript/C++); stdin via file, local Python fallback
- Community post markdown rendering (`marked`); Edit/Delete buttons now owner-only via `isOwnPost()` username check
- Fix: `PostAuthor.id` changed from `number` to `string` (UUID) to match DB
- Test cases panel in sandbox (migrations 005–007, Tests tab in right panel)
- Community discussion per challenge (migration 008, posts/votes, Community tab)
- Sandbox sidebar filtering (topic + difficulty + language)
- Draggable panel resizing in sandbox (all 3 split points, localStorage persist)
- TopicProblems enhanced filtering (difficulty + language, colored dots)
- Challenge history in Profile (GET /api/profile/completed, history list with scores)
- Completed challenge badges in TopicProblems rows (checkmark + best score)
- BYOK AI provider keys (Anthropic/OpenAI/Google, AES-256-GCM, Profile settings card)
- Judge0 CE integration: `routers/run.py` now POSTs to `JUDGE0_URL` when set; Docker fallback retained for dev; `httpx` added to requirements.txt; `JUDGE0_URL` documented in `.env.example`
- Email verification via Postmark: migration 010 adds `verification_token` columns; `email_service.py` sends HTML email on register; `GET /auth/verify?token=` marks `is_verified=TRUE`; Angular `/verify-email` component handles the link click (loading/success/error states)
- Enforce `is_verified` at login: `/auth/login` returns 403 for unverified users; `POST /auth/resend-verification` re-sends the link; login UI shows resend button on that error
- Forgot password / reset: migration 011 adds `reset_token` columns; `POST /auth/forgot-password` sends Postmark link (1 hr TTL); `POST /auth/reset-password` verifies token + rehashes; Angular `/forgot-password` + `/reset-password` components
- Rate limiting via `slowapi`: register 10/hr, login 20/hr, resend/forgot 5/hr, evaluate 30/hr, run 60/hr — all per IP
- Community post ownership UI: `isOwnPost()` already wired to `auth.user().username`; Edit/Delete hidden for non-owners (was already done, confirmed)
- OpenAI + Google BYOK packages: `openai==1.75.0` + `google-generativeai==0.8.5` added to `requirements.txt`
- Sidebar filter state persistence: topic, difficulty, and search (`q`) persisted in URL query params; restored on init; cleared together
- Challenge keyword search: search input in sandbox sidebar filters by title + description client-side; synced to `?q=` URL param
- Challenges list pagination: `GET /api/challenges` now returns `{ items, total, page, limit, pages }`; frontend fetches with `?limit=200` to load all at once; `?page=` + `?limit=` available for future use
- Submission history: migration 012 adds `submissions` table + `last_code/last_score/last_language` to `user_challenges`; `routers/evaluate.py` inserts a row on every evaluation; `GET /api/challenges/:id/my-submissions` returns ordered history; "History" tab in sandbox bottom panel shows scores, timestamps, expandable code with "Load into editor" button
- Sandbox layout: description + editor side-by-side (top half), Tests/AI/Community/History tabs panel at bottom — all three split points draggable with localStorage persist
- Password change from profile: `PUT /auth/password` verifies current password with Argon2, rehashes new one; "Change Password" card in Profile settings with current/new/confirm fields

### 1. ~~Submission History with Code Storage~~ ✅ Done

### 2. Learning Paths / Challenge Sequences

The single biggest differentiator from LeetCode. Random challenge lists = challenge dump. Curated sequences = curriculum. A user who follows "SOLID Principles: Beginner → Intermediate → Advanced" learns 10× better than one who picks randomly.

- Migration: `paths` table (`id`, `title`, `description`, `topic`, `order`) + `path_challenges` join table (ordered)
- Endpoints: `GET /api/paths`, `GET /api/paths/:id` (returns ordered challenge list), `GET /api/paths/:id/progress` (auth — how many completed)
- Angular `/paths` route — grid of learning path cards; `/paths/:id` — sequential challenge list with progress bar
- Seed 5–10 paths from existing challenges (e.g. "SOLID Principles", "Design Patterns Fundamentals", "Concurrency Basics")

### 3. Public User Profiles `/profile/:username`

Currently `/profile` is auth-gated and self-only. Making profiles public creates social competition, shareable proof of skill, and organic word-of-mouth. A user sharing `cr4ck.dev/profile/alice` is a free marketing loop.

- `GET /api/users/:username/profile` — public endpoint returning XP, level, streak, challenges completed, topic breakdown, badges (no email)
- Angular `/profile/:username` route — shows public stats, topic radar/bar chart, recent activity, badge shelf
- Link to profile from leaderboard rows and community post author names

### 4. Badges / Achievements System

Streaks and XP alone aren't enough to drive daily habit formation. Badges are discrete, celebratory, and shareable — far more emotionally resonant than a number going up.

- Migration: `badges` table (`id`, `slug`, `label`, `description`, `icon`) + `user_badges` (`user_id`, `badge_id`, `earned_at`)
- Award logic in `routers/evaluate.py` after XP update: check and award badges like `first_solve`, `perfect_score`, `streak_7`, `streak_30`, `topic_master`, `century` (100 challenges)
- Badge shelf on profile page; badge pop-up notification in sandbox on first earn
- Seed 10–15 badges via migration

### 5. Daily Challenge (AI-Generated)

The single biggest driver of daily active users (DAU). A new challenge generated by Claude every 24 hours, shown on the landing page. Users who run out of motivation get a daily reason to return.

#### Architecture: Option A + C hybrid (recommended)

```text
Midnight UTC → GitHub Actions cron hits POST /api/admin/generate-daily
                         ↓
              Claude generates challenge JSON (validated, retried up to 3x)
                         ↓
              INSERT into challenges (is_ai_generated = TRUE)
              INSERT into daily_challenges (date, challenge_id)
              Write to Redis: daily:{date} TTL = seconds until next midnight
                         ↓
GET /api/daily → Redis hit  → instant return
              → Redis miss  → DB lookup → cache → return
              → DB miss     → on-demand generate (fallback)
```

#### DB changes (migration 012)

```sql
ALTER TABLE challenges
  ADD COLUMN is_ai_generated BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN generated_at    TIMESTAMPTZ;

CREATE TABLE daily_challenges (
  date         DATE PRIMARY KEY,
  challenge_id UUID NOT NULL REFERENCES challenges(id)
);
```

#### Backend (api/routers/daily.py)

- `GET /api/daily` — public; Redis-cached; returns full `ChallengeOut`
- `POST /api/admin/generate-daily` — protected by `X-Admin-Secret` header (env var `ADMIN_SECRET`); calls Claude with structured prompt; validates JSON schema; retries up to 3× on malformed output; inserts into DB + Redis

#### Prompt engineering — key rules

- Pass last 7 days' topics + difficulties to Claude so it avoids repetition
- Enforce a weekly rotation in the prompt: Mon=Easy design pattern, Tue=Medium SOLID, Wed=Hard concurrency, Thu=Easy creational, Fri=Medium structural, Sat=Hard behavioral, Sun=free pick
- Claude must return strict JSON matching the `challenges` table schema (title, description, topic, difficulty, starter_code object keyed by language, test_cases array)
- Validate all test_cases have `input`, `expected_output`, `description` keys before inserting
- If validation fails after 3 attempts, fall back to picking a random unshown challenge from the DB

#### GitHub Actions (.github/workflows/daily-challenge.yml)

```yaml
on:
  schedule:
    - cron: "0 0 * * *" # midnight UTC daily
  workflow_dispatch: # allow manual trigger

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger daily challenge generation
        run: |
          curl -X POST ${{ secrets.API_URL }}/api/admin/generate-daily \
            -H "X-Admin-Secret: ${{ secrets.ADMIN_SECRET }}" \
            --fail
```

Secrets needed in GitHub repo: `API_URL`, `ADMIN_SECRET`

#### Frontend changes

- `GET /api/daily` fetched in `LandingPageComponent` on init
- "Today's Challenge" card on landing page above the main CTA — shows title, topic, difficulty badge, "Solve it" button that deep-links to `/sandbox?challenge=:id`
- Badge on the challenge card in the sidebar if it matches today's daily (`isDaily()` signal)

### 6. Solution Showcase

After scoring ≥ 80, prompt users to opt-in to share their solution publicly. This creates a peer-learning corpus that makes Cr4ck's community more valuable the more people use it — a genuine network effect.

- Add `is_public BOOLEAN DEFAULT FALSE` + `public_code TEXT` columns to `user_challenges`
- `POST /api/challenges/:id/share` — authenticated, sets `is_public = TRUE`, stores code
- `GET /api/challenges/:id/top-solutions` — returns top public solutions sorted by score; code visible after user has attempted the challenge (prevents copying)
- Community tab in sandbox: "Top Solutions" section below posts

### ~~7. Password Change from Profile~~ ✅ Done

`PUT /auth/password` added to `routers/auth.py` — verifies current password with Argon2, rehashes new one. "Change Password" card in Profile page with current/new/confirm fields.

### 8. WebSocket Authentication

`/ws` currently accepts all connections with zero validation. In production this leaks usernames and challenge titles in `solve_event` broadcasts to any anonymous client who connects. Should be opt-in authenticated.

- Accept optional `?token=` query param on the WebSocket handshake; decode and validate the JWT
- Unauthenticated connections still receive `leaderboard_update` (public); `solve_event` only broadcasts to authenticated connections
- Frontend `WebSocketService`: append `?token=` when user is logged in

### 9. Admin Panel for Challenge Management

As the challenge count grows, managing them via SQL migrations becomes a bottleneck. An admin-only panel removes this friction for adding, editing, or deactivating challenges.

- Protected `/admin` route in Angular — only renders for users with `role = 'admin'`; Angular guard checks role from `auth.user()`
- Backend: `GET/POST /api/admin/challenges`, `PUT/DELETE /api/admin/challenges/:id` — gated by `role = 'admin'` dependency
- Simple form: title, description, topic, difficulty, language, starter code, is_active toggle
- Seeding new challenges no longer requires a migration

### 10. Production Docker Compose

Right now deploying Cr4ck requires manually starting FastAPI, PostgreSQL, Redis, and Judge0 separately. A production-ready `docker-compose.prod.yml` + Nginx config makes self-hosting a one-command operation.

- `docker-compose.prod.yml`: services for `api` (Dockerfile), `db` (postgres:16), `redis`, `nginx` (reverse proxy + SSL termination)
- `Dockerfile` for the FastAPI app
- `nginx.conf`: proxy `/api/*`, `/auth/*`, `/ws` → FastAPI; serve Angular build as static files
- `.env.prod.example` with production-specific variables (no `ALLOW_SERVER_KEY=true`, etc.)

### 11. GitHub OAuth

Backend flow not wired. Frontend shows "coming soon". Use Supabase Auth or custom OAuth flow.

---

## Annual Engineering Audit — Action Items (2026-03-22)

Ratings below are from the 2026 annual check. All items scored below 10/10. Ordered by severity within each category.

**Progress: 24 / 24 completed** (last updated 2026-03-23)

---

### Security (8/10)

#### ✅ AUDIT-S1: Authenticate WebSocket connections — gate `solve_event` to verified clients

**Done.** `ConnectionManager` now tracks authenticated vs. anonymous connections separately. WS endpoint accepts optional `?token=<access_jwt>`; validates JWT on connect. `solve_event` (contains PII) only goes to authenticated connections; `leaderboard_update` stays public. `WebSocketService` appends `?token=` when the user is logged in.

#### ✅ AUDIT-S2: Fix timing-attack exposure on verification and password-reset token lookups

**Done.** `verify_email` and `reset_password` now fetch the stored token column alongside the user row and compare using `secrets.compare_digest()`. A dummy token value is used when no row is found so the comparison always executes, preventing branch-timing leaks.

#### ✅ AUDIT-S3: Add rate-limit response headers so clients can back off gracefully

**Done.** `Limiter(headers_enabled=True)` in `main.py` — all rate-limited endpoints now return `X-RateLimit-Limit`, `X-RateLimit-Remaining`, and `X-RateLimit-Reset` headers.

#### ✅ AUDIT-S4: Enforce HTTPS-only cookies / add `Secure` flag guidance for production

**Done.** `api/.env.prod.example` created with explicit guidance: `ALLOWED_ORIGINS` must use `https://`, `FRONTEND_URL` must use `https://`, and `ALLOW_SERVER_KEY=false` is set. Nginx HTTPS redirect requirement documented inline.

---

### Testing (3/10)

#### ✅ AUDIT-T1: Add a backend test suite — zero tests currently exist

**Done.** `api/requirements-dev.txt` with pytest, pytest-asyncio, httpx, pytest-cov, anyio. `api/tests/` contains:

- `test_password.py` — 10 pure unit tests for Argon2id helpers (no DB)
- `test_auth.py` — 16 integration tests: register, login (email + username), wrong password, unverified, refresh, logout token revocation, `/me`
- `test_challenges.py` — 7 integration tests: paginated list, single fetch, 404
- `test_evaluate.py` — 2 integration tests: unauthenticated guard, authenticated path with mocked AI
- `conftest.py` — `db_required` skip marker, `verified_user` / `unverified_user` fixtures with DB teardown; avoids `pytest.skip()` inside FastAPI dependencies (raises `BaseException`, crashes ASGI middleware)

#### ✅ AUDIT-T2: Wire frontend tests — Vitest is installed but never executed

**Done.** 27 tests across 5 spec files, all passing:

- `auth.service.spec.ts` — 10 tests: isLoggedIn, login success/failure, logout, authHeaders, restore
- `challenges.service.spec.ts` — 6 tests: load, cache idempotency, byId, byTopic, error handling
- `auth.guard.spec.ts` — 2 tests: authenticated returns true, unauthenticated redirects to /login
- `login.spec.ts` — 8 tests: form state, submit, error display, showResend, isLoading lifecycle
- `app.spec.ts` — 1 smoke test (broken "should render title" test removed)

#### ✅ AUDIT-T3: Add end-to-end tests for the critical user journey

**Done.** `@playwright/test@^1.49.0` added to `devDependencies`. `ui/playwright.config.ts` configured for Chromium, `E2E_BASE_URL` env override, CI-mode retries. `ui/e2e/critical-journey.spec.ts` covers: landing page CTA, leaderboard public access, problems topic grid, sandbox redirect-to-login, registration validation, login error, forgot-password navigation, and authenticated flows (profile, sandbox loads, challenge selection, submit button visible). `ui/e2e/auth.setup.ts` handles test-user registration + verification bypass. Backend `POST /auth/test/verify-bypass` added (only active when `TEST_MODE=true`). E2e CI job added to `ci.yml` — runs after unit tests pass, uploads `playwright-report/` artifact on failure.

---

### CI/CD (7/10)

#### ✅ AUDIT-C1: Run tests in CI — neither frontend nor backend tests execute on PR

**Done.** `ci.yml` backend job now: installs `requirements-dev.txt`, runs DB migrations against a Postgres service container, then `pytest tests/ --cov --cov-fail-under=50`. Frontend job runs `npm run test:ci`. Both run on every PR and push to `main`.

#### ✅ AUDIT-C2: Build and validate the production Angular bundle in CI

**Done.** `npm run build -- --configuration production` runs in the CI frontend job. Angular's budget enforcement (500 kB warn / 1 MB error) automatically fails the build on bundle regressions.

#### ✅ AUDIT-C3: Add mypy static type checking for the backend

**Done.** `mypy==1.13.0` added to `requirements-dev.txt`. `mypy . --ignore-missing-imports` step added to CI backend job (`continue-on-error: true` while type coverage grows incrementally). `[tool.mypy]` config in `api/pyproject.toml`.

#### ✅ AUDIT-C4: Add SAST scanning (Semgrep or Bandit) to the security workflow

**Done.** `bandit -r . -ll --exclude ./venv,./tests` added to both CI backend job and `security.yml` weekly scan. Medium+ severity findings are reported; `continue-on-error: true` while existing findings are triaged.

---

### Observability (4/10)

#### ✅ AUDIT-O1: Add structured JSON request logging middleware to FastAPI

**Done.** `@app.middleware("http")` in `main.py` logs `request_id`, `method`, `path`, `status_code`, `duration_ms`, `user_id` (extracted from Bearer token) as a JSON line per request. `python-json-logger==2.0.7` added to `requirements.txt`; falls back to plain-text if package absent.

#### ✅ AUDIT-O2: Integrate Sentry for backend and frontend crash tracking

**Done.** `sentry-sdk[fastapi]==2.20.0` added to `requirements.txt`. `main.py` initializes Sentry when `SENTRY_DSN` env var is set; uses `before_send` to drop 401/403/404 noise; integrates `StarletteIntegration` + `FastApiIntegration`. Frontend: `@sentry/angular@^8` added to `package.json`; `app.config.ts` dynamically imports and inits Sentry when `__SENTRY_DSN__` build constant is set; `GlobalErrorHandler` forwards all unhandled errors to `Sentry.captureException`. `SENTRY_DSN` documented in `.env.example` and `.env.prod.example`.

#### ✅ AUDIT-O3: Add a proper health check endpoint that reports dependency status

**Done.** `GET /health` returns `{ "status": "ok"|"degraded", "db": "ok"|"error", "redis": "ok"|"disabled" }`. DB checked via `SELECT 1`; Redis checked via `PING`. Returns HTTP 200 when healthy, 503 when degraded.

#### ✅ AUDIT-O4: Track key business metrics (submissions, XP events, error rates)

**Done.** Structured `logger.info(...)` calls added to `routers/evaluate.py` and `routers/auth.py` (both already use `python-json-logger`). Events emitted:

- `evaluate.submitted` — per user, challenge, language, provider
- `evaluate.passed` / `evaluate.failed` — with score, xp_earned, is_first_completion, reason
- `auth.login.success` — with user_id, role
- `auth.login.failure` — with reason (invalid_credentials / account_disabled / email_not_verified)

---

### Code Quality (8/10)

#### ✅ AUDIT-Q1: Enforce Prettier formatting in CI

**Done.** `.prettierrc` already existed (100-char width, single quotes, Angular HTML parser). `"format:check": "prettier --check \"src/**/*.{ts,html,css}\""` added to `package.json`. Runs in CI frontend job on every PR.

#### ✅ AUDIT-Q2: Add ESLint with Angular-recommended rules

**Done.** `ng add @angular-eslint/schematics` auto-generated `eslint.config.js`. Stylistic rules (`prefer-inject`, `no-explicit-any`) set to warn; accessibility violations set to warn (tracked under AUDIT-F2). Zero errors, 97 warnings. `npm run lint` added to CI. `VerifyEmail` migrated from `*ngIf` to Angular 17+ `@if` control flow as part of fixing lint errors.

#### ✅ AUDIT-Q3: Add a `pyproject.toml` with explicit Ruff configuration

**Done.** `api/pyproject.toml` created with `[tool.ruff]` (line-length=100, select E/F/I/UP, target-version py311), `[tool.mypy]`, `[tool.pytest.ini_options]` (asyncio_mode=auto), and `[tool.coverage]` sections. Replaces the minimal `ruff.toml`.

---

### Infrastructure (5/10)

#### ✅ AUDIT-I1: Replace per-request DB connections with a connection pool

**Done.** `core/database.py` now uses `psycopg2.pool.ThreadedConnectionPool`. Pool initialized lazily on first request (min=2, max=20, env-configurable via `DB_POOL_MIN`/`DB_POOL_MAX`). `get_db()` acquires/releases from pool instead of open/close. `get_db_context()` updated identically.

#### ⬜ AUDIT-I2: Add automated database backup

There is no backup strategy documented or automated. A misconfigured migration or accidental `DELETE` without a `WHERE` clause would cause permanent data loss.

- If using Supabase: enable Point-in-Time Recovery (PITR) in the Supabase dashboard — this is one toggle
- If self-hosted: add a daily `pg_dump` cron job (GitHub Actions or system cron) that uploads to S3 / R2 with a 30-day retention policy
- Document the restore procedure in this file

#### ✅ AUDIT-I3: Write the production Docker Compose (already on roadmap as item 10)

**Done.** `api/Dockerfile` — multi-stage build (builder installs deps, runtime copies packages + source); non-root `appuser`; `HEALTHCHECK` via `/health` endpoint; `uvicorn` with 2 workers. `api/.dockerignore` excludes venv, `.env`, tests. `nginx.conf` — HTTP→HTTPS redirect, TLS config, proxies `/api/*`, `/auth/*`, `/ws` to FastAPI, serves Angular static build, Angular HTML5 routing fallback. `docker-compose.prod.yml` — services: `db` (postgres:16-alpine), `redis` (redis:7-alpine), `api` (built from `api/Dockerfile`), `nginx`; health-check-based `depends_on`; named volumes for DB + Redis data.

#### ✅ AUDIT-I4: Add query timeout and slow-query logging to the database layer

**Done.** `statement_timeout=5000` (5s hard limit) set via connection options in `core/database.py`. Any request that holds a DB connection longer than 500 ms emits a `WARNING` log line with the duration.

---

### API Design (8/10)

#### ⬜ AUDIT-A1: Add API versioning prefix (`/api/v1/`)

All endpoints are currently under `/api/` and `/auth/`. Any breaking change requires coordinating the frontend and backend simultaneously with no deprecation window.

- Prefix all routes with `/api/v1/` and `/auth/v1/` (or use a version header strategy)
- Keep the old unprefixed routes as aliases for one release cycle, then remove them
- Update the Angular proxy config and all `HttpClient` calls accordingly

#### ✅ AUDIT-A2: Standardize error response schema across all endpoints

**Done.** `main.py` now registers `@app.exception_handler(StarletteHTTPException)` and `@app.exception_handler(RequestValidationError)` — both convert to `{ "error": { "code": str, "message": str, "field": str|None } }`. `AuthService` updated with `extractErrorMessage()` helper that handles the new shape with graceful fallback to legacy `detail` shapes for any routers not yet migrated.

#### ✅ AUDIT-A3: Expose OpenAPI schema as a downloadable artifact in CI

**Done.** New `openapi` job in `ci.yml`: imports `main.app` in-process with stub env vars, calls `app.openapi()`, writes `api/openapi.json`, uploads as `openapi-schema` artifact (30-day retention). On PRs, a diff step attempts to compare against the base-branch artifact. Schema is available for download from any CI run without needing a running server.

---

### Frontend (7/10)

#### ✅ AUDIT-F1: Add a global Angular `ErrorHandler` and user-facing error boundary

**Done.** `ui/src/app/global-error-handler.ts` — `GlobalErrorHandler` implements Angular's `ErrorHandler`; runs outside Angular's zone; skips `ChunkLoadError` (lazy-route cache misses); shows a dismissible red toast banner (auto-removes after 8s) with `role="alert"` for screen readers; forwards to `Sentry.captureException()` when Sentry is loaded. Registered in `app.config.ts` as `{ provide: ErrorHandler, useClass: GlobalErrorHandler }`.

#### ✅ AUDIT-F2: Add accessibility baseline — run Lighthouse and fix critical violations

**Done.** Fixed all ESLint a11y violations across all 11 HTML templates: (1) All `<button>` tags now have explicit `type` attribute. (2) Non-button interactive elements converted to `<button>`: logo click in Header + Sandbox (was `<div>`/`<span>`), topic cards in ProblemSet (was `<div>`), challenge rows in TopicProblems and Profile history (was `<div>`). (3) `<span>` show/hide password toggles converted to `<button type="button" aria-label="...">` in Login, Register, and ResetPassword. (4) Vote buttons in sandbox Community tab given `aria-label="Upvote"/"Downvote"`. (5) ESLint a11y rules escalated from `warn` to `error` in `eslint.config.js` — CI will now block on new violations.

#### ✅ AUDIT-F3: Add bundle size tracking to CI to catch regressions

**Done.** `bundlesize@^0.18.2` + `webpack-bundle-analyzer@^4.10.2` added to `devDependencies`. `ui/.bundlesizerc.json` defines thresholds: main chunk ≤ 300 kB gzip, other chunks ≤ 400 kB gzip. `npx bundlesize --config .bundlesizerc.json` step added to CI frontend job after the production build (non-blocking with `continue-on-error: true` while Monaco lazy-loading reduces main-chunk size). `npm run analyze` script added for local bundle visualisation.

#### ✅ AUDIT-F4: Enable lazy loading for all routes except the landing page

**Done.** All routes in `app.routes.ts` converted to `loadComponent: () => import(...).then(m => m.ComponentName)` syntax. Monaco editor (loaded only on `/sandbox`) is now excluded from the initial bundle. Landing page remains as the first route but also lazy-loads. `canActivate: [authGuard]` preserved on `/sandbox`.

#### Sandbox to the right

now the sandbox is under description, which is counterintuitive and not accessible. Put the Description and Sandbox panels half-half of the right screen (we can still drag the edge to resize the panel). The Tests/Ai Evaluation/Community panel should remain at the bottom.

---

## Known Issues / Tech Debt

- **Challenges served from DB only**: `data/challenges.ts` holds type definitions and `TOPICS` metadata only. To add a challenge, write a migration SQL.
- **Challenge type `testCases` is optional**: `Challenge` interface has `testCases?` optional — actual test cases come from DB. Don't make it required.
- **Sandbox template visibility**: Services injected in `SandboxComponent` referenced in template must be `readonly` (not `private`). Angular templates cannot access private members.
- **Angular route matching**: `problems/topic/:topic` must appear before `problems/:id` in `app.routes.ts`.
- **Monaco assets**: `angular.json` copies `node_modules/monaco-editor/min/vs` → `assets/monaco/min/vs`. Restart dev server after any `angular.json` change.
- **Code execution not sandboxed**: `/api/run` is a stub. Do not exec user code without Docker sandboxing.
- **API_KEY_SECRET required**: `auth/apikey.py` will raise `RuntimeError` on startup if `API_KEY_SECRET` is not a 64-char hex string. Add to `.env`.
- **ALLOW_SERVER_KEY=true by default**: Dev fallback uses server's `ANTHROPIC_API_KEY`. Set `ALLOW_SERVER_KEY=false` in prod to force BYOK.
- **OpenAI + Google BYOK dispatch**: packages added to `requirements.txt`; provider-dispatch logic in `routers/evaluate.py` still routes everything through Anthropic — needs conditional branching for OpenAI/Google providers.
