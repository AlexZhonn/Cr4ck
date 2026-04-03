# Cr4ck — Completed Work Log

> Chronological log of all finished features, fixes, and infrastructure work.
> See [CLAUDE.md](CLAUDE.md) for the active roadmap and audit action items.

---

## Features

### Daily Challenge
- **Daily AI-generated challenge** — `POST /api/admin/generate-daily` (protected by `X-Admin-Secret`) calls Claude to create a fresh challenge each day following a weekly rotation schedule (Mon=Easy design_patterns … Sat=Hard behavioral_patterns). Retries up to 3× on malformed output; falls back to a random unshown challenge. `GET /api/v1/daily` returns today's challenge (Redis-cached until midnight UTC). Landing page shows a "Today's Challenge" card with title, topic, difficulty badge, and a "Solve it" deep-link into the sandbox. GitHub Actions cron runs at midnight UTC.
- **Migration 014** — `is_ai_generated BOOLEAN`, `generated_at TIMESTAMPTZ` added to `challenges`; `daily_challenges` table (`date DATE PRIMARY KEY`, `challenge_id UUID FK`).

### Code Execution
- **Test harness system** — `test_harness` column (migration 013) holds a hidden driver script per challenge. `POST /api/v1/run` concatenates user code + harness before submitting to Judge0/Docker, enabling stdin/stdout test cases to work against user-defined classes. Per-language conflict stripping: Java `public` removed from user type declarations, C++ `int main()` removed, Python `__main__` block removed. Harness generation script (`api/scripts/generate_harnesses.py`) uses Claude API to write harnesses for all 300 challenges.
- **Multi-language support per challenge** — `starter_codes` JSONB column (migration 013) maps `{ language: starter_code }`. `ChallengeOut` returns it; frontend sandbox shows a language dropdown when multiple languages are available. `selectedLanguage` signal drives editor options, file extension, and request payloads.
- **Docker-sandboxed code execution** (`/api/run`) — Python/Java/TypeScript/C++; stdin via file, local Python fallback

### Community
- **Community posts per challenge** — migration 008, posts/votes, Community tab in sandbox
- **Post markdown rendering** — `marked` library; Edit/Delete buttons owner-only via `isOwnPost()` username check
- **Fix: `PostAuthor.id`** — changed from `number` to `string` (UUID) to match DB

### Sandbox & Editor
- **Test cases panel** — migrations 005–007, Tests tab in right panel
- **Sidebar filtering** — topic + difficulty + language filters
- **Draggable panel resizing** — all 3 split points, localStorage persist
- **Sandbox layout** — description + editor side-by-side (top half), Tests/AI/Community/History tabs at bottom
- **Challenge keyword search** — search input filters by title + description client-side; synced to `?q=` URL param
- **Sidebar filter state persistence** — topic, difficulty, and search (`q`) persisted in URL query params

### Challenges & Problems
- **TopicProblems enhanced filtering** — difficulty + language, colored dots
- **Completed challenge badges** — checkmark + best score in TopicProblems rows

### Profile & Progress
- **Challenge history in Profile** — `GET /api/profile/completed`, history list with scores
- **Submission history with code storage** — migration 012 adds `submissions` table; "History" tab in sandbox with scores, timestamps, expandable code and "Load into editor" button

### Auth & Account
- **Email verification via Postmark** — migration 010; `email_service.py` sends HTML email on register; `GET /auth/verify?token=` marks `is_verified=TRUE`; Angular `/verify-email` component
- **Enforce `is_verified` at login** — `/auth/login` returns 403 for unverified users; `POST /auth/resend-verification` re-sends link; login UI shows resend button
- **Forgot password / reset** — migration 011; `POST /auth/forgot-password` sends Postmark link (1hr TTL); `POST /auth/reset-password` verifies token + rehashes; Angular `/forgot-password` + `/reset-password` components
- **Password change from profile** — `PUT /auth/password` verifies current password with Argon2, rehashes new one; "Change Password" card in Profile settings

### AI & BYOK
- **BYOK AI provider keys** — Anthropic/OpenAI/Google, AES-256-GCM encrypted, Profile settings card
- **OpenAI + Google BYOK packages** — `openai==1.75.0` + `google-generativeai==0.8.5` added to `requirements.txt`

### Integrations
- **Judge0 CE integration** — `routers/run.py` POSTs to `JUDGE0_URL` when set; Docker fallback retained for dev; `httpx` added to `requirements.txt`
- **Rate limiting via `slowapi`** — register 10/hr, login 20/hr, resend/forgot 5/hr, evaluate 30/hr, run 60/hr, all per IP

### Pagination
- **Challenges list pagination** — `GET /api/challenges` returns `{ items, total, page, limit, pages }`; frontend fetches with `?limit=200`

---

## Annual Engineering Audit (2026-03-22) — All 24 items completed

