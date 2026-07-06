# Project Stack Setup

cc's dev commands (`/cc:verify:*`, `/cc:implement:*`, `/cc:release:*`, `/cc:plan:*`, etc.)
are **stack-agnostic**. Instead of hardcoding `npm test` or `uv run pytest`, they resolve
**abstract steps** (`test`, `typecheck`, `lint`, `build`, `dev`, `migrate`, …) from a
per-project manifest: a `STACK.md` at your project root.

> Note: this is the *project's* `STACK.md` (its tech stack). It is unrelated to the cc
> plugin's own `INVENTORY.md` (the command/skill inventory) — different file, different repo.

## Quick start

In any project, run:

```
/cc:setup:stack
```

It detects your stack (package.json scripts, lockfiles, pyproject.toml, manage.py,
monorepo layout), writes a best-guess `STACK.md`, and shows it to you for editing.

## What gets written

A `STACK.md` with YAML frontmatter mapping steps to real commands. Single-stack example
(Expo/React Native):

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

Monorepo example (Django + Next.js):

```markdown
---
stack: django + nextjs
components:
  backend:
    language: python
    package_manager: uv
    working_dir: backend
    commands:
      smoke:     uv run python manage.py check
      test:      uv run pytest -v
      typecheck: uv run mypy .
      lint:      uv run ruff check .
      migrate:   uv run python manage.py migrate
      dev:       uv run python manage.py runserver
  frontend:
    language: typescript
    package_manager: npm
    working_dir: frontend
    commands:
      test:      npm test
      typecheck: npm run typecheck
      lint:      npm run lint
      build:     npm run build
      dev:       npm run dev
---
```

## The step vocabulary

| Step | When commands use it |
|------|----------------------|
| `install` | Setting up deps |
| `smoke` | Fast fail-fast before the full suite (import/type-check/`manage.py check`) |
| `test` (`test:unit`, `test:integration`) | Running tests |
| `typecheck` | Type checking |
| `lint` | Linting |
| `format:check` | Formatter check |
| `build` | Production build (release flow) |
| `dev` | Starting the app/server |
| `migrate` | DB migrations |
| `coverage` | Coverage reports |

**Unmapped steps are skipped** — only define the ones your project has.

## Editing by hand

Copy a seed profile from the plugin's `references/dev/stack-profiles/` (`nextjs`,
`expo-rn`, `django`, `fastapi`, `generic-node`, `generic-python`) into a `STACK.md`
`components:` entry and adjust. Multi-component projects list several entries; commands run
each step from that component's `working_dir` and aggregate the results.

## How commands resolve it

Full algorithm: `references/dev/stack-resolution.md`. In short — a command needing
`smoke → test → typecheck → lint` reads your `STACK.md`, runs each mapped command per
component from its `working_dir`, skips unmapped steps, and reports per component. With no
`STACK.md`, it auto-detects once and suggests running `/cc:setup:stack`.
