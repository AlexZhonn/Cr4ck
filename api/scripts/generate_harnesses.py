#!/usr/bin/env python3
"""
Generate test harnesses for all Cr4ck challenges and output a SQL migration file.

Usage:
    cd api && source venv/bin/activate
    python scripts/generate_harnesses.py \
        --output migrations/013b_harness_data.sql \
        --model gemini-2.5-pro

For each challenge, this script asks Gemini to:
  1. Write a test harness in the challenge's language that:
     - Is the sole public entry point (public class Main / run_harness() / int main())
     - Reads multi-command stdin (one command per line), processes each, prints results
     - Works when concatenated with user-submitted class definitions
  2. Update the test_cases JSON so each "input" uses the multi-command format
     the harness expects (with setup commands preceding the assertion command)

Output: SQL file with UPDATE statements for test_harness and test_cases columns.
Review the SQL before applying it: psql $DATABASE_URL -f migrations/013b_harness_data.sql
"""

import argparse
import json
import os
import sys
import textwrap
import time

import google.generativeai as genai
import psycopg2
import psycopg2.extras
from dotenv import load_dotenv

load_dotenv()

# ---------------------------------------------------------------------------
# Per-language harness authoring rules injected into the prompt
# ---------------------------------------------------------------------------
LANGUAGE_RULES: dict[str, str] = {
    "java": textwrap.dedent("""
        Java-specific rules:
        - The harness MUST be named exactly: public class Main
        - It must have: public static void main(String[] args) throws Exception
        - All user class declarations will have 'public' stripped before concatenation,
          so do NOT reference classes as 'public' in your harness — just use their names.
        - Use java.util.Scanner(System.in) to read stdin line by line.
        - Use a stateful object (e.g., Library lib = new Library()) created once,
          then loop over commands: while (sc.hasNextLine()) { ... }
        - Print each result with System.out.println().
    """).strip(),

    "python": textwrap.dedent("""
        Python-specific rules:
        - The harness MUST define a function called run_harness() and call it at module level.
        - Do NOT use if __name__ == '__main__': — it will be stripped from user code.
        - Use sys.stdin to read lines: import sys; for line in sys.stdin: ...
        - Create stateful objects once before the loop.
        - Print each result with print().
        - The harness is appended to user code, so all user-defined classes are available.
    """).strip(),

    "typescript": textwrap.dedent("""
        TypeScript-specific rules:
        - The harness MUST use Node.js readline:
            import * as readline from 'readline';
            const rl = readline.createInterface({ input: process.stdin });
            const lines: string[] = [];
            rl.on('line', (line) => lines.push(line.trim()));
            rl.on('close', () => { /* process lines here */ });
        - ALL logic must be inside the 'close' handler so it runs after stdin is fully read.
        - Create stateful objects inside the close handler before the loop.
        - Use console.log() to print results.
        - The harness is appended to user code, so all user-defined classes are available.
    """).strip(),

    "cpp": textwrap.dedent("""
        C++ specific rules:
        - The harness MUST provide int main() { ... }
        - User code may have an int main() — it will be stripped before concatenation.
        - Use #include <iostream>, #include <sstream>, #include <string> as needed.
        - Read stdin with: std::string line; while (std::getline(std::cin, line)) { ... }
        - Create stateful objects before the loop.
        - Use std::cout << result << std::endl; to print each result.
        - The harness is appended to user code so all user-defined classes/structs are available.
    """).strip(),
}

HARNESS_PROMPT = """\
You are writing a hidden test harness for a coding challenge platform called Cr4ck.

Challenge: {title} (ID: {challenge_id})
Language: {language}
Description:
{description}

Current starter code (what users are given):
```{language}
{starter_code}
```

Current test cases (these may need updating):
{test_cases_json}

{language_rules}

Your task:
1. Write a test harness in {language} that:
   - Acts as the SOLE entry point when concatenated with the user's class definitions
   - Reads commands from stdin, one per line
   - Maintains stateful objects across commands
   - Prints the result of each meaningful command to stdout (one result per line)
   - For stateful tests: earlier commands set up state, only the FINAL command's output
     needs to match expected_output (but all printed lines are compared)

2. Rewrite the test_cases array so that each "input" field uses the multi-command
   format your harness expects:
   - Include any setup commands needed to establish state before the test command
   - The "expected_output" should be the complete stdout output for ALL printed lines,
     newline-separated (e.g. "Book1 borrowed by User1\\nBook1 is not available")
   - Keep the same "description" values

Return ONLY valid JSON with no markdown, no explanation:
{{
  "harness": "<complete harness code as a string>",
  "test_cases": [
    {{"input": "command1\\ncommand2", "expected_output": "line1\\nline2", "description": "..."}}
  ]
}}
"""


def get_db_connection() -> psycopg2.extensions.connection:
    db_url = os.getenv("DATABASE_URL")
    if not db_url:
        sys.exit("DATABASE_URL not set in environment or .env")
    conn = psycopg2.connect(db_url, cursor_factory=psycopg2.extras.RealDictCursor)
    conn.autocommit = True
    return conn


