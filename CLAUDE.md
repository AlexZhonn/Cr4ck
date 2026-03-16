# Cr4ck — CLAUDE.md

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
  migrations/       Raw SQL migration files (001–006; 006 backfills test cases for 12 challenges)
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
| WS | /ws | WebSocket — real-time solve events + leaderboard updates |

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

### 1. Test Cases Panel in Sandbox
Add a third pane to the sandbox IDE (alongside the editor and AI feedback) that runs deterministic test cases against the user's code. AI feedback is a qualitative layer on top — test cases are the ground truth pass/fail signal.

**Design:**
- Each challenge in the DB gets a `test_cases` JSONB column: array of `{ input, expected_output, description }` objects
- New endpoint `POST /api/run` — executes user code in a sandboxed subprocess (Docker or e2 subprocess with timeout), captures stdout, compares against expected
- Sandbox UI: tabbed panel — "Tests" tab next to "AI Feedback", shows each test case with pass/fail status and actual vs expected output
- Languages need a runner per language: Java (compile + run), Python (run), TypeScript (ts-node), C++ (compile + run)
- Code execution must be sandboxed — no network, limited CPU/memory, hard timeout (5s). Use Docker with `--network none --memory 128m --cpus 0.5` or a cloud sandbox (e.g. Judge0 API)
- XP logic: test pass rate feeds into score alongside AI feedback; full pass = bonus XP

**DB migration needed:** `ALTER TABLE challenges ADD COLUMN test_cases JSONB DEFAULT '[]'`

### 2. Community Discussion per Challenge
Each challenge gets a threaded discussion board — users share approaches, ask questions, make friends. This is the social layer that makes Cr4ck sticky beyond just solving problems.

**Design:**
- New `posts` table: `id, challenge_id (FK), user_id (FK), parent_id (nullable FK → posts for threading), body TEXT, created_at, updated_at, is_deleted`
- New `post_votes` table: `user_id, post_id, value (+1/-1)` — simple upvote/downvote
- Endpoints:
  - `GET /api/challenges/:id/posts` — paginated, sorted by votes or recency
  - `POST /api/challenges/:id/posts` — create post/reply (auth required)
  - `PUT /api/posts/:id` — edit own post (auth required)
  - `DELETE /api/posts/:id` — soft delete own post (auth required)
  - `POST /api/posts/:id/vote` — upvote/downvote (auth required)
- UI: Community tab in the sandbox panel (next to Tests and AI Feedback), or a dedicated `/problems/:id/discuss` route
- Show username, XP level badge, and timestamp per post
- Threading: top-level posts + one level of replies (Reddit-style is enough to start)
- Markdown rendering for post bodies (use a lightweight lib like `marked`)

### 3. Sandbox Sidebar Filtering
300 challenges is too many to scroll. Add topic + difficulty filter controls above the sidebar challenge list. Already have the data — just needs UI.

### 4. Email Verification
`is_verified` column exists in DB but is always `false`. Need SMTP or Resend integration to send a verification link on register.

### 5. GitHub OAuth
Backend flow not wired. Frontend already shows "coming soon" notice on click. Can use Supabase Auth or a custom OAuth flow with GitHub App credentials.

---

## Known Issues / Tech Debt

- **Challenges in both DB and frontend**: `data/challenges.ts` holds type definitions and `TOPICS` metadata (icons etc.) for UI. Actual challenge content is served from DB via `/api/challenges`. To add a new challenge, write a new migration SQL — no need to edit `challenges.ts` unless adding a new topic.
- **No email verification**: `is_verified` column in DB is always `false`. No email sending infrastructure (SMTP/Resend).
- **Angular route matching**: `problems/topic/:topic` before `problems/:id` in routes is correct — test this on every route refactor.
- **Monaco assets**: `angular.json` copies the monaco-editor `min/vs` folder to `assets/monaco/min/vs`. Dev server must be restarted after any `angular.json` change for this to take effect.
- **Code execution not sandboxed yet**: `/api/run` does not exist yet. Until it does, test cases cannot be run server-side. Do not attempt to exec user code without proper sandboxing (Docker or Judge0).
