# Cr4ck

An AI-powered coding challenge platform for learning Object-Oriented Programming and System Design.

Write code in the browser. Get instant AI architectural feedback. Level up.

## Features

- In-browser Monaco Editor with Java, Python, TypeScript, C++ support
- OOP & System Design challenges with difficulty tiers
- AI-powered code evaluation (architectural feedback, not just correctness)
- JWT authentication with secure refresh token rotation
- XP, streaks, and progress tracking

## Tech Stack

- **Frontend:** Angular 21, Tailwind CSS 4, Monaco Editor
- **Backend:** FastAPI, PostgreSQL (Supabase)
- **Auth:** JWT + Argon2id
- **AI:** Claude API

## Quick Start

```bash
# Backend
cd api && source venv/bin/activate
uvicorn main:app --reload --port 8000

# Frontend
cd ui && npm install && ng serve
```

See [CLAUDE.md](CLAUDE.md) for full dev setup and architecture notes.
