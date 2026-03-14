.PHONY: dev dev-api dev-ui check install

# ── Dev servers ───────────────────────────────────────────────────────────────

dev:
	@echo "Starting API and UI in parallel..."
	@make -j2 dev-api dev-ui

dev-api:
	cd api && source venv/bin/activate && uvicorn main:app --reload --port 8000

dev-ui:
	cd ui && ng serve

# ── Static checks (no servers needed) ────────────────────────────────────────

check:
	@echo "=== TypeScript type check ==="
	cd ui && npx tsc --noEmit
	@echo "=== Python import check ==="
	cd api && source venv/bin/activate && python -c "from main import app; print('Backend imports OK')"
	@echo "All checks passed."

# ── Install deps ──────────────────────────────────────────────────────────────

install:
	cd ui && npm install
	cd api && python -m venv venv && source venv/bin/activate && pip install -r requirements.txt
