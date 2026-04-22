#!/usr/bin/env python3
"""
Generate multi-language starter codes for all Cr4ck challenges.

For each challenge, asks Gemini to translate the existing starter code into
the other 3 supported languages (java, python, typescript, cpp), then writes
a SQL migration that merges all 4 into the starter_codes JSONB column.

Usage:
    cd api && source venv/bin/activate
    python scripts/generate_starter_codes.py \
        --output migrations/017_starter_codes.sql

    # Dry-run first 5 challenges:
    python scripts/generate_starter_codes.py --limit 5 --output /tmp/test.sql

    # Resume from offset (e.g. after a crash at challenge 50):
    python scripts/generate_starter_codes.py --offset 50 --append \
        --output migrations/017_starter_codes.sql

    # Retry a single challenge:
    python scripts/generate_starter_codes.py --id oop_001 --append \
        --output migrations/017_starter_codes.sql

Apply when satisfied:
    psql $DATABASE_URL -f api/migrations/017_starter_codes.sql
"""

import argparse
import json
import os
import sys
import time
import textwrap

import google.generativeai as genai
import psycopg2
import psycopg2.extras
from dotenv import load_dotenv

load_dotenv()

ALL_LANGUAGES = ["java", "python", "typescript", "cpp"]

# ---------------------------------------------------------------------------
# Per-language starter-code style rules
# ---------------------------------------------------------------------------
LANGUAGE_STYLE: dict[str, str] = {
    "java": textwrap.dedent("""
        Java style rules:
        - Use public class declarations (no package statement).
        - Prefer standard Java idioms: ArrayList, HashMap, etc.
        - Do NOT add a main() method — this is starter code only.
        - Use // TODO: implement for method bodies.
        - Keep fields private with public getters/setters where appropriate.
    """).strip(),

    "python": textwrap.dedent("""
        Python style rules:
        - Use Python 3 type hints where natural (e.g. def foo(self, x: int) -> str:).
        - Do NOT add if __name__ == '__main__': — starter code only.
        - Use # TODO: implement for method bodies (just `pass` as the body).
        - Use @abstractmethod / ABC for abstract classes.
        - Keep it idiomatic: dataclasses, properties, dunder methods as appropriate.
    """).strip(),

    "typescript": textwrap.dedent("""
        TypeScript style rules:
        - Use interface or abstract class as appropriate.
        - Do NOT add any harness, readline, or entry-point code — starter code only.
        - Use // TODO: implement for method bodies.
        - Type all parameters and return values.
        - Use readonly, private, public access modifiers.
    """).strip(),

    "cpp": textwrap.dedent("""
        C++ style rules:
        - A single file with class definitions is fine — no header guards needed.
        - Do NOT add int main() — this is starter code only.
        - Use // TODO: implement for method bodies.
        - Use std::string, std::vector, std::unordered_map etc.
        - Use virtual / override / pure virtual (= 0) for abstract methods.
        - Keep constructors and destructors explicit.
    """).strip(),
}

TRANSLATE_PROMPT = """\
You are translating a coding challenge starter code for the Cr4ck platform.

Challenge: {title}
Topic: {topic}  Difficulty: {difficulty}
Description:
{description}

Original language: {src_language}
Original starter code:
```{src_language}
{starter_code}
```

Target language: {tgt_language}

{style_rules}

Task:
Translate the starter code above into {tgt_language}.
- Preserve the same class names, method signatures (adapted to {tgt_language} conventions), and structure.
- Keep the same TODO comments so users know what to implement.
- Do NOT implement any logic — stubs only.
- Return ONLY the raw code with no markdown fences, no explanation.
"""


# ---------------------------------------------------------------------------
# DB helpers
# ---------------------------------------------------------------------------

def get_db_connection() -> psycopg2.extensions.connection:
    db_url = os.getenv("DATABASE_URL")
    if not db_url:
        sys.exit("DATABASE_URL not set in environment or .env")
    conn = psycopg2.connect(db_url, cursor_factory=psycopg2.extras.RealDictCursor)
    conn.autocommit = True
    return conn


def fetch_challenges(conn: psycopg2.extensions.connection, challenge_id: str | None = None) -> list[dict]:
    with conn.cursor() as cur:
        if challenge_id:
            cur.execute(
                """
                SELECT id, title, topic, difficulty, language, description,
                       starter_code, starter_codes
                FROM challenges
                WHERE is_active = TRUE AND id = %s
                """,
                (challenge_id,),
            )
        else:
            cur.execute(
                """
                SELECT id, title, topic, difficulty, language, description,
                       starter_code, starter_codes
                FROM challenges
                WHERE is_active = TRUE
                ORDER BY id
                """
            )
        return [dict(r) for r in cur.fetchall()]


# ---------------------------------------------------------------------------
# Gemini API
# ---------------------------------------------------------------------------

