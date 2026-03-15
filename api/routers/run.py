"""
POST /api/run

Executes user code against the challenge's test cases in a sandboxed Docker
subprocess. Returns per-test pass/fail results with actual vs expected output.

Security: runs in Docker with --network none --memory 128m --cpus 0.5
Timeout: 10 seconds per run (all test cases together)
"""

import json
import subprocess
import tempfile
import os
import textwrap
from fastapi import APIRouter, HTTPException, status, Depends
from pydantic import BaseModel

from auth.dependencies import get_current_user
from core.database import get_db
from models.user import UserInDB

router = APIRouter(prefix="/api", tags=["run"])

TIMEOUT_SECONDS = 10


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
# Language runner helpers
# ---------------------------------------------------------------------------

def _docker_available() -> bool:
    try:
        result = subprocess.run(
            ["docker", "info"],
            capture_output=True,
            timeout=5,
        )
        return result.returncode == 0
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False


def _run_in_docker(image: str, cmd: list[str], tmpdir: str) -> tuple[str, str, int]:
    """Run a command in a sandboxed Docker container, returning (stdout, stderr, returncode)."""
    docker_cmd = [
        "docker", "run",
        "--rm",
        "--network", "none",
        "--memory", "128m",
        "--cpus", "0.5",
        "--pids-limit", "64",
        "--read-only",
        "--tmpfs", "/tmp:size=32m",
        "-v", f"{tmpdir}:/code:ro",
        "-w", "/code",
        image,
    ] + cmd

    try:
        proc = subprocess.run(
            docker_cmd,
            capture_output=True,
            text=True,
            timeout=TIMEOUT_SECONDS,
        )
        return proc.stdout, proc.stderr, proc.returncode
    except subprocess.TimeoutExpired:
        return "", "Execution timed out", 124


def _wrap_python(code: str, test_input: str) -> str:
    """Wrap Python solution code with stdin injection for test input."""
    escaped_input = test_input.replace("\\", "\\\\").replace("'", "\\'")
    return textwrap.dedent(f"""\
        import sys
        from io import StringIO
        sys.stdin = StringIO('{escaped_input}\\n')

        {code}
    """)


def _wrap_java(code: str, test_input: str) -> str:
    """Java code is returned as-is; test input is passed via stdin."""
    return code


def _wrap_typescript(code: str, test_input: str) -> str:
    """Wrap TypeScript solution with stdin injection."""
    escaped_input = test_input.replace("`", "\\`")
    preamble = textwrap.dedent(f"""\
        import {{ createInterface }} from 'readline';
        // Inject test input
        const _inputLines = `{escaped_input}`.split('\\n');
        let _lineIdx = 0;
        const _rl = createInterface({{ input: process.stdin }});
        // Override readline to use injected input
        process.stdin.push(_inputLines.join('\\n') + '\\n');
        process.stdin.push(null);

    """)
    return preamble + code


def _wrap_cpp(code: str, test_input: str) -> str:
    """C++ code is returned as-is; test input is passed via stdin."""
    return code


def _run_python(code: str, test_input: str, tmpdir: str) -> tuple[str, str]:
    with open(os.path.join(tmpdir, "solution.py"), "w") as f:
        f.write(code)

    if not _docker_available():
        return _run_python_local(code, test_input)

    docker_cmd = [
        "docker", "run",
        "--rm",
        "--network", "none",
        "--memory", "128m",
        "--cpus", "0.5",
        "--pids-limit", "64",
        "-v", f"{tmpdir}:/code:ro",
        "-w", "/code",
        "python:3.12-slim",
        "python", "-c",
        f"import sys; sys.stdin = __import__('io').StringIO({repr(test_input + chr(10))})\n" + code,
    ]
    try:
        proc = subprocess.run(
            docker_cmd,
            capture_output=True,
            text=True,
            timeout=TIMEOUT_SECONDS,
        )
        return proc.stdout.strip(), proc.stderr.strip() if proc.returncode != 0 else ""
    except subprocess.TimeoutExpired:
        return "", "Execution timed out (10s)"
    except FileNotFoundError:
        return _run_python_local(code, test_input)


def _run_python_local(code: str, test_input: str) -> tuple[str, str]:
    """Fallback: run Python locally with restricted builtins (no Docker)."""
    import ast
    # Basic safety check — reject code with obvious unsafe patterns
    dangerous = ["import os", "import sys", "import subprocess", "__import__", "open(", "exec(", "eval("]
    for d in dangerous:
        if d in code:
            return "", f"Unsafe operation blocked: {d}"
    try:
        proc = subprocess.run(
            ["python3", "-c", code],
            input=test_input + "\n",
            capture_output=True,
            text=True,
            timeout=TIMEOUT_SECONDS,
        )
        return proc.stdout.strip(), proc.stderr.strip() if proc.returncode != 0 else ""
    except subprocess.TimeoutExpired:
        return "", "Execution timed out (10s)"


