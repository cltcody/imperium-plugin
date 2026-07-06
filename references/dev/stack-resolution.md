# Stack Resolution

How cc dev commands turn **abstract steps** (`test`, `typecheck`, `lint`, …) into the
**concrete shell commands** for the current project. Every dev command references this
file instead of hardcoding a stack. The single source of truth for a project is its
root-level `STACK.md`.

---

## Step vocabulary

Commands ask for steps by these canonical names. A project maps each to a real command;
**unmapped steps are skipped silently** (not an error).

| Step | Meaning |
|------|---------|
| `install` | Install dependencies |
| `smoke` | Cheap fail-fast that proves the app loads (import check / type-check / `manage.py check`) |
| `test` | Full test suite |
| `test:unit` / `test:integration` | Split suites (optional) |
| `typecheck` | Static type checking |
| `lint` | Linter |
| `format:check` | Formatter in check mode |
| `build` | Production build |
| `dev` | Start the app / dev server |
| `migrate` | Apply database migrations |
| `coverage` | Test run with coverage report |

---

## The `STACK.md` manifest

Lives at the **target project's** root (not in the cc plugin). YAML frontmatter holds the
machine-readable command map; the body holds human notes. Single- and multi-component
(monorepo) projects are both supported via the `components:` map.

```markdown
---
stack: django + nextjs
components:
  backend:
    language: python
    package_manager: uv          # uv | poetry | pip
    working_dir: backend
    commands:
      smoke:     uv run python manage.py check
      test:      uv run pytest -v
      typecheck: uv run mypy .
      lint:      uv run ruff check .
      format:check: uv run ruff format --check .
      migrate:   uv run python manage.py migrate
      dev:       uv run python manage.py runserver
  frontend:
    language: typescript
    package_manager: npm          # npm | pnpm | yarn | bun
    working_dir: frontend
    commands:
      test:      npm test
      typecheck: npm run typecheck
      lint:      npm run lint
      build:     npm run build
      dev:       npm run dev
---

# Project Stack
Notes on architecture, gotchas, and why these commands were chosen.
```

A single-stack project has just one component:

```markdown
---
stack: expo-react-native
components:
  app:
    language: typescript
    package_manager: npm
    working_dir: .
    commands:
      smoke:     npx tsc --noEmit
      test:      npm test
      typecheck: npx tsc --noEmit
      lint:      npm run lint
      dev:       npx expo start
---
```

---

## Resolution algorithm

When a command needs steps `[s1, s2, …]`:

1. **Locate the manifest.** Read `STACK.md` at the project root (walk up from the working
   directory if needed).
2. **If `STACK.md` exists:** for each `component` (in declared order), `cd` into its
   `working_dir` and run each requested step's command **if mapped**. Skip unmapped steps.
3. **If `STACK.md` is missing:** fall back to **live auto-detection** (table below) for a
   single run, and recommend the user run `/cc:setup:stack` to persist a manifest.
4. **Never hardcode** a stack assumption. If a step can't be resolved or detected, say so
   and ask the user rather than guessing.

### Multi-component behavior

Run **all** components and **aggregate** — do not stop at the first component's failure.
Report results per component, e.g.:

```
Validation — STACK.md (django + nextjs)
  backend  (uv)   smoke ✓  test ✓  typecheck ✗ (3 errors)  lint ✓
  frontend (npm)  test ✓   typecheck ✓  lint ✓  build ✓
Result: FAIL — backend typecheck
```

For an explicit fail-fast (e.g. `verify:run`'s `smoke` gate), run `smoke` for every
component first; abort only if a `smoke` step fails.

---

## Live auto-detection (fallback when no `STACK.md`)

Infer a component from these markers. Prefer the project's **real** scripts over defaults
(e.g. read `package.json` `scripts` rather than assuming).

| Marker | Stack | package_manager | Notes |
|--------|-------|-----------------|-------|
| `package.json` | JS/TS | lockfile: `package-lock.json`→npm · `pnpm-lock.yaml`→pnpm · `yarn.lock`→yarn · `bun.lockb`→bun (or `packageManager` field) | Use `scripts.{test,lint,typecheck,build,dev}` when present; else `npx tsc --noEmit`, etc. |
| `next.config.*` | Next.js | — | `dev`→`next dev`, `build`→`next build` |
| `expo` in deps | Expo / React Native | — | `dev`→`expo start` |
| `pyproject.toml` | Python | `uv.lock`→uv · `poetry.lock`→poetry · else pip | test=pytest if present; typecheck=mypy/pyright; lint=ruff/flake8 |
| `manage.py` | Django | (python rules above) | `smoke`→`manage.py check`, `migrate`→`manage.py migrate`, `dev`→`manage.py runserver` |
| `app/main.py` + uvicorn dep | FastAPI | uv | `smoke`→import app, `dev`→`uvicorn app.main:app` |

**Monorepo:** if multiple roots match (`backend/`+`frontend/`, `apps/*`, npm/pnpm
workspaces), emit one component per root.

Bundled seed profiles for these stacks live in
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-profiles/`.
