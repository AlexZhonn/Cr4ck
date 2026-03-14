# Cr4ck — CLAUDE.md

## Project Overview

**Cr4ck** is an AI-powered coding challenge platform focused on Object-Oriented Programming (OOP) and System Design. Users write code in a browser-based Monaco Editor and receive instant AI architectural feedback.

**Stack:**
- Frontend: Angular 21 + Tailwind CSS 4 + Monaco Editor (port 4200 dev)
- Backend: FastAPI + PostgreSQL (Supabase) (port 8000 dev)
- Auth: JWT (access 15min / refresh 30d) + Argon2id password hashing
- AI: Claude API for code evaluation (to be wired in `/api/evaluate`)

---

## Dev Setup

### Backend

```bash
cd api
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt   # once created
uvicorn main:app --reload --port 8000
```

Requires `.env` in `api/`:
```
DATABASE_URL=postgresql://...
SECRET_KEY=...
ALLOWED_ORIGINS=http://localhost:4200
ANTHROPIC_API_KEY=...
```

### Frontend

```bash
cd ui
npm install
ng serve   # runs on http://localhost:4200
```

Angular proxies `/api/*` → `http://localhost:8000` via `proxy.conf.json` (to be added).

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
  data/challenges   Challenge[] + Topic type + TOPICS metadata — single source of truth
  services/         AuthService (JWT lifecycle)
  guards/           authGuard (CanActivateFn, protects /sandbox)

api/
  main.py           FastAPI entry, CORS, router mounting
  core/config.py    Env vars, JWT config, CORS origins
  core/database.py  psycopg2 connection pool
  auth/             tokens.py, password.py, dependencies.py
  models/user.py    Pydantic schemas + enums
  routers/auth.py   /auth/* endpoints
  routers/evaluate.py  POST /api/evaluate — Claude API, XP award, streak tracking
  migrations/       Raw SQL migration files
```

---

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | / | Health check |
| POST | /auth/register | Create account |
| POST | /auth/login | Get tokens |
| POST | /auth/refresh | Rotate refresh token |
| POST | /auth/logout | Revoke refresh token |
| GET | /auth/me | Current user profile |
| GET | /api/challenges | All active challenges (public) |
| GET | /api/challenges/:id | Single challenge detail (public) |
| POST | /api/evaluate | AI code evaluation (needs ANTHROPIC_API_KEY) |
| GET | /api/leaderboard | Top 50 users ranked by XP (public) |

---

## Key Decisions

- Argon2id with per-user salt + server-side pepper (not stored in DB)
- Refresh tokens stored in DB with JTI for per-token revocation
- Angular standalone components (no NgModules)
- Tailwind v4 (CSS-first config, no tailwind.config.js)
- Monaco editor for in-browser code editing across Java, Python, TypeScript, C++

---

## Routes

| Path | Component | Notes |
|------|-----------|-------|
| `/` | LandingPageComponent | Hero + CTA |
| `/problems` | ProblemSetComponent | Topic hub |
| `/problems/topic/:topic` | TopicProblemsComponent | Topic detail + difficulty filter |
| `/problems/:id` | ProblemComponent | Problem detail |
| `/sandbox` | SandboxComponent | Auth-guarded |
| `/leaderboard` | LeaderboardComponent | Public, fetches /api/leaderboard |
| `/login` | LoginComponent | |
| `/register` | RegisterComponent | |
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

> Run `migration 002_user_challenges.sql` against Supabase before starting the API — it creates the `user_challenges` table needed for XP deduplication.

---

## What's Next (Priority Order)

1. `ANTHROPIC_API_KEY` — add to `api/.env` to enable `/api/evaluate`
2. Backend `/api/challenges` route — move challenges from static frontend data to DB
3. Email verification flow — `is_verified` flag exists in DB but no flow to set it
4. GitHub OAuth — buttons exist in Login/Register UI but not wired

---

## Known Issues / Tech Debt

- **Challenges in both DB and frontend**: `data/challenges.ts` still holds the type definitions and `TOPICS` metadata (icons etc.) used for UI. The actual challenge content is now served from the DB via `/api/challenges`. When adding a new challenge, update `003_challenges_seed.sql` and run it — no need to edit `challenges.ts` unless you're adding a new topic.
- **No email verification**: `is_verified` column in DB is always `false`. No email sending infrastructure (SMTP/Resend).
- **Sandbox not auth-gated for evaluate**: The evaluate button calls `/api/evaluate` without checking `isLoggedIn` client-side — backend will 401, but the UX could be friendlier (prompt to log in instead of showing an error).
- **Angular route matching**: `problems/topic/:topic` before `problems/:id` in routes is correct, but test this on every route refactor.