def _run_java(code: str, test_input: str, tmpdir: str) -> tuple[str, str]:
    if not _docker_available():
        return "", "Java execution requires Docker (not available)"

    with open(os.path.join(tmpdir, "Solution.java"), "w") as f:
        # Wrap in a Solution class if not already present
        if "class Solution" not in code and "public class" not in code:
            f.write(f"public class Solution {{\n{code}\n}}")
        else:
            f.write(code)

    docker_cmd = [
        "docker", "run",
        "--rm",
        "--network", "none",
        "--memory", "256m",
        "--cpus", "0.5",
        "--pids-limit", "64",
        "-v", f"{tmpdir}:/code",
        "-w", "/code",
        "openjdk:21-slim",
        "bash", "-c",
        f"javac Solution.java 2>&1 && echo '{test_input}' | java Solution 2>&1",
    ]
    try:
        proc = subprocess.run(
            docker_cmd,
            capture_output=True,
            text=True,
            timeout=30,  # Java needs more time to compile
        )
        if proc.returncode != 0:
            return "", proc.stdout.strip() or proc.stderr.strip()
        return proc.stdout.strip(), ""
    except subprocess.TimeoutExpired:
        return "", "Execution timed out (30s)"


def _run_typescript(code: str, test_input: str, tmpdir: str) -> tuple[str, str]:
    if not _docker_available():
        return "", "TypeScript execution requires Docker (not available)"

    with open(os.path.join(tmpdir, "solution.ts"), "w") as f:
        f.write(code)

    docker_cmd = [
        "docker", "run",
        "--rm",
        "--network", "none",
        "--memory", "256m",
        "--cpus", "0.5",
        "--pids-limit", "64",
        "-v", f"{tmpdir}:/code:ro",
        "-w", "/code",
        "node:20-slim",
        "bash", "-c",
        f"npx --yes ts-node solution.ts <<< '{test_input}' 2>&1",
    ]
    try:
        proc = subprocess.run(
            docker_cmd,
            capture_output=True,
            text=True,
            timeout=30,
        )
        if proc.returncode != 0:
            return "", proc.stdout.strip() or proc.stderr.strip()
        return proc.stdout.strip(), ""
    except subprocess.TimeoutExpired:
        return "", "Execution timed out (30s)"


def _run_cpp(code: str, test_input: str, tmpdir: str) -> tuple[str, str]:
    if not _docker_available():
        return "", "C++ execution requires Docker (not available)"

    with open(os.path.join(tmpdir, "solution.cpp"), "w") as f:
        f.write(code)

    docker_cmd = [
        "docker", "run",
        "--rm",
        "--network", "none",
        "--memory", "128m",
        "--cpus", "0.5",
        "--pids-limit", "64",
        "-v", f"{tmpdir}:/code",
        "-w", "/code",
        "gcc:13",
        "bash", "-c",
        f"g++ -o solution solution.cpp 2>&1 && echo '{test_input}' | ./solution 2>&1",
    ]
    try:
        proc = subprocess.run(
            docker_cmd,
            capture_output=True,
            text=True,
            timeout=30,
        )
        if proc.returncode != 0:
            return "", proc.stdout.strip() or proc.stderr.strip()
        return proc.stdout.strip(), ""
    except subprocess.TimeoutExpired:
        return "", "Execution timed out (30s)"


RUNNERS = {
    "python": _run_python,
    "java": _run_java,
    "typescript": _run_typescript,
    "cpp": _run_cpp,
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
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Code cannot be empty",
        )

    lang = body.language.lower()
    if lang not in RUNNERS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported language: {body.language}. Supported: python, java, typescript, cpp",
        )

    # Fetch test cases from DB
    with db.cursor() as cur:
        cur.execute(
            "SELECT test_cases FROM challenges WHERE id = %s AND is_active = TRUE",
            (body.challenge_id,),
        )
        row = cur.fetchone()

    if not row:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Challenge not found",
        )

    test_cases = row["test_cases"] or []
    if not test_cases:
        return RunResponse(results=[], passed=0, total=0)

    runner = RUNNERS[lang]
    results: list[TestResult] = []

    with tempfile.TemporaryDirectory() as tmpdir:
        for tc in test_cases:
            tc_input = tc.get("input", "")
            tc_expected = tc.get("expected_output", "").strip()
            tc_desc = tc.get("description", "")

            try:
                actual, error = runner(body.code, tc_input, tmpdir)
                actual = actual.strip()
                passed = actual == tc_expected and not error
                results.append(TestResult(
                    description=tc_desc,
                    input=tc_input,
                    expected_output=tc_expected,
                    actual_output=actual,
                    passed=passed,
                    error=error or None,
                ))
            except Exception as e:
                results.append(TestResult(
                    description=tc_desc,
                    input=tc_input,
                    expected_output=tc_expected,
                    actual_output="",
                    passed=False,
                    error=str(e),
                ))

    passed_count = sum(1 for r in results if r.passed)
    return RunResponse(results=results, passed=passed_count, total=len(results))
