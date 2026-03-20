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
- **Community discussion** — threaded posts with upvotes/downvotes per challenge, rendered in Markdown
- **JWT authentication** — secure access + refresh token rotation, Argon2id password hashing
- **XP & streaks** — earn XP per submission, track daily streaks and challenge history
- **Live leaderboard** — real-time updates via WebSocket broadcasts on XP award
- **BYOK support** — bring your own Anthropic / OpenAI / Google API key, stored AES-256-GCM encrypted
- **Email verification** — Postmark integration sends a verification link on registration

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| Frontend | Angular 21, Tailwind CSS 4, Monaco Editor |
| Backend | FastAPI, Python 3.12+ |
| Database | PostgreSQL (Supabase or self-hosted) |
| Auth | JWT (HS256), Argon2id, refresh token rotation |
| AI | Claude API (`claude-sonnet-4-6`) |
| Code Execution | Judge0 CE (self-hosted), Docker fallback for dev |
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
| Node.js | 20+ |
| Python | 3.12+ |
| Angular CLI | 19+ (`npm i -g @angular/cli`) |
| PostgreSQL | Any (Supabase free tier works) |
| Docker | For Judge0 CE or local code execution |

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

# Run migrations (in order) against your PostgreSQL instance
psql $DATABASE_URL -f migrations/001_create_users_and_tokens.sql
# ... repeat for 002 through 010 (see Database Migrations section)

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
| `JUDGE0_URL` | No | URL of self-hosted Judge0 CE instance (e.g. `http://localhost:2358`). Falls back to Docker if unset |
| `POSTMARK_API_KEY` | No | Postmark server token for email verification |
| `POSTMARK_FROM` | No | Verified sender address (e.g. `noreply@yourdomain.com`) |
| `FRONTEND_URL` | No | Base URL for email links (e.g. `https://cr4ck.dev`) |
| `REDIS_URL` | No | Redis connection string. Caching silently disabled if unset/unreachable |

---

## Database Migrations

Migrations are plain SQL files in `api/migrations/`. Run them in order against your PostgreSQL instance:

```bash
psql $DATABASE_URL -f api/migrations/001_create_users_and_tokens.sql
psql $DATABASE_URL -f api/migrations/002_user_challenges.sql
psql $DATABASE_URL -f api/migrations/003_challenges_seed.sql
psql $DATABASE_URL -f api/migrations/004_backfill_challenges.sql
psql $DATABASE_URL -f api/migrations/004b_fix_titles.sql
psql $DATABASE_URL -f api/migrations/005_test_cases.sql
psql $DATABASE_URL -f api/migrations/006_backfill_test_cases.sql
psql $DATABASE_URL -f api/migrations/007_backfill_test_cases_288.sql
psql $DATABASE_URL -f api/migrations/008_community_posts.sql
psql $DATABASE_URL -f api/migrations/009_user_api_key.sql
psql $DATABASE_URL -f api/migrations/010_email_verification.sql
```

To add new challenges, write a new migration SQL that `INSERT`s into the `challenges` table — do not modify `ui/src/app/data/challenges.ts` (that file only holds TypeScript type definitions and topic UI metadata).

---

## API Reference

### Auth

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| POST | `/auth/register` | — | Create account (sends verification email) |
| POST | `/auth/login` | — | Login with email or username; returns access + refresh tokens |
| POST | `/auth/refresh` | — | Rotate refresh token |
| POST | `/auth/logout` | — | Revoke refresh token |
| GET | `/auth/me` | Required | Current user profile |
| GET | `/auth/verify?token=` | — | Verify email address |
| PUT | `/auth/api-key` | Required | Save/update BYOK API key |
| DELETE | `/auth/api-key` | Required | Remove stored API key |
| GET | `/auth/api-key/status` | Required | Returns `{ has_key, provider }` — never the key itself |

### Challenges

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| GET | `/api/challenges` | — | All active challenges |
| GET | `/api/challenges/:id` | — | Single challenge detail |
| POST | `/api/evaluate` | Required | Submit code for AI evaluation; awards XP |
| POST | `/api/run` | — | Execute code via Judge0 CE sandbox |

### Community

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| GET | `/api/challenges/:id/posts` | — | Paginated posts for a challenge |
| POST | `/api/challenges/:id/posts` | Required | Create post or reply |
| PUT | `/api/posts/:id` | Required | Edit own post |
| DELETE | `/api/posts/:id` | Required | Soft-delete own post |
| POST | `/api/posts/:id/vote` | Required | Vote: `+1` upvote, `-1` downvote, `0` remove |

### Other

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| GET | `/api/leaderboard` | — | Top 50 users by XP |
| GET | `/api/profile/completed` | Required | Challenges attempted by current user |
| WS | `/ws` | — | Real-time `solve_event` + `leaderboard_update` broadcasts |
| GET | `/` | — | Health check |

