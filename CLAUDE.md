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
```
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

```
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

| Method | Path | Description |
|--------|------|-------------|
| GET | / | Health check |
| POST | /auth/register | Create account |
| POST | /auth/login | Get tokens (accepts email or username) |
| POST | /auth/refresh | Rotate refresh token |
| POST | /auth/logout | Revoke refresh token |
| GET | /auth/me | Current user profile |
| GET | /api/challenges | All active challenges (public) |
| GET | /api/challenges/:id | Single challenge detail (public) |
| POST | /api/evaluate | AI code evaluation (auth required) |
| GET | /api/leaderboard | Top 50 users ranked by XP (public) |
| GET | /api/profile/completed | Challenges the current user has attempted (auth required) |
| PUT | /auth/api-key | Save/update user's AI provider + encrypted API key (auth required) |
| DELETE | /auth/api-key | Remove stored API key (auth required) |
| GET | /auth/api-key/status | Returns `{ has_key, provider, provider_label }` — never the key (auth required) |
| WS | /ws | WebSocket — real-time solve events + leaderboard updates |
| GET | /api/challenges/:id/posts | Paginated post list for a challenge (public, viewer's vote included if authed) |
| POST | /api/challenges/:id/posts | Create top-level post or reply (auth required) |
| PUT | /api/posts/:id | Edit own post (auth required) |
| DELETE | /api/posts/:id | Soft-delete own post (auth required) |
| POST | /api/posts/:id/vote | Upvote (+1) / downvote (-1) / remove (0) a post (auth required) |

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

| Path | Component | Notes |
|------|-----------|-------|
| `/` | LandingPageComponent | Hero + CTA |
| `/problems` | ProblemSetComponent | Topic hub |
| `/problems/topic/:topic` | TopicProblemsComponent | Topic detail + difficulty filter |
| `/problems/:id` | ProblemComponent | Problem detail, shows loading/error states |
| `/sandbox` | SandboxComponent | Auth-guarded; 401 mid-session redirects to /login |
| `/leaderboard` | LeaderboardComponent | Public, fetches /api/leaderboard |
| `/login` | LoginComponent | GitHub OAuth button shows "coming soon" notice |
| `/register` | RegisterComponent | GitHub OAuth button shows "coming soon" notice |
| `/about` | AboutComponent | |
| `/profile` | ProfileComponent | |

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

### 1. Submission History with Code Storage

The biggest missing learning feature. `user_challenges` tracks `best_score + attempts` but never stores the actual code submitted. Users can't review past work, see how they improved, or learn from their own mistakes.

- Add `last_code TEXT` + `last_score INT` columns to `user_challenges` (migration 012); update `routers/evaluate.py` to persist the submitted code on every evaluation
- New endpoint: `GET /api/challenges/:id/my-submissions` — returns ordered attempt history (score, code, submitted_at)
- Sandbox UI: "My Submissions" tab or sub-panel in the right panel, showing past attempts with diffs or re-loadable code

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
    - cron: '0 0 * * *'   # midnight UTC daily
  workflow_dispatch:        # allow manual trigger

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

### 7. Password Change from Profile

Basic UX expectation. Currently a user who wants to change their password must go through the forgot-password email flow, which is clunky and confusing.

- `PUT /auth/password` — requires `{ current_password, new_password }`; verifies current password with Argon2, rehashes new one
- Profile settings card with a "Change password" form (current + new + confirm)

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
