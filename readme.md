# Cr4ck

> An AI-powered coding challenge platform for developers who want to go beyond LeetCode — write real object-oriented code and get instant architectural feedback.

Most platforms tell you if your output is correct. Cr4ck tells you if your **design** is any good.

Write code in the browser, run it against real test cases, and receive AI feedback on your OOP patterns, SOLID principles, and system design trade-offs. Earn XP, build streaks, and discuss approaches with the community.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture Overview](#architecture-overview)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
  - [Running Both Together](#running-both-together)
- [Environment Variables](#environment-variables)
- [Database Migrations](#database-migrations)
- [API Reference](#api-reference)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [Known Issues](#known-issues)
- [Roadmap](#roadmap)

---

## Features

- **In-browser IDE** — Monaco Editor with syntax highlighting for Java, Python, TypeScript, and C++
- **300+ OOP & System Design challenges** — organized by topic (Design Patterns, SOLID, Concurrency, etc.) with Easy / Medium / Hard tiers
- **AI architectural feedback** — submit your code and receive a score, strengths, and specific design improvements powered by Claude
- **Real test case execution** — code runs in a sandboxed Judge0 CE instance; results shown in a Tests tab
- **Submission history** — every submission stored with code, score, and timestamp; reload any past submission into the editor
- **Community discussion** — threaded posts with upvotes/downvotes per challenge, rendered in Markdown
- **JWT authentication** — access + refresh token rotation, Argon2id password hashing
- **Email verification** — Postmark sends a verification link on registration; forgot-password + reset flow included
- **XP & streaks** — earn XP per submission, track daily streaks and challenge history
- **Live leaderboard** — real-time updates via WebSocket broadcasts on XP award; authenticated connections only receive solve events
- **BYOK support** — bring your own Anthropic / OpenAI / Google API key, stored AES-256-GCM encrypted
- **Rate limiting** — per-IP limits on all sensitive endpoints (register 10/hr, login 20/hr, evaluate 30/hr, run 60/hr)
- **Structured observability** — JSON request logs, Sentry crash tracking, `/health` endpoint reporting DB + Redis status

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| Frontend | Angular 21, Tailwind CSS 4, Monaco Editor |
| Backend | FastAPI, Python 3.12+ |
| Database | PostgreSQL (Supabase or self-hosted) |
| Auth | JWT (HS256), Argon2id, refresh token rotation |
| AI | Claude API (`claude-sonnet-4-6`), OpenAI, Google Gemini (BYOK) |
| Code Execution | Judge0 CE (self-hosted or remote), Docker fallback for dev |
| Email | Postmark |
| Cache | Redis (optional — silently disabled if unreachable) |
| Realtime | WebSocket (`/ws`) |

---

## Architecture Overview

```text
┌─────────────────────────────────────┐
│         Angular 21 (port 4200)      │
│  Monaco Editor  ·  Tailwind CSS 4   │
└────────────────┬────────────────────┘
                 │ HTTP + WebSocket (proxied)
┌────────────────▼────────────────────┐
│         FastAPI (port 8000)         │
│  routers/  ·  auth/  ·  models/     │
└──┬──────────────┬────────────────┬──┘
   │              │                │
   ▼              ▼                ▼
PostgreSQL      Redis           Judge0 CE
(Supabase)   (optional)      (code execution)
```

The Angular dev server proxies `/auth/*`, `/api/*`, and `/ws` to FastAPI via `proxy.conf.json`, so no CORS issues during development.

---

## Getting Started

### Prerequisites

| Tool | Version |
| --- | --- |
| Node.js | 22+ |
| Python | 3.12+ |
| Angular CLI | 19+ (`npm i -g @angular/cli`) |
| PostgreSQL | Any (Supabase free tier works) |
| Docker | For Judge0 CE or local code execution fallback |

### Backend Setup

```bash
cd api

# Create and activate virtualenv
python -m venv venv
source venv/bin/activate          # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Copy and fill in environment variables
cp .env.example .env
# Edit .env — see Environment Variables section below

# Run migrations in order
for f in migrations/0*.sql; do psql "$DATABASE_URL" -f "$f"; done

# Start the API
uvicorn main:app --reload --port 8000
```

The API will be available at `http://localhost:8000`. Interactive docs at `http://localhost:8000/docs`.

### Frontend Setup

```bash
cd ui

# Install dependencies
npm install

# Start the dev server
ng serve
```

The app will be available at `http://localhost:4200`.

> **Monaco Editor note:** `angular.json` copies `node_modules/monaco-editor/min/vs` → `assets/monaco/min/vs` at build time. If the editor appears read-only, restart the dev server after any `angular.json` changes.

### Running Both Together

```bash
# From the project root
make dev          # runs API on :8000 + UI on :4200 in parallel
make install      # install all deps (frontend + backend)
make dev-api      # API only
make dev-ui       # UI only
make check        # tsc --noEmit + Python import check
```

---

## Environment Variables

Copy `api/.env.example` to `api/.env` and fill in each value.

| Variable | Required | Description |
| --- | --- | --- |
| `DATABASE_URL` | Yes | PostgreSQL connection string |
| `SECRET_KEY` | Yes | 64-char hex for JWT signing. Generate: `python3 -c "import secrets; print(secrets.token_hex(32))"` |
| `ALLOWED_ORIGINS` | Yes | Comma-separated CORS origins (e.g. `http://localhost:4200`) |
| `ANTHROPIC_API_KEY` | Yes* | Server-level Claude key. *Not needed if `ALLOW_SERVER_KEY=false` |
| `ALLOW_SERVER_KEY` | No | `true` (default) uses server key as fallback; set `false` in prod to require BYOK |
| `API_KEY_SECRET` | Yes | 64-char hex for AES-256-GCM encryption of user API keys |
| `JUDGE0_URL` | No | URL of Judge0 CE instance (e.g. `http://localhost:2358`). Falls back to Docker if unset |
| `POSTMARK_API_KEY` | No | Postmark server token for transactional email |
| `POSTMARK_FROM` | No | Verified sender address (e.g. `noreply@yourdomain.com`) |
| `FRONTEND_URL` | No | Base URL for email links (e.g. `https://cr4ck.dev`) |
| `REDIS_URL` | No | Redis connection string. Caching silently disabled if unset/unreachable |
| `SENTRY_DSN` | No | Sentry DSN for backend crash tracking |

---

## Database Migrations

Migrations are plain SQL files in `api/migrations/`. Run them in order:

```bash
for f in api/migrations/0*.sql; do psql "$DATABASE_URL" -f "$f"; done
```

| File | Description |
| --- | --- |
| `001_create_users_and_tokens.sql` | Users table, refresh tokens, indexes |
| `002_user_challenges.sql` | Challenge attempt tracking, XP, streaks |
| `003_challenges_seed.sql` | Initial challenge data (first batch) |
| `004_backfill_challenges.sql` | Additional challenges |
| `004b_fix_titles.sql` | Title corrections |
| `005_test_cases.sql` | Test cases table |
| `006_backfill_test_cases.sql` | Test case data |
| `007_backfill_test_cases_288.sql` | Test cases for remaining 288 challenges |
| `008_community_posts.sql` | Posts + votes tables |
| `009_user_api_key.sql` | BYOK encrypted API key storage |
| `010_email_verification.sql` | Email verification + password reset tokens |
| `011_password_reset.sql` | Password reset flow columns |
| `012_submission_history.sql` | Per-submission code + score storage |

To add new challenges, write a new migration that `INSERT`s into the `challenges` table — do not modify `ui/src/app/data/challenges.ts` (that file only holds TypeScript type definitions and topic UI metadata).

---

## API Reference

All endpoints are versioned under `/api/v1/` and `/auth/v1/`. Unversioned aliases (`/api/`, `/auth/`) are kept for one deprecation cycle.

### Auth

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| POST | `/auth/v1/register` | — | Create account (sends verification email) |
| POST | `/auth/v1/login` | — | Login with email or username; returns access + refresh tokens |
| POST | `/auth/v1/refresh` | — | Rotate refresh token |
| POST | `/auth/v1/logout` | — | Revoke refresh token |
| GET | `/auth/v1/me` | Required | Current user profile |
| GET | `/auth/v1/verify?token=` | — | Verify email address |
| POST | `/auth/v1/resend-verification` | — | Resend verification email |
| POST | `/auth/v1/forgot-password` | — | Send password reset link (1hr TTL) |
| POST | `/auth/v1/reset-password` | — | Reset password via token |
| PUT | `/auth/v1/password` | Required | Change password |
| PUT | `/auth/v1/api-key` | Required | Save/update BYOK API key |
| DELETE | `/auth/v1/api-key` | Required | Remove stored API key |
| GET | `/auth/v1/api-key/status` | Required | Returns `{ has_key, provider }` — never the key itself |

### Challenges

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| GET | `/api/v1/challenges` | — | All active challenges (paginated) |
| GET | `/api/v1/challenges/:id` | — | Single challenge detail |
| GET | `/api/v1/challenges/:id/my-submissions` | Required | Submission history for current user |
| POST | `/api/v1/evaluate` | Required | Submit code for AI evaluation; awards XP |
| POST | `/api/v1/run` | Required | Execute code via Judge0 CE sandbox |

### Community

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| GET | `/api/v1/challenges/:id/posts` | — | Paginated posts for a challenge |
| POST | `/api/v1/challenges/:id/posts` | Required | Create post or reply |
| PUT | `/api/v1/posts/:id` | Required | Edit own post |
| DELETE | `/api/v1/posts/:id` | Required | Soft-delete own post |
| POST | `/api/v1/posts/:id/vote` | Required | Vote: `+1` upvote, `-1` downvote, `0` remove |

### Other

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| GET | `/api/v1/leaderboard` | — | Top 50 users by XP |
| GET | `/api/v1/profile/completed` | Required | Challenges attempted by current user |
| GET | `/health` | — | Reports `{ status, db, redis }` — returns 503 if degraded |
| WS | `/ws?token=` | — | Real-time `solve_event` (auth only) + `leaderboard_update` broadcasts |

---

## Project Structure

```text
Cr4ck/
├── api/                        # FastAPI backend
│   ├── auth/                   # tokens.py, password.py, dependencies.py, apikey.py
│   ├── core/                   # config.py, database.py (connection pool), redis.py
│   ├── models/                 # Pydantic schemas (user.py)
│   ├── routers/                # auth, challenges, evaluate, leaderboard, posts, profile, run, ws
│   ├── migrations/             # SQL migration files (001–012)
│   ├── tests/                  # pytest suite (unit + integration)
│   ├── email_service.py        # Postmark transactional email
│   ├── main.py                 # FastAPI app entry point
│   ├── requirements.txt
│   ├── requirements-dev.txt    # pytest, mypy, httpx, etc.
│   ├── pyproject.toml          # Ruff, mypy, pytest, coverage config
│   └── .env.example
│
├── ui/                         # Angular 21 frontend
│   ├── e2e/                    # Playwright end-to-end tests
│   └── src/app/
│       ├── About/
│       ├── ForgotPassword/
│       ├── Header/
│       ├── LandingPage/
│       ├── Leaderboard/
│       ├── Login/
│       ├── Problem/
│       ├── ProblemSet/
│       ├── Profile/
│       ├── Register/
│       ├── ResetPassword/
│       ├── TopicProblems/
│       ├── VerifyEmail/
│       ├── sandbox/            # Main IDE: Monaco + AI feedback + Tests + Community + History tabs
│       ├── data/               # TypeScript types + TOPICS UI metadata
│       ├── guards/             # authGuard (protects /sandbox)
│       └── services/           # AuthService, ChallengesService, WebSocketService, PostsService
│
├── .github/workflows/
│   ├── ci.yml                  # Frontend + backend + E2E tests on every PR
│   ├── security.yml            # Weekly Bandit SAST scan
│   └── daily-challenge.yml     # (planned) AI-generated daily challenge
│
└── Makefile
```

---

## Contributing

Contributions are welcome. Here's how to get involved:

### How to contribute

1. Fork the repository and create a branch from `main`
2. Follow the [Getting Started](#getting-started) guide to set up your dev environment
3. Make your changes — keep PRs focused on one thing
4. Run the pre-commit checks locally before opening a PR:

```bash
# Backend (from api/, venv activated)
python -m ruff check .
mypy . --ignore-missing-imports
bandit -r . -ll --exclude ./venv,./tests -q
python -c "import main"

# Frontend (from ui/)
npx tsc --noEmit
npm run format:check
npm run lint
npm run test:ci
npm run build -- --configuration production
```

1. Open a pull request with a clear description of what changed and why

### Code conventions

- **Backend:** Python type hints everywhere, Pydantic for all request/response schemas, `psycopg2` with `RealDictCursor` for DB queries
- **Frontend:** Angular standalone components (no NgModules), Tailwind CSS utility classes only, `async/await` in services
- **Challenges:** New challenges go in a SQL migration — do not hardcode them in TypeScript
- **Secrets:** Never commit `.env`. Never log tokens or password hashes.

### Adding a new challenge

Write a migration in `api/migrations/` that inserts into `challenges`:

```sql
-- api/migrations/013_my_new_challenges.sql
INSERT INTO challenges (id, title, description, topic, difficulty, language, framework, starter_code, is_active)
VALUES (
  gen_random_uuid(),
  'My Challenge',
  'Description...',
  'design-patterns',
  'Medium',
  'python',
  'Python / OOP',
  E'class MyClass:\n    pass\n',
  TRUE
);
```

### Adding a new API endpoint

1. Create or edit a router in `api/routers/`
2. Mount it in `api/main.py` under both `/api/v1/` and `/auth/v1/` prefixes as appropriate
3. Add it to the API Reference table in this README
4. Add it to the API Endpoints table in `CLAUDE.md`

---

## Known Issues

| Issue | Notes |
| --- | --- |
| OpenAI + Google BYOK dispatch | Packages installed; provider routing in `routers/evaluate.py` still sends everything through Anthropic — needs conditional branching |
| Monaco editor read-only after `angular.json` changes | Restart the Angular dev server |
| `API_KEY_SECRET` must be exactly 64 hex chars | Generate: `python3 -c "import secrets; print(secrets.token_hex(32))"` |
| No automated DB backup | AUDIT-I2: enable Supabase PITR or add a `pg_dump` cron job |

---

## Roadmap

See [CLAUDE.md](CLAUDE.md) for the detailed roadmap with implementation notes. High-level items:

- [ ] Learning Paths / Challenge Sequences
- [ ] Public User Profiles (`/profile/:username`)
- [ ] Badges / Achievements System
- [ ] Daily AI-Generated Challenge
- [ ] Solution Showcase (opt-in public solutions after scoring ≥ 80)
- [ ] Admin Panel for Challenge Management
- [ ] GitHub OAuth
- [ ] Multi-Language Support per Challenge

---

## License

MIT