### Security
- **AUDIT-S1** — WebSocket authentication: `solve_event` gated to verified JWT connections; `leaderboard_update` stays public
- **AUDIT-S2** — Timing-attack fix on verification + password-reset token lookups via `secrets.compare_digest()`
- **AUDIT-S3** — Rate-limit response headers (`X-RateLimit-Limit/Remaining/Reset`) via `headers_enabled=True`
- **AUDIT-S4** — HTTPS-only guidance: `api/.env.prod.example` with `https://` origins and `ALLOW_SERVER_KEY=false`

### Testing
- **AUDIT-T1** — Backend test suite: `api/tests/` with 35 tests across auth, challenges, evaluate, password; `requirements-dev.txt`
- **AUDIT-T2** — Frontend unit tests: 27 tests across 5 spec files (auth service, challenges service, guard, login, app smoke)
- **AUDIT-T3** — Playwright E2E tests: critical user journey covering public pages, registration, login, authenticated sandbox flows; `test/verify-bypass` endpoint for CI

### CI/CD
- **AUDIT-C1** — Tests run in CI: backend pytest with coverage gate (50%); frontend `test:ci` on every PR
- **AUDIT-C2** — Production Angular build in CI with bundle budget enforcement
- **AUDIT-C3** — mypy static type checking in CI (`continue-on-error` while coverage grows); `pyproject.toml` config
- **AUDIT-C4** — Bandit SAST scanning in CI and weekly `security.yml` workflow

### Observability
- **AUDIT-O1** — Structured JSON request logging middleware (`python-json-logger`): `request_id`, `method`, `path`, `status_code`, `duration_ms`, `user_id` per request
- **AUDIT-O2** — Sentry integration: backend (`sentry-sdk[fastapi]`) + frontend (`@sentry/angular@^8`); drops 401/403/404 noise
- **AUDIT-O3** — Health check endpoint `GET /health`: reports DB + Redis status; returns 503 when degraded
- **AUDIT-O4** — Business metric events: `evaluate.submitted/passed/failed`, `auth.login.success/failure` via structured logger

### Code Quality
- **AUDIT-Q1** — Prettier format check in CI (`format:check` script)
- **AUDIT-Q2** — ESLint with Angular-recommended rules; a11y violations escalated to errors in CI
- **AUDIT-Q3** — `api/pyproject.toml` with explicit Ruff, mypy, pytest, and coverage config

### Infrastructure
- **AUDIT-I1** — Connection pooling: `psycopg2.pool.ThreadedConnectionPool` (min=2, max=20); replaces per-request connections
- **AUDIT-I3** — Production Docker Compose: `api/Dockerfile`, `nginx.conf`, `docker-compose.prod.yml` with postgres/redis/api/nginx services
- **AUDIT-I4** — Query timeout (5s hard limit) + slow-query logging (>500ms WARNING) in `core/database.py`

### API Design
- **AUDIT-A1** — API versioning: all routes prefixed `/api/v1/` and `/auth/v1/`; unversioned aliases kept for one cycle
- **AUDIT-A2** — Standardised error schema: `{ "error": { "code", "message", "field" } }` via global exception handlers
- **AUDIT-A3** — OpenAPI schema exported as CI artifact (`openapi-schema`, 30-day retention); PR diff step included

### Frontend
- **AUDIT-F1** — Global Angular `ErrorHandler`: dismissible toast banner, Sentry forwarding, skips `ChunkLoadError`
- **AUDIT-F2** — Accessibility baseline: all `<button>` tags have `type`; interactive `<div>`s converted to `<button>`; vote buttons have `aria-label`; a11y ESLint rules set to error
- **AUDIT-F3** — Bundle size tracking: `bundlesize` thresholds (main ≤300 kB gzip); `npm run analyze` for local visualisation
- **AUDIT-F4** — Lazy loading: all routes use `loadComponent` syntax; Monaco excluded from initial bundle

---

## Bug Fixes

- **Sandbox template visibility** — services injected in `SandboxComponent` must be `readonly` (not `private`) for template access
- **Angular route matching** — `problems/topic/:topic` placed before `problems/:id` in `app.routes.ts`
- **FastAPI 422 flattening** — `AuthService` flattens `detail` arrays to readable strings
- **Login accepts email or username** — `LoginRequest.email` is plain `str`; query uses `WHERE email = %s OR username = %s`
- **Lint fix: `about.html`** — added `type="button"` to CTA button
- **Lint fix: `global-error-handler.ts`** — added description to bare `@ts-expect-error`
- **Lint fix: `sandbox.html`** — converted clickable submission header `<div>` to `<button type="button">`
- **CI fix: pytest `@example.invalid`** — Pydantic v2 `EmailStr` rejects `.invalid` TLD; changed to `@example.com` in all test fixtures
- **CI fix: evaluate mock** — `routers.evaluate.anthropic` doesn't exist at module level (lazy import); test now patches `routers.evaluate._call_anthropic` directly