---

## Project Structure

```text
Cr4ck/
├── api/                        # FastAPI backend
│   ├── auth/                   # tokens.py, password.py, dependencies.py
│   ├── core/                   # config.py, database.py, redis.py
│   ├── models/                 # Pydantic schemas (user.py)
│   ├── routers/                # auth, challenges, evaluate, leaderboard, posts, run, ws
│   ├── migrations/             # SQL migration files (001–010)
│   ├── email_service.py        # Postmark email sender
│   ├── main.py                 # FastAPI app entry point
│   ├── requirements.txt
│   └── .env.example
│
├── ui/                         # Angular 21 frontend
│   └── src/app/
│       ├── About/
│       ├── Header/
│       ├── LandingPage/
│       ├── Leaderboard/
│       ├── Login/
│       ├── Problem/
│       ├── ProblemSet/
│       ├── Profile/
│       ├── Register/
│       ├── TopicProblems/
│       ├── VerifyEmail/
│       ├── sandbox/            # Main IDE: Monaco + AI feedback + Tests + Community tabs
│       ├── data/               # TypeScript types + TOPICS UI metadata
│       ├── guards/             # authGuard (protects /sandbox)
│       └── services/           # AuthService, ChallengesService, WebSocketService
│
├── judge0/                     # Judge0 CE self-hosted setup
│   ├── docker-compose.yml
│   ├── judge0.conf
│   └── AWS_DEPLOY.md           # Production deployment checklist
│
└── Makefile
```

---

## Contributing

Contributions are welcome. Here's how to get involved:

### Good first issues

- Fix the community post ownership UI — Edit/Delete buttons should be hidden for non-owners (backend already returns 403; just needs a frontend `isOwnPost()` check wired to the current user)
- Persist sidebar filter state in URL params or localStorage so filters survive navigation
- Add OpenAI and Google Gemini provider support (packages not yet in `requirements.txt`)
- Write a GitHub OAuth flow (backend stub exists, frontend shows "coming soon")

### How to contribute

1. Fork the repository and create a branch from `main`
2. Follow the [Getting Started](#getting-started) guide to set up your dev environment
3. Make your changes — keep PRs focused on one thing
4. Test your changes locally (both API and UI)
5. Open a pull request with a clear description of what you changed and why

### Code conventions

- **Backend:** Python type hints everywhere, Pydantic for all request/response schemas, `psycopg2` with `RealDictCursor` for DB queries
- **Frontend:** Angular standalone components (no NgModules), Tailwind CSS utility classes only (no `tailwind.config.js`), `async/await` in services
- **Challenges:** New challenges go in a SQL migration — do not hardcode them in TypeScript
- **Secrets:** Never commit `.env`. Never log tokens or password hashes.

### Adding a new challenge

Write a migration in `api/migrations/` that inserts into `challenges` and `test_cases`:

```sql
-- api/migrations/011_my_new_challenge.sql
INSERT INTO challenges (title, description, topic, difficulty, languages, starter_code, is_active)
VALUES ('My Challenge', 'Description...', 'design-patterns', 'medium', ARRAY['python','java'], '{}', TRUE);

INSERT INTO test_cases (challenge_id, input, expected_output, is_hidden)
VALUES (
  (SELECT id FROM challenges WHERE title = 'My Challenge'),
  '{"arg": "value"}',
  '{"result": "expected"}',
  FALSE
);
```

### Adding a new API endpoint

1. Create or edit a router in `api/routers/`
2. Mount it in `api/main.py`
3. Add it to the API Reference table in this README
4. Add it to the API Endpoints table in `CLAUDE.md`

---

## Known Issues

| Issue | Workaround |
| --- | --- |
| Community post Edit/Delete visible to all logged-in users | Backend correctly returns 403; UI fix is a good first contribution |
| Sidebar filter state resets on navigation | Planned: persist in URL params |
| OpenAI + Google BYOK providers not fully wired | `openai` and `google-generativeai` not yet in `requirements.txt` |
| Monaco editor read-only after `angular.json` changes | Restart the Angular dev server |
| `API_KEY_SECRET` must be exactly 64 hex chars | Generate with `python3 -c "import secrets; print(secrets.token_hex(32))"` |

---

## Roadmap

- [ ] GitHub OAuth (Supabase Auth or custom flow)
- [ ] Sidebar filter state persistence (URL params or localStorage)
- [ ] Full OpenAI + Google Gemini BYOK support
- [ ] Community post ownership UI fix
- [ ] Admin panel for challenge management
- [ ] Submission history + diff view per challenge

---

## License

MIT
