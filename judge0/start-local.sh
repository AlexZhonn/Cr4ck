#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "Starting Judge0 locally..."

echo "[1/3] Starting db and redis..."
docker compose up -d db redis

echo "[2/3] Waiting 10s for db/redis to initialize..."
sleep 10

echo "[3/3] Starting server and workers..."
docker compose up -d server workers

echo ""
echo "Judge0 is up at http://localhost:2358"
echo ""
echo "Verifying..."
for i in {1..10}; do
  if curl -sf http://localhost:2358/system_info > /dev/null 2>&1; then
    echo "Health check passed."
    break
  fi
  echo "  waiting... ($i/10)"
  sleep 3
done

echo ""
echo "To stop: docker compose down"
echo "To stop and wipe data: docker compose down -v"
