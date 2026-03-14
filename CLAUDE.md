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
  ProblemSet/       Challenge grid with difficulty badges
  sandbox/          Main IDE: sidebar + Monaco + AI feedback pane
  Login/            JWT login form
  Register/         Registration form
  Problem/          Individual problem view (stub)
  services/         AuthService, EvaluateService (to be created)
  guards/           AuthGuard (to be created)

api/
  main.py           FastAPI entry, CORS, router mounting
  core/config.py    Env vars, JWT config, CORS origins
  core/database.py  psycopg2 connection pool
  auth/             tokens.py, password.py, dependencies.py
  models/user.py    Pydantic schemas + enums
  routers/auth.py   /auth/* endpoints
  routers/evaluate.py  /api/evaluate (to be created)
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

## What's Next (Priority Order)

1. `api/requirements.txt` — pin all Python deps
2. `ui/proxy.conf.json` — proxy Angular `/api` → FastAPI
3. `AuthService` (Angular) — token storage + API calls
4. Wire Login/Register forms to backend
5. Route guards + header auth state
6. `POST /api/evaluate` FastAPI endpoint using Claude API
7. Wire evaluate to sandbox frontend
8. `Problem` component with dynamic routing `/problems/:id`
