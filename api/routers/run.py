"""
POST /api/run

Executes user code against the challenge's test cases.

Primary:  Judge0 CE (self-hosted) — set JUDGE0_URL=http://judge0:2358 in .env.
          FastAPI POSTs to {JUDGE0_URL}/submissions?wait=true; Judge0 handles
          sandboxing (isolate + cgroups). FastAPI never touches Docker socket.

Fallback: Direct Docker execution (dev only, when JUDGE0_URL is unset).
          Python also has a local subprocess fallback when Docker is unavailable.

Language IDs (Judge0): Python 3 = 71, Java = 62, TypeScript = 74, C++ = 54
"""

import os
import re
import subprocess
import tempfile
import httpx
from fastapi import APIRouter, HTTPException, status, Depends, Request
from pydantic import BaseModel
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

from auth.dependencies import get_current_user
from core.database import get_db
from models.user import UserInDB

router = APIRouter(tags=["run"])

JUDGE0_URL = os.getenv("JUDGE0_URL", "").rstrip("/")


# ---------------------------------------------------------------------------
# Harness helpers — strip conflicting entry points from user code before
# concatenating with the challenge's hidden test harness.
# ---------------------------------------------------------------------------

def _strip_java_public(user_code: str) -> str:
    """Remove 'public' modifier from top-level class/interface/enum declarations.

    Java allows only one public top-level type per file. User code may have
    multiple 'public class' declarations; the harness provides the sole
    'public class Main'. This strips 'public' from all user type declarations
    without touching method-level 'public void', 'public int', etc.
    """
    return re.sub(
        r'^(\s*)public\s+((?:abstract\s+)?(?:class|interface|enum)\s)',
        r'\1\2',
        user_code,
        flags=re.MULTILINE,
    )


def _strip_cpp_main(user_code: str) -> str:
    """Remove any 'int main(...)' definition from user C++ code.

    Uses brace-counting to find the matching closing brace so the entire
    main body is removed. The harness provides the real main().
    """
    m = re.search(r'\bint\s+main\s*\([^)]*\)\s*\{', user_code)
    if not m:
        return user_code
    start = m.start()
    brace_start = user_code.index('{', m.start())
    depth = 0
    i = brace_start
    while i < len(user_code):
        if user_code[i] == '{':
            depth += 1
        elif user_code[i] == '}':
            depth -= 1
            if depth == 0:
                return user_code[:start] + user_code[i + 1:]
        i += 1
    return user_code  # malformed — return as-is


def _strip_python_main_block(user_code: str) -> str:
    """Remove 'if __name__ == \"__main__\":' block from user Python code.

    The harness calls run_harness() at module level, so any user-provided
    __main__ block must not execute.
    """
    return re.sub(
        r'\nif\s+__name__\s*==\s*["\']__main__["\']\s*:.*',
        '',
        user_code,
        flags=re.DOTALL,
    )


def _build_submission_code(language: str, user_code: str, test_harness: str | None) -> str:
    """Concatenate user code with the challenge's test harness.

    Returns user_code unchanged when no harness is present (backward compat).
    Each language has different conflict risks when concatenating:
      - Java: strip 'public' from user type decls; harness owns 'public class Main'
      - C++:  strip user int main(); harness provides int main()
      - Python: strip __main__ block; harness calls run_harness() at module level
      - TypeScript: harness uses readline close handler (runs last); no stripping needed
    """
    if not test_harness:
        return user_code
    lang = language.lower()
    if lang == "java":
        # Java imports must appear before class declarations.
        # Extract import lines from the harness, hoist them to the top.
        harness_lines = test_harness.splitlines(keepends=True)
        import_lines = [l for l in harness_lines if l.strip().startswith("import ")]
        non_import_harness = "".join(l for l in harness_lines if not l.strip().startswith("import "))
        imports_block = "".join(import_lines)
        cleaned_user = _strip_java_public(user_code)
        return imports_block + "\n" + cleaned_user + "\n\n" + non_import_harness
    if lang in ("cpp", "c++"):
        return _strip_cpp_main(user_code) + "\n\n" + test_harness
    if lang == "python":
        return _strip_python_main_block(user_code) + "\n\n" + test_harness
    # typescript — harness uses readline close handler, runs after all user code
    return user_code + "\n\n" + test_harness

TIMEOUT_RUN = 10    # seconds
TIMEOUT_COMPILE = 30

# Judge0 language IDs
JUDGE0_LANG: dict[str, int] = {
    "python":     71,
    "java":       62,
    "typescript": 74,
    "cpp":        54,
    "c++":        54,
}


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
# Judge0 runner
# ---------------------------------------------------------------------------