def translate_starter_code(
    model: genai.GenerativeModel,
    challenge: dict,
    tgt_language: str,
    retries: int = 3,
) -> str | None:
    src_language = challenge["language"].lower()
    prompt = TRANSLATE_PROMPT.format(
        title=challenge["title"],
        topic=challenge["topic"],
        difficulty=challenge["difficulty"],
        description=challenge["description"],
        src_language=src_language,
        starter_code=challenge["starter_code"],
        tgt_language=tgt_language,
        style_rules=LANGUAGE_STYLE.get(tgt_language, ""),
    )

    for attempt in range(1, retries + 1):
        try:
            response = model.generate_content(prompt)
            raw = response.text.strip()

            # Strip accidental markdown fences
            if raw.startswith("```"):
                lines = raw.split("\n")
                raw = "\n".join(lines[1:-1]).strip()

            if not raw:
                raise ValueError("empty response from Gemini")

            return raw

        except Exception as exc:
            msg = str(exc)
            if "429" in msg or "RESOURCE_EXHAUSTED" in msg or "quota" in msg.lower():
                import re as _re
                m = _re.search(r'retry.*?(\d+)s', msg, _re.IGNORECASE)
                wait = int(m.group(1)) + 2 if m else 60
                print(f"  [attempt {attempt}/{retries}] rate limited, waiting {wait}s…", file=sys.stderr)
                time.sleep(wait)
            elif "504" in msg or "Deadline Exceeded" in msg:
                wait = 30 * attempt
                print(f"  [attempt {attempt}/{retries}] timeout, waiting {wait}s…", file=sys.stderr)
                time.sleep(wait)
            else:
                print(
                    f"  [attempt {attempt}/{retries}] error translating {challenge['id']} → {tgt_language}: {exc}",
                    file=sys.stderr,
                )
                if attempt < retries:
                    time.sleep(2 ** attempt)

    return None


# ---------------------------------------------------------------------------
# SQL output
# ---------------------------------------------------------------------------

def write_sql(results: list[dict], output_path: str, append: bool = False) -> None:
    lines: list[str] = []

    for r in results:
        cid = r["challenge_id"]
        codes: dict[str, str] = r["starter_codes"]
        json_str = json.dumps(codes, ensure_ascii=False)
        quoted = psycopg2.extensions.QuotedString(json_str.encode("utf-8")).getquoted().decode("utf-8")

        lines.append(f"-- {cid}: {r['title']}")
        lines.append("UPDATE challenges")
        lines.append(f"  SET starter_codes = {quoted}::jsonb")
        lines.append(f"WHERE id = {psycopg2.extensions.QuotedString(cid).getquoted().decode()};")
        lines.append("")

    mode = "a" if append else "w"
    with open(output_path, mode, encoding="utf-8") as f:
        f.write("\n".join(lines))


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate multi-language starter codes for all Cr4ck challenges"
    )
    parser.add_argument(
        "--output",
        default="migrations/017_starter_codes.sql",
        help="Output SQL file path",
    )
    parser.add_argument(
        "--append",
        action="store_true",
        help="Append to output file instead of overwriting",
    )
    parser.add_argument(
        "--model",
        default="gemini-2.5-flash",
        help="Gemini model to use (default: gemini-2.5-flash)",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=0,
        help="Process only first N challenges (0 = all)",
    )
    parser.add_argument(
        "--offset",
        type=int,
        default=0,
        help="Skip first N challenges (for resuming after a crash)",
    )
    parser.add_argument(
        "--id",
        help="Process only this challenge ID",
    )
    parser.add_argument(
        "--skip-existing",
        action="store_true",
        default=True,
        help="Skip challenges that already have all 4 languages in starter_codes (default: on)",
    )
    parser.add_argument(
        "--no-skip-existing",
        dest="skip_existing",
        action="store_false",
        help="Re-generate even if starter_codes already has all 4 languages",
    )
    args = parser.parse_args()

    api_key = os.getenv("GOOGLE_API_KEY")
    if not api_key:
        sys.exit("GOOGLE_API_KEY not set in environment or .env")

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel(args.model)

    conn = get_db_connection()
    challenges = fetch_challenges(conn, challenge_id=args.id)
    conn.close()

    if not args.id:
        if args.offset:
            challenges = challenges[args.offset:]
        if args.limit:
            challenges = challenges[: args.limit]

    if args.skip_existing and not args.id:
        before = len(challenges)
        challenges = [
            c for c in challenges
            if not all(lang in (c.get("starter_codes") or {}) for lang in ALL_LANGUAGES)
        ]
        skipped = before - len(challenges)
        if skipped:
            print(f"Skipping {skipped} challenges that already have all 4 languages.")

    print(f"Generating starter codes for {len(challenges)} challenges using {args.model}…")

    if not args.append:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write("-- Migration 017: multi-language starter codes\n")
            f.write("-- Generated by api/scripts/generate_starter_codes.py\n")
            f.write("-- REVIEW BEFORE APPLYING: psql $DATABASE_URL -f migrations/017_starter_codes.sql\n\n")

    failed: list[str] = []
    written = 0

    for i, challenge in enumerate(challenges, 1):
        cid = challenge["id"]
        native_lang = challenge["language"].lower()
        existing_codes: dict[str, str] = dict(challenge.get("starter_codes") or {})

        if native_lang not in existing_codes:
            existing_codes[native_lang] = challenge["starter_code"]

        target_langs = [lang for lang in ALL_LANGUAGES if lang != native_lang]
        print(f"[{i}/{len(challenges)}] {cid} ({native_lang} → {', '.join(target_langs)})", end="  ", flush=True)

        ok = True
        for tgt in target_langs:
            if args.skip_existing and tgt in existing_codes:
                continue
            code = translate_starter_code(model, challenge, tgt)
            if code:
                existing_codes[tgt] = code
            else:
                print(f"\n  FAILED to translate {cid} → {tgt}", file=sys.stderr)
                ok = False

        if ok:
            write_sql(
                [{"challenge_id": cid, "title": challenge["title"], "starter_codes": existing_codes}],
                args.output,
                append=True,
            )
            written += 1
            print("OK")
        else:
            failed.append(cid)
            print("PARTIAL/FAILED")

        time.sleep(1.0)

    print(f"\nWrote {written} UPDATE statements to {args.output}")

    if failed:
        print(f"\nFailed ({len(failed)}): {', '.join(failed)}", file=sys.stderr)
        print(
            "Re-run with --id <challenge_id> --append to retry individual failures.",
            file=sys.stderr,
        )


if __name__ == "__main__":
    main()
