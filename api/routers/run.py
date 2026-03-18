"""
POST /api/run

Executes user code against the challenge's test cases in a sandboxed Docker
container. Returns per-test pass/fail with actual vs expected output.

Security: --network none --memory 128m --cpus 0.5 --pids-limit 64
Timeout:  10s per test case (Java/TS/C++ allow 30s for compile step)
Stdin:    Written to /tmp/input.txt inside the container to handle
          multi-line and special-character inputs safely.
"""

import os
import subprocess
import tempfile
from fastapi import APIRouter, HTTPException, status, Depends
from pydantic import BaseModel

from auth.dependencies import get_current_user
from core.database import get_db
from models.user import UserInDB

router = APIRouter(prefix="/api", tags=["run"])

TIMEOUT_RUN = 10   # seconds per test case
TIMEOUT_COMPILE = 30  # seconds for compile-then-run languages


class RunRequest(BaseModel):
    challenge_id: str
    language: str
    code: str


class TestResult(BaseModel):
    description: str
    input: str
    expected_output: str
    actual_output: str
    passed: bool
    error: str | None = None


class RunResponse(BaseModel):
    results: list[TestResult]
    passed: int
    total: int


# ---------------------------------------------------------------------------
# Docker helpers
# ---------------------------------------------------------------------------

def _docker_available() -> bool:
    try:
        r = subprocess.run(["docker", "info"], capture_output=True, timeout=5)
        return r.returncode == 0
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False


def _docker_run(image: str, shell_cmd: str, tmpdir: str, timeout: int) -> tuple[str, str, int]:
    """
    Mount tmpdir as /code (rw) and run shell_cmd inside the container.
    stdin.txt is written to tmpdir before calling this — the shell_cmd
    should redirect < /code/stdin.txt for stdin injection.
    """
    cmd = [
        "docker", "run", "--rm",
        "--network", "none",
        "--memory", "128m",
        "--cpus", "0.5",
        "--pids-limit", "64",
        "-v", f"{tmpdir}:/code",
        "-w", "/code",
        image,
        "sh", "-c", shell_cmd,
    ]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return proc.stdout.strip(), proc.stderr.strip(), proc.returncode
    except subprocess.TimeoutExpired:
        return "", f"Execution timed out ({timeout}s)", 124


def _write(tmpdir: str, filename: str, content: str) -> str:
    path = os.path.join(tmpdir, filename)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    return path


# ---------------------------------------------------------------------------
# Per-language runners  (code, test_input, tmpdir) -> (stdout, stderr)
# ---------------------------------------------------------------------------

def _run_python(code: str, test_input: str, tmpdir: str) -> tuple[str, str]:
    _write(tmpdir, "solution.py", code)
    _write(tmpdir, "stdin.txt", test_input)

    if not _docker_available():
        # Local fallback — restricted to safe patterns
        dangerous = ["import os", "import sys", "import subprocess",
                     "__import__", "open(", "exec(", "eval("]
        if any(d in code for d in dangerous):
            return "", "Unsafe operation blocked (Docker not available)"
        try:
            proc = subprocess.run(
                ["python3", "solution.py"],
                input=test_input + "\n",
                capture_output=True, text=True, timeout=TIMEOUT_RUN,
                cwd=tmpdir,
            )
            return proc.stdout.strip(), proc.stderr.strip() if proc.returncode != 0 else ""
        except subprocess.TimeoutExpired:
            return "", f"Execution timed out ({TIMEOUT_RUN}s)"

    stdout, stderr, rc = _docker_run(
        "python:3.12-slim",
        "python solution.py < stdin.txt",
        tmpdir, TIMEOUT_RUN,
    )
    return stdout, stderr if rc != 0 else ""


def _run_java(code: str, test_input: str, tmpdir: str) -> tuple[str, str]:
    if not _docker_available():
        return "", "Java execution requires Docker (not available)"

    # Detect or inject public class name
    import re
    m = re.search(r"public\s+class\s+(\w+)", code)
    classname = m.group(1) if m else "Solution"
    if not m:
        code = f"public class Solution {{\n{code}\n}}"

    _write(tmpdir, f"{classname}.java", code)
    _write(tmpdir, "stdin.txt", test_input)

    stdout, stderr, rc = _docker_run(
        "openjdk:21-slim",
        f"javac {classname}.java 2>&1 && java {classname} < stdin.txt",
        tmpdir, TIMEOUT_COMPILE,
    )
    return stdout, stderr if rc != 0 else ""


def _run_typescript(code: str, test_input: str, tmpdir: str) -> tuple[str, str]:
    if not _docker_available():
        return "", "TypeScript execution requires Docker (not available)"

    _write(tmpdir, "solution.ts", code)
    _write(tmpdir, "stdin.txt", test_input)

    # Use ts-node from a globally installed image; fall back to compiling with tsc+node
    stdout, stderr, rc = _docker_run(
        "node:20-slim",
        "npx --yes ts-node --skip-project solution.ts < stdin.txt 2>&1",
        tmpdir, TIMEOUT_COMPILE,
    )
    return stdout, stderr if rc != 0 else ""


def _run_cpp(code: str, test_input: str, tmpdir: str) -> tuple[str, str]:
    if not _docker_available():
        return "", "C++ execution requires Docker (not available)"

    _write(tmpdir, "solution.cpp", code)
    _write(tmpdir, "stdin.txt", test_input)

    stdout, stderr, rc = _docker_run(
        "gcc:13",
        "g++ -O2 -o solution solution.cpp 2>&1 && ./solution < stdin.txt",
        tmpdir, TIMEOUT_COMPILE,
    )
    return stdout, stderr if rc != 0 else ""


RUNNERS: dict[str, callable] = {
    "python":     _run_python,
    "java":       _run_java,
    "typescript": _run_typescript,
    "cpp":        _run_cpp,
    "c++":        _run_cpp,
}


# ---------------------------------------------------------------------------
# Endpoint
# ---------------------------------------------------------------------------

@router.post("/run", response_model=RunResponse)
def run_code(
    body: RunRequest,
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    if not body.code.strip():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Code cannot be empty")

    lang = body.language.lower()
    runner = RUNNERS.get(lang)
    if not runner:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported language: {body.language}. Supported: python, java, typescript, cpp",
        )

    with db.cursor() as cur:
        cur.execute(
            "SELECT test_cases FROM challenges WHERE id = %s AND is_active = TRUE",
            (body.challenge_id,),
        )
        row = cur.fetchone()

    if not row:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Challenge not found")

    test_cases = row["test_cases"] or []
    if not test_cases:
        return RunResponse(results=[], passed=0, total=0)

    results: list[TestResult] = []

    with tempfile.TemporaryDirectory() as tmpdir:
        for tc in test_cases:
            tc_input    = tc.get("input", "")
            tc_expected = tc.get("expected_output", "").strip()
            tc_desc     = tc.get("description", "")
            try:
                actual, error = runner(body.code, tc_input, tmpdir)
                actual = actual.strip()
                passed = (actual == tc_expected) and not error
                results.append(TestResult(
                    description=tc_desc,
                    input=tc_input,
                    expected_output=tc_expected,
                    actual_output=actual,
                    passed=passed,
                    error=error or None,
                ))
            except Exception as exc:
                results.append(TestResult(
                    description=tc_desc,
                    input=tc_input,
                    expected_output=tc_expected,
                    actual_output="",
                    passed=False,
                    error=str(exc),
                ))

    passed_count = sum(1 for r in results if r.passed)
    return RunResponse(results=results, passed=passed_count, total=len(results))