def _run_judge0(language: str, code: str, stdin: str) -> tuple[str, str]:
    """Submit to Judge0 and return (stdout, stderr_or_error)."""
    lang_id = JUDGE0_LANG[language]
    url = f"{JUDGE0_URL}/submissions?base64_encoded=false&wait=true"
    payload = {
        "source_code": code,
        "language_id": lang_id,
        "stdin": stdin,
    }
    try:
        resp = httpx.post(url, json=payload, timeout=TIMEOUT_COMPILE + 5)
        resp.raise_for_status()
    except httpx.HTTPError as exc:
        return "", f"Judge0 request failed: {exc}"

    data = resp.json()
    stdout = (data.get("stdout") or "").strip()
    stderr = (data.get("stderr") or "").strip()
    compile_output = (data.get("compile_output") or "").strip()
    status_desc = (data.get("status") or {}).get("description", "")

    if status_desc in ("Accepted",):
        return stdout, ""

    # Collect error info
    error_parts = []
    if compile_output:
        error_parts.append(compile_output)
    if stderr:
        error_parts.append(stderr)
    if not error_parts:
        error_parts.append(status_desc or "Unknown error")
    return stdout, "\n".join(error_parts)


# ---------------------------------------------------------------------------
# Docker helpers (fallback when JUDGE0_URL is unset)
# ---------------------------------------------------------------------------

def _docker_available() -> bool:
    try:
        r = subprocess.run(["docker", "info"], capture_output=True, timeout=5)
        return r.returncode == 0
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False


def _docker_run(image: str, shell_cmd: str, tmpdir: str, timeout: int) -> tuple[str, str, int]:
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


def _write(tmpdir: str, filename: str, content: str) -> None:
    path = os.path.join(tmpdir, filename)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


# ---------------------------------------------------------------------------
# Per-language Docker runners
# ---------------------------------------------------------------------------

def _docker_python(code: str, stdin: str, tmpdir: str) -> tuple[str, str]:
    _write(tmpdir, "solution.py", code)
    _write(tmpdir, "stdin.txt", stdin)

    if not _docker_available():
        dangerous = ["import os", "import sys", "import subprocess",
                     "__import__", "open(", "exec(", "eval("]
        if any(d in code for d in dangerous):
            return "", "Unsafe operation blocked (Docker not available)"
        try:
            proc = subprocess.run(
                ["python3", "solution.py"],
                input=stdin + "\n",
                capture_output=True, text=True, timeout=TIMEOUT_RUN,
                cwd=tmpdir,
            )
            return proc.stdout.strip(), _clean_error(proc.stderr.strip(), "python") if proc.returncode != 0 else ""
        except subprocess.TimeoutExpired:
            return "", f"Execution timed out ({TIMEOUT_RUN}s)"

    stdout, stderr, rc = _docker_run(
        "python:3.12-slim", "python solution.py < stdin.txt", tmpdir, TIMEOUT_RUN
    )
    return stdout, _clean_error(stderr, "python") if rc != 0 else ""


def _clean_error(stderr: str, language: str) -> str:
    """Trim compiler/runtime errors down to the most useful lines."""
    if not stderr:
        return ""
    lines = stderr.splitlines()
    if language == "java":
        # Group into individual errors separated by blank lines
        errors = []
        current: list[str] = []
        for l in lines:
            if re.match(r'.+\.java:\d+: error:', l):
                if current:
                    errors.append(current)
                current = [re.sub(r'^[^:]+\.java:(\d+):\s*', r'Line \1: ', l).strip()]
            elif current and ("^" in l or "symbol:" in l or "required:" in l or "found:" in l or "reason:" in l):
                current.append(l.strip())
            elif current and l.strip() == "":
                pass  # skip blank lines within a group
        if current:
            errors.append(current)
        # Format: each error as a paragraph, cap at 5 errors
        return "\n\n".join("\n".join(e) for e in errors[:5])
    if language in ("cpp", "c++"):
        useful = [l for l in lines if "error:" in l]
        cleaned = [re.sub(r'^[^:]+\.cpp:\d+:\d+:\s*', '', l).strip() for l in useful]
        return "\n".join(cleaned[:10])
    if language == "python":
        # Keep the last N lines (traceback tail is most useful)
        return "\n".join(lines[-8:])
    if language == "typescript":
        useful = [l for l in lines if "error TS" in l or "Error:" in l]
        return "\n".join(useful[:10]) if useful else "\n".join(lines[-8:])
    return "\n".join(lines[:10])


