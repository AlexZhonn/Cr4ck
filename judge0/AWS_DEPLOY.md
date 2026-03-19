# Judge0 AWS Deployment Checklist

Current state: Judge0 running locally at `http://localhost:2358` (dev only).
Goal: Move to an EC2 instance so Cr4ck prod can use it.

---

## 1. EC2 Instance

- [ ] Launch **Ubuntu 24.04 LTS**, instance type `t3.small` (min) or `t3.medium` (recommended)
- [ ] Storage: 20 GB gp3
- [ ] Install Docker on the instance:
  ```bash
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker ubuntu
  # re-login then verify:
  docker compose version
  ```

---

## 2. Security Group (Firewall)

- [ ] **Port 22** — SSH, source: your IP only
- [ ] **Port 2358** — Judge0 API, source: **Cr4ck FastAPI server's IP only** (NOT 0.0.0.0/0)
  - If FastAPI is also on EC2: use its private IP or security group reference
  - If FastAPI is elsewhere: use its public IP
- [ ] Do NOT expose ports 5432 (Postgres) or 6379 (Redis) publicly — they stay internal to the EC2 instance

---

## 3. judge0.conf Changes for Production

Edit `judge0.conf` before deploying to EC2:

### 3a. Rotate secrets (critical — current values are in git)
```ini
# Generate new ones:
# python3 -c "import secrets; print(secrets.token_hex(16))"
REDIS_PASSWORD=<new_random_value>
POSTGRES_PASSWORD=<new_random_value>
SECRET_KEY_BASE=<new_random_value>   # add this line
```

### 3b. Enable authentication (so only Cr4ck can call Judge0)
```ini
AUTHN_HEADER=X-Auth-Token
AUTHN_TOKEN=<generate a long random token>
```
Then add the same token to Cr4ck's `.env`:
```
JUDGE0_AUTH_TOKEN=<same token>
```
And update `api/routers/run.py` → `_run_judge0()` to pass the header:
```python
headers = {}
token = os.getenv("JUDGE0_AUTH_TOKEN", "")
if token:
    headers["X-Auth-Token"] = token

resp = httpx.post(url, json=payload, headers=headers, timeout=TIMEOUT_COMPILE + 5)
```

### 3c. Lock down allowed IPs (optional, belt-and-suspenders)
```ini
# Only allow requests from Cr4ck FastAPI server
ALLOW_IP="<fastapi_server_public_ip>"
```

### 3d. Disable telemetry (optional)
```ini
JUDGE0_TELEMETRY_ENABLE=false
```

---

## 4. Copy Files to EC2

```bash
scp -r judge0/ ubuntu@<ec2-public-ip>:~/judge0
```

Or clone the repo on EC2 and only copy `judge0/` contents.

---

## 5. Start Judge0 on EC2

```bash
ssh ubuntu@<ec2-public-ip>
cd ~/judge0

docker compose up -d db redis
sleep 10
docker compose up -d server workers

# Verify
curl http://localhost:2358/system_info
```

---

## 6. Update Cr4ck's .env (prod)

```ini
# Change from localhost to EC2 private IP (if same VPC) or public IP
JUDGE0_URL=http://<ec2-private-or-public-ip>:2358
JUDGE0_AUTH_TOKEN=<same token set in judge0.conf AUTHN_TOKEN>
```

---

## 7. Current judge0.conf Status

| Setting | Current value | Action needed |
|---------|--------------|---------------|
| `REDIS_PASSWORD` | set (hardcoded) | **Rotate before deploying** |
| `POSTGRES_PASSWORD` | set (hardcoded) | **Rotate before deploying** |
| `AUTHN_TOKEN` | empty | **Set before deploying** |
| `SECRET_KEY_BASE` | empty (auto-generated) | Set explicitly for stability |
| `ALLOW_IP` | empty (all IPs allowed) | Set to FastAPI server IP |
| `CPU_TIME_LIMIT` | 5s | OK for OOP challenges |
| `WALL_TIME_LIMIT` | 10s | OK |
| `MEMORY_LIMIT` | 128 MB | OK |
| `MAX_PROCESSES_AND_OR_THREADS` | 64 | OK |
| `ENABLE_NETWORK` | false (default) | OK — submissions cannot make network calls |

---

## 8. Verify End-to-End

Once deployed, test from your local machine:

```bash
# Health check (no auth needed)
curl http://<ec2-ip>:2358/system_info

# Test submission (with auth token if AUTHN_TOKEN is set)
curl -X POST "http://<ec2-ip>:2358/submissions?wait=true" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Token: <your_token>" \
  -d '{"source_code": "print(\"hello\")", "language_id": 71, "stdin": ""}'
```

Expected: `"stdout": "hello\n"`, `"status": {"description": "Accepted"}`

Then run a challenge from the Cr4ck sandbox to confirm the full path works.