def fetch_challenges(conn: psycopg2.extensions.connection) -> list[dict]:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT id, title, language, description, starter_code, test_cases
            FROM challenges
            WHERE is_active = TRUE
            ORDER BY id
            """
        )
        return [dict(r) for r in cur.fetchall()]


def call_gemini(model: genai.GenerativeModel, challenge: dict, retries: int = 3) -> dict | None:
    lang = challenge["language"].lower()
    prompt = HARNESS_PROMPT.format(
        title=challenge["title"],
        challenge_id=challenge["id"],
        language=lang,
        description=challenge["description"],
        starter_code=challenge["starter_code"],
        test_cases_json=json.dumps(challenge["test_cases"] or [], indent=2),
        language_rules=LANGUAGE_RULES.get(lang, ""),
    )

    for attempt in range(1, retries + 1):
        try:
            response = model.generate_content(prompt)
            raw = response.text.strip()

            # Strip any accidental markdown code fences
            if raw.startswith("```"):
                raw = raw.split("```", 2)[1]
                if raw.startswith("json"):
                    raw = raw[4:]
                raw = raw.rsplit("```", 1)[0].strip()

            data = json.loads(raw)
            harness = data.get("harness", "").strip()
            test_cases = data.get("test_cases", [])

            if not harness:
                raise ValueError("harness field is empty")
            if not isinstance(test_cases, list) or len(test_cases) == 0:
                raise ValueError("test_cases is empty or not a list")

            return {"harness": harness, "test_cases": test_cases}

        except Exception as exc:
            msg = str(exc)
            # Rate limit — honour the retry_delay from the error if present
            if "429" in msg or "RESOURCE_EXHAUSTED" in msg or "quota" in msg.lower():
                import re as _re
                m = _re.search(r'retry.*?(\d+)s', msg, _re.IGNORECASE)
                wait = int(m.group(1)) + 2 if m else 60
                print(f"  [attempt {attempt}/{retries}] rate limited, waiting {wait}s…", file=sys.stderr)
                time.sleep(wait)
            elif "504" in msg or "Deadline Exceeded" in msg:
                wait = 30 * attempt
                print(f"  [attempt {attempt}/{retries}] 504 timeout, waiting {wait}s…", file=sys.stderr)
                time.sleep(wait)
            else:
                print(f"  [attempt {attempt}/{retries}] error for {challenge['id']}: {exc}", file=sys.stderr)
                if attempt < retries:
                    time.sleep(2 ** attempt)

    return None


def escape_dollar_quote(s: str, tag: str = "harness") -> tuple[str, str]:
    """Ensure the dollar-quote tag doesn't appear inside the string."""
    while f"${tag}$" in s:
        tag = tag + "_"
    return tag, s


def write_sql(results: list[dict], output_path: str, append: bool = False) -> None:
    lines: list[str] = []

    for r in results:
        cid = r["challenge_id"]
        harness = r["harness"]
        test_cases_json = json.dumps(r["test_cases"], ensure_ascii=False)

        tag, harness = escape_dollar_quote(harness, "harness")

        lines.append(f"-- {cid}: {r['title']}")
        lines.append("UPDATE challenges SET")
        lines.append(f"  test_harness = ${tag}${harness}${tag}$,")
        lines.append(f"  test_cases   = {psycopg2.extensions.QuotedString(test_cases_json.encode('utf-8')).getquoted().decode('utf-8')}::jsonb")
        lines.append(f"WHERE id = {psycopg2.extensions.QuotedString(cid).getquoted().decode()};")
        lines.append("")

    with open(output_path, "a" if append else "w", encoding="utf-8") as f:
        f.write("\n".join(lines))


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate test harnesses for all Cr4ck challenges")
    parser.add_argument("--output", default="migrations/013b_harness_data.sql", help="Output SQL file path")
    parser.add_argument("--append", action="store_true", help="Append to output file instead of overwriting")
    parser.add_argument("--model", default="gemini-2.5-flash", help="Gemini model to use")
    parser.add_argument("--limit", type=int, default=0, help="Process only first N challenges (0 = all)")
    parser.add_argument("--offset", type=int, default=0, help="Skip first N challenges (resume from offset)")
    parser.add_argument("--id", help="Process only this challenge ID")
    args = parser.parse_args()

    api_key = os.getenv("GOOGLE_API_KEY")
    if not api_key:
        sys.exit("GOOGLE_API_KEY not set in environment or .env")

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel(args.model)

    conn = get_db_connection()
    challenges = fetch_challenges(conn)
    conn.close()

    if args.id:
        challenges = [c for c in challenges if c["id"] == args.id]
        if not challenges:
            sys.exit(f"Challenge '{args.id}' not found")
    else:
        if args.offset:
            challenges = challenges[args.offset:]
        if args.limit:
            challenges = challenges[: args.limit]

    print(f"Generating harnesses for {len(challenges)} challenges using {args.model}...")

    # Write header only when not appending
    if not args.append:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write("-- Migration 013b: test harness data + updated test_cases\n")
            f.write("-- Generated by api/scripts/generate_harnesses.py\n")
            f.write("-- REVIEW BEFORE APPLYING: psql $DATABASE_URL -f migrations/013b_harness_data.sql\n\n")

    failed: list[str] = []
    written = 0

    for i, challenge in enumerate(challenges, 1):
        cid = challenge["id"]
        lang = challenge["language"]
        print(f"[{i}/{len(challenges)}] {cid} ({lang})", end="  ", flush=True)

        result = call_gemini(model, challenge)
        if result:
            write_sql([{
                "challenge_id": cid,
                "title": challenge["title"],
                "harness": result["harness"],
                "test_cases": result["test_cases"],
            }], args.output, append=True)
            written += 1
            print("OK")
        else:
            failed.append(cid)
            print("FAILED")

        # Brief pause to stay under Flash RPM limits
        time.sleep(1.0)

    print(f"\nWrote {written} UPDATE statements to {args.output}")

    if failed:
        print(f"\nFailed ({len(failed)}):", ", ".join(failed), file=sys.stderr)
        print("Re-run with --id <challenge_id> to retry individual failures.", file=sys.stderr)


if __name__ == "__main__":
    main()