def _docker_java(code: str, stdin: str, tmpdir: str) -> tuple[str, str]:
    if not _docker_available():
        return "", "Java execution requires Docker (not available)"

    # Prefer 'Main' (harness entry point), then any public class, else wrap in Solution.
    m = re.search(r"\bclass\s+Main\b", code)
    if m:
        classname = "Main"
    else:
        m = re.search(r"public\s+class\s+(\w+)", code)
        classname = m.group(1) if m else "Solution"
    if classname == "Solution" and not m:
        code = f"public class Solution {{\n{code}\n}}"

    _write(tmpdir, f"{classname}.java", code)
    _write(tmpdir, "stdin.txt", stdin)

    stdout, stderr, rc = _docker_run(
        "eclipse-temurin:21-jdk-alpine",
        f"javac {classname}.java 2>&1 && java {classname} < stdin.txt",
        tmpdir, TIMEOUT_COMPILE,
    )
    if rc != 0:
        # javac errors go to stdout (2>&1); clean and return as error
        return "", _clean_error(stdout or stderr, "java")
    return stdout, ""


def _docker_typescript(code: str, stdin: str, tmpdir: str) -> tuple[str, str]:
    if not _docker_available():
        return "", "TypeScript execution requires Docker (not available)"

    _write(tmpdir, "solution.ts", code)
    _write(tmpdir, "stdin.txt", stdin)

    stdout, stderr, rc = _docker_run(
        "node:20-slim",
        "npx --yes ts-node --skip-project solution.ts < stdin.txt 2>&1",
        tmpdir, TIMEOUT_COMPILE,
    )
    return stdout, _clean_error(stderr, "typescript") if rc != 0 else ""


def _docker_cpp(code: str, stdin: str, tmpdir: str) -> tuple[str, str]:
    if not _docker_available():
        return "", "C++ execution requires Docker (not available)"

    _write(tmpdir, "solution.cpp", code)
    _write(tmpdir, "stdin.txt", stdin)

    stdout, stderr, rc = _docker_run(
        "gcc:13",
        "g++ -O2 -o solution solution.cpp 2>&1 && ./solution < stdin.txt",
        tmpdir, TIMEOUT_COMPILE,
    )
    return stdout, _clean_error(stderr, "cpp") if rc != 0 else ""


DOCKER_RUNNERS: dict[str, callable] = {
    "python":     _docker_python,
    "java":       _docker_java,
    "typescript": _docker_typescript,
    "cpp":        _docker_cpp,
    "c++":        _docker_cpp,
}


# ---------------------------------------------------------------------------
# Unified runner: Judge0 preferred, Docker fallback
# ---------------------------------------------------------------------------

def _execute(language: str, code: str, stdin: str, tmpdir: str) -> tuple[str, str]:
    if JUDGE0_URL:
        return _run_judge0(language, code, stdin)
    runner = DOCKER_RUNNERS.get(language)
    if runner:
        return runner(code, stdin, tmpdir)
    return "", f"Unsupported language: {language}"


# ---------------------------------------------------------------------------
# Endpoint
# ---------------------------------------------------------------------------

@router.post("/run", response_model=RunResponse)
@limiter.limit("60/hour")
def run_code(
    request: Request,
    body: RunRequest,
    db=Depends(get_db),
    current_user: UserInDB = Depends(get_current_user),
):
    if not body.code.strip():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Code cannot be empty")

    lang = body.language.lower()
    if lang not in JUDGE0_LANG and lang not in DOCKER_RUNNERS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported language: {body.language}. Supported: python, java, typescript, cpp",
        )

    with db.cursor() as cur:
        cur.execute(
            "SELECT test_cases, test_harness FROM challenges WHERE id = %s AND is_active = TRUE",
            (body.challenge_id,),
        )
        row = cur.fetchone()

    if not row:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Challenge not found")

    test_cases = row["test_cases"] or []
    if not test_cases:
        return RunResponse(results=[], passed=0, total=0)

    test_harness: str | None = row["test_harness"]
    results: list[TestResult] = []

    with tempfile.TemporaryDirectory() as tmpdir:
        for tc in test_cases:
            tc_input    = tc.get("input", "")
            tc_expected = tc.get("expected_output", "").strip()
            tc_desc     = tc.get("description", "")
            try:
                submission_code = _build_submission_code(lang, body.code, test_harness)
                actual, error = _execute(lang, submission_code, tc_input, tmpdir)
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
