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


### 1. Email Verification
`is_verified` column in DB always `false`. Integrate Resend or SMTP to send verification link on register.

### 2. GitHub OAuth
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
- **OpenAI + Google providers**: `openai` and `google-generativeai` packages are not in requirements.txt yet — add them before enabling those providers in prod.
- **Community post ownership UI**: Edit/Delete shown to all logged-in users. Backend returns 403 correctly; UI needs `auth.currentUser()` check to hide buttons for non-owners.
- **Sidebar filter state not preserved**: Filters reset on navigation. Could persist in URL params or localStorage.
