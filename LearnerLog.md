# Learner Log

A running record of bugs caught, ideas produced, and architectural insights from building Cr4ck.

---

## Bugs Found

### Angular `[innerHTML]` + `ViewEncapsulation.Emulated` = styles never apply
**Date:** 2026-04-22
Angular's default `Emulated` encapsulation stamps a unique attribute (e.g. `_ngcontent-xyz`) onto every template element and rewrites CSS selectors to match only those elements. Content injected via `[innerHTML]` does not get the attribute — so component-scoped styles are completely invisible to it. `::ng-deep` and `!important` both fail because Tailwind Preflight's `color: inherit` cascade wins regardless. **Fix:** `ViewEncapsulation.None` on the component makes its CSS global, reaching injected nodes.

### Tailwind v4 Preflight cascades `color: inherit` through everything
**Date:** 2026-04-22
`@import 'tailwindcss'` in `styles.css` pulls in Preflight, which resets all elements to `color: inherit`. Combined with `text-gray-300` on the root sandbox wrapper, every descendant — including `[innerHTML]` nodes — inherits `gray-300` and ignores any class-level `color` declaration that doesn't carry `!important` or land in global CSS after Preflight. Lesson: for dynamically injected HTML, either use `ViewEncapsulation.None` or set color via inline `style=` on the container.

### 96 challenge descriptions are placeholder text
**Date:** 2026-04-22
`004_backfill_challenges.sql` has 96 entries with the generic description `"Design an object‑oriented system modeling scenario #N. Focus on encapsulation, inheritance, and polymorphism."` — visible verbatim in the sandbox now that markdown rendering is live. The `generate_starter_codes.py` pattern (Claude + SQL backfill) can fix this; tracked in CLAUDE.md Known Issues.

---

## Ideas

### Backfill descriptions with Claude (like starter codes)
**Date:** 2026-04-22
The `generate_starter_codes.py` script pattern works well for bulk AI backfills: paginate challenges, call Claude per record, write `UPDATE` SQL, apply via migration. Same approach should be used to generate proper **Requirements** / **Constraints** descriptions for the 96 placeholder challenges. Weekly rotation / topic awareness from the daily challenge prompt can seed the style guide for consistency.

### `ViewEncapsulation.None` as the right default for IDE-like components
**Date:** 2026-04-22
Components that render rich user content (markdown, code, dynamic HTML) should default to `ViewEncapsulation.None` so their prose/code styles reach injected nodes without workarounds. Worth noting in CLAUDE.md for any future rich-content components.

### Adversarial code review caught 3 real issues before merge
**Date:** 2026-04-22
Running `/codex:adversarial-review` on `generate_starter_codes.py` before applying the migration surfaced: (1) unexecutable languages exposed in the runner, (2) raw Gemini output accepted without validation, (3) full-blob JSONB overwrites clobbering manual edits. All three logged in CLAUDE.md Known Issues. Good habit: run adversarial review on any script that bulk-writes to production DB.
