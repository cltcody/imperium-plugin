---
description: Detect the current project's stack and generate an editable STACK.md the dev commands read
argument-hint: "[optional: path to project root] [--check]"
---

# Setup: Project Stack

Generate a root-level `STACK.md` for the current project (or `$ARGUMENTS` if a path is
given). cc's dev commands read this manifest to resolve abstract steps (`test`, `typecheck`,
`lint`, …) into concrete shell commands — see
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` for the schema and vocabulary.

## Steps

### 1 — Detect components

Inspect the project root (and obvious subdirs) for stack markers. A monorepo may yield
**multiple components** — emit one per root.

- **JS/TS** — `package.json`. Package manager from lockfile (`package-lock.json`→npm,
  `pnpm-lock.yaml`→pnpm, `yarn.lock`→yarn, `bun.lockb`→bun) or the `packageManager` field.
  Framework from deps/config: `next.config.*` or `next` dep → Next.js; `expo` dep → Expo/RN;
  `vite` → Vite.
- **Python** — `pyproject.toml`. Runner from `uv.lock`→uv, `poetry.lock`→poetry, else pip.
- **Django** — `manage.py`.
- **FastAPI** — `app/main.py` + a uvicorn/fastapi dep.
- **Monorepo** — `backend/`+`frontend/`, `apps/*`, or workspace globs → multiple components.

### 2 — Build each component's command map

For each detected component, fill the step vocabulary. **Prefer the project's real
commands** over guesses:

- JS/TS: read `package.json` `scripts` for `test`/`lint`/`typecheck`/`build`/`dev`. If a
  `typecheck` script is absent but `typescript` is a dep, use `npx tsc --noEmit`.
- Python: detect pytest vs `manage.py test`; mypy/pyright; ruff/flake8; alembic vs
  `manage.py migrate`.

Use the seed profiles in `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-profiles/`
(`nextjs`, `expo-rn`, `django`, `fastapi`, `generic-node`, `generic-python`) as the
starting shape, then overwrite with what you actually found.

### 3 — Write STACK.md

Write `STACK.md` to the project root using the frontmatter schema in
`stack-resolution.md`: `stack:` label + `components:` map, each with `language`,
`package_manager`, `working_dir`, and a `commands:` block. Add a short human-readable
body documenting the stack and any gotchas.

**Do not overwrite an existing STACK.md without showing a diff and confirming.**

### 4 — Show and confirm

Print the generated manifest. Call out any step you could **not** confidently map (left
blank or guessed) and ask the user to verify. Note that unmapped steps are skipped by
commands, so leaving a step blank is safe.

### 5 — Sanity-check (optional)

Offer to run the `smoke` and `test` steps once to confirm they actually work, then report
results.

### 6 — Front end? (optional pointer)

If the project has a UI (HTML templates, React/Vue/Tailwind, etc.), mention it once:
"Building UI here? Run `/cc:setup:design` to apply your brand to the generic design system,
then the `design-system` skill can generate on-brand components." Don't act on it — just
point.

## Check mode (`--check`)

If `$ARGUMENTS` contains `--check`, skip Steps 1–6's generate/write flow entirely and run a
**read-only drift check** instead — this is the mode CI or a `piv:ship` phase gate calls to
confirm an existing `STACK.md` still matches reality.

1. **Re-detect.** Re-run Step 1's detection pass fresh against current project markers
   (`package.json` + lockfile, `pyproject.toml` + lockfile, `manage.py`, `app/main.py`,
   monorepo roots) — same rules, but held in memory, never written anywhere.
2. **Load the existing manifest.** Read the current `STACK.md` frontmatter: its
   `components:` map, each component's `commands:` block, and its `class:` field if present.
3. **Diff and report** (never fix — see below):
   - **Missing new components** — a root detected now (step 1) that has no entry in
     `STACK.md`'s `components:` map.
   - **Steps whose underlying scripts vanished** — a mapped command that reads from
     `package.json` `scripts` or an equivalent source where that script/file no longer
     exists (e.g. `commands.test` still says `npm run test:unit` but that script was
     removed).
   - **Changed package managers** — the component's `package_manager:` field no longer
     matches the lockfile actually present (e.g. manifest says `npm`, repo now has
     `pnpm-lock.yaml`).
   - **`class:` mismatches** — compare a fresh classification pass (remote-host rules,
     `references/dev/repo-classification.md`) against the existing `class:` field. **Report
     only, never edit.** Per that file's "The `class:` field and override semantics" (rule
     1): an explicit `class:` in `STACK.md` always wins, and drift checks may report a
     mismatch but must never change or second-guess it.
4. **Print a summary report**, one line per finding, e.g.:

   ```
   STACK.md drift check — <project>
     components:      backend ✓  frontend ✓  docs ⚠ NEW (detected, not in STACK.md)
     scripts:         frontend.build → `npm run build` MISSING from package.json ✗
     package_manager: frontend: STACK.md says npm, lockfile says pnpm ✗
     class:           STACK.md says personal, remote detection says corporate ⚠ (report-only — not changed)
   Result: DRIFT — 3 finding(s). Exit 1.
   ```

   Clean run:

   ```
   STACK.md drift check — <project>
     components:      backend ✓  frontend ✓
     scripts:         all mapped commands present ✓
     package_manager:  matches lockfiles ✓
     class:           no STACK.md/detection mismatch ✓
   Result: CLEAN — no drift. Exit 0.
   ```
5. **Exit semantics** (scriptable): no drift found → **exit 0**. Any finding in category 3
   → **exit nonzero** (1) with the summary above on stdout/stderr, so CI or a `piv:ship`
   phase gate can consume the exit code without parsing prose.
6. **`--check` never writes.** It does not touch `STACK.md`, does not create files, and
   makes no edits — not even to fix an obvious drift. **To fix drift, re-run `/cc:setup:stack`
   normally** (without `--check`): that path still applies Step 3's rule (don't overwrite an
   existing `STACK.md` without showing a diff and confirming) and still preserves any
   `class:` field already present, exactly as it does today.

## Output

- `STACK.md` at the project root.
- A summary of detected components and the command map, with anything uncertain flagged.
- In `--check` mode: no file output — a drift report printed to the conversation, and an
  exit code (0 clean / nonzero drift) for scriptable callers.
