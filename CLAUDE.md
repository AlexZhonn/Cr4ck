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
| POST | /api/evaluate | AI code evaluation (TODO) |

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
| `/login` | LoginComponent | |
| `/register` | RegisterComponent | |
| `/about` | AboutComponent | |
| `/profile` | ProfileComponent | |

> **Route order matters:** `problems/topic/:topic` must appear before `problems/:id` in `app.routes.ts` or Angular will match "topic" as a problem ID.

---

## What's Next (Priority Order)

1. `ANTHROPIC_API_KEY` — add to `api/.env` to enable `/api/evaluate`
2. Leaderboard — `/leaderboard` page + `GET /api/leaderboard` backend endpoint (top users by XP)
3. Backend `/api/challenges` route — move challenges from static frontend data to DB
4. Email verification flow — `is_verified` flag exists in DB but no flow to set it
5. Prevent duplicate XP — users earn XP on every submit; should check if challenge already completed
6. Makefile — `make dev`, `make dev-api`, `make dev-ui`, `make check` targets
7. GitHub OAuth — buttons exist in Login/Register UI but not wired

---

## Known Issues / Tech Debt

- **Duplicate XP**: `evaluate.py` increments `challenges_completed` and awards XP on every submission. No deduplication check. A user can farm XP by re-submitting.
- **Challenges are frontend-only**: `data/challenges.ts` is the single source of truth. No backend `/api/challenges` route. Makes it hard to add challenges without a code deploy.
- **No email verification**: `is_verified` column in DB is always `false`. No email sending infrastructure (SMTP/Resend).
- **Sandbox not auth-gated for evaluate**: The evaluate button in the sandbox calls `/api/evaluate` without forcing login first (the guard only applies at route level; the button doesn't check `isLoggedIn` before calling).
- **Angular route matching**: `problems/topic/:topic` before `problems/:id` in routes is correct, but Angular's router doesn't support static segments before dynamic ones without ordering — test this on every route refactor.
