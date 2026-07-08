---
description: Generate or repair a CI pipeline (GitHub Actions or Azure DevOps) that mirrors the project's STACK.md verify gate
argument-hint: "[--forge github|ado]"
size-budget: exempt — embeds complete GitHub Actions + Azure DevOps pipeline templates
---

# Setup: CI Pipeline

Generate — or repair — a CI workflow that is a **mechanical projection of `STACK.md`**: one
job per component, running that component's mapped `install → smoke → test → typecheck →
lint → format:check → build` steps from its `working_dir`. This is the same step vocabulary
`/cc:verify:run` resolves locally (see
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`) — CI should never drift from what
the dev commands already check on the machine. This command is **stack-agnostic and
forge-agnostic**: it never hardcodes a toolchain or a CI provider.

## Steps

### 1 — Resolve the stack

Read the project's `STACK.md` and resolve components per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. If there is no `STACK.md`,
auto-detect once (same live-detection table as the other dev commands).

**Abort rule:** if there is no `STACK.md` **and** auto-detection finds no component (no
`package.json`, `pyproject.toml`, `manage.py`, etc. anywhere in the project), stop here and
route the user to `/cc:setup:stack` — do not fabricate a workflow with nothing to run. If
auto-detection *does* find components but no manifest exists yet, proceed using the detected
components for this run and recommend persisting them with `/cc:setup:stack` afterward (same
contract every other dev command uses).

### 2 — Detect the forge

Default target file:

| Forge | Target file |
|-------|-------------|
| GitHub | `.github/workflows/validate.yml` |
| Azure DevOps | `azure-pipelines.yml` (repo root) |

Detect from the git remote, unless `--forge github` / `--forge ado` is passed (always wins,
no detection needed):

```bash
case "$(git remote get-url origin 2>/dev/null)" in
  *github.com*) forge=github ;;
  *dev.azure.com*|*visualstudio.com*|*ssh.dev.azure.com*) forge=ado ;;
  *) forge= ;;
esac
```

If detection is empty or ambiguous (no `origin`, an unrecognized host, a proxy/mirror URL,
multiple remotes pointing at different forges), **ask the user** which forge to target rather
than guessing — don't default silently to GitHub.

### 3 — Determine mode: generate or repair

Check whether the target file already exists.
- **Missing** → generate mode (Step 5 writes a fresh file).
- **Exists** → repair mode (Step 6): diff, don't clobber.

### 4 — Map each component to a job

For each `STACK.md` component, in declared order, build one job:

- **Job id / name**: the component name (e.g. `backend`, `frontend`).
- **Working directory**: the component's `working_dir` (GitHub: `defaults.run.working-directory`;
  Azure DevOps: `workingDirectory` on each step).
- **Steps, in order, skipping anything unmapped**:

  | Order | Step | Notes |
  |-------|------|-------|
  | 1 | `install` | Dependency install, if mapped (nearly always is) |
  | 2 | `smoke` | Fail-fast check |
  | 3 | `test` | Full suite |
  | 4 | `typecheck` | Static types |
  | 5 | `lint` | Linter |
  | 6 | `format:check` | Formatter, check mode only — never `format` (auto-fix) in CI |
  | 7 | `build` | Production build |

  This mirrors `/cc:verify:run`'s local gate (`smoke → test → typecheck → lint → format:check`)
  plus `install` at the front and `build` at the end, since CI also needs to prove the app
  installs from a clean checkout and produces a deployable artifact. A component that maps
  none of these (rare) gets no job — note it and move on.

- **Runtime setup + dependency caching**, keyed off the component's `package_manager`:

  | `package_manager` | GitHub Actions setup | Azure DevOps setup | Cache key source |
  |--------------------|----------------------|---------------------|-------------------|
  | `npm` | `actions/setup-node@v4` (`cache: npm`) | `NodeTool@0` + `Cache@2` | `package-lock.json` |
  | `pnpm` | `pnpm/action-setup@v4` then `actions/setup-node@v4` (`cache: pnpm`) | `NodeTool@0` + `Cache@2` | `pnpm-lock.yaml` |
  | `yarn` | `actions/setup-node@v4` (`cache: yarn`) | `NodeTool@0` + `Cache@2` | `yarn.lock` |
  | `bun` | `oven-sh/setup-bun@v2` | `Cache@2` (manual) | `bun.lockb` |
  | `uv` | `astral-sh/setup-uv@v3` (`enable-cache: true`) | `Cache@2` (manual, `$(UV_CACHE_DIR)`) | `uv.lock` |
  | `poetry` | `actions/setup-python@v5` (`cache: poetry`, after installing poetry) | `UsePythonVersion@0` + `Cache@2` | `poetry.lock` |
  | `pip` | `actions/setup-python@v5` (`cache: pip`) | `UsePythonVersion@0` + `Cache@2` | `requirements*.txt` |
  | gradle (Java) | `actions/setup-java@v4` + `gradle/actions/setup-gradle@v4` | `JavaToolInstaller@0` + `Gradle@3` | `*.gradle*`/`gradle.lock` |

  Scope every cache key to the component's `working_dir` (e.g.
  `cache-dependency-path: backend/uv.lock`) so a monorepo's components don't cross-pollinate
  cache keys.

- **Runtime version — matrix only when STACK.md says so.** `STACK.md` doesn't require a
  runtime-version field; this command reads an **optional** `versions:` list on a component if
  present (e.g. `versions: [18, 20, 22]` on a Node component) and builds a matrix over it. If
  absent (the common case), resolve a **single** version from the project's real version file —
  `.nvmrc` / `package.json engines.node` (Node), `.python-version` / `pyproject.toml
  requires-python` (Python), `.java-version` / Gradle `sourceCompatibility` (Java) — falling
  back to a current LTS only if nothing is declared. Never build a matrix speculatively; it
  slows every run for a guess nobody asked for.

- **No secrets for the base gate.** Don't add `secrets:`/pipeline variable references. If a
  step looks like it needs one (a `test`/`smoke` command reads `DATABASE_URL`, hits a real
  service, etc.), leave a `# TODO:` comment next to that step naming what's missing instead of
  inventing a credential or a service container — that's a follow-up for the user, not this
  command's job to guess at.

### 5 — Generate mode: render the workflow

Trigger on push to the **default branch** (detect via
`git symbolic-ref refs/remotes/origin/HEAD` stripped to a branch name, falling back to asking
if that fails — don't assume `main`) plus all pull requests. Set a job-level timeout (default
20 minutes; bump for a component with a visibly heavy suite). Mark the file as owned by this
command with a header comment naming the managed job ids — repair mode (Step 6) reads this
back to know which jobs it's allowed to touch.

**GitHub Actions** (`.github/workflows/validate.yml`) — example for a `uv` backend + `npm`
frontend monorepo:

```yaml
name: Validate

# Managed by /cc:setup:ci — job ids: backend, frontend.
# Edit STACK.md and re-run /cc:setup:ci to update these jobs. Other jobs in this file
# (e.g. deploy) are left alone by that command.

on:
  push:
    branches: [main]
  pull_request:

jobs:
  backend:
    name: backend (uv)
    runs-on: ubuntu-latest
    timeout-minutes: 20
    defaults:
      run:
        working-directory: backend
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v3
        with:
          enable-cache: true
          cache-dependency-glob: backend/uv.lock
      - run: uv sync                          # install
      - run: uv run python manage.py check     # smoke
      - run: uv run pytest -v                  # test
      - run: uv run mypy .                     # typecheck
      - run: uv run ruff check .               # lint
      - run: uv run ruff format --check .      # format:check

  frontend:
    name: frontend (npm)
    runs-on: ubuntu-latest
    timeout-minutes: 20
    defaults:
      run:
        working-directory: frontend
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
          cache-dependency-path: frontend/package-lock.json
      - run: npm ci                # install
      - run: npm test               # test
      - run: npm run typecheck      # typecheck
      - run: npm run lint           # lint
      - run: npm run build          # build
```

**Azure DevOps** (`azure-pipelines.yml`) — same monorepo:

```yaml
# Managed by /cc:setup:ci — job ids: backend, frontend.
# Edit STACK.md and re-run /cc:setup:ci to update these jobs. Other jobs in this file
# (e.g. deploy stages) are left alone by that command.

trigger:
  branches:
    include: [main]

pr:
  branches:
    include: [main]

jobs:
  - job: backend
    displayName: 'backend (uv)'
    pool:
      vmImage: ubuntu-latest
    timeoutInMinutes: 20
    steps:
      - script: |
          curl -LsSf https://astral.sh/uv/install.sh | sh
          echo "$HOME/.local/bin" >> "$PATH"
        displayName: Install uv
      - task: Cache@2
        inputs:
          key: 'uv | "$(Agent.OS)" | backend/uv.lock'
          path: $(UV_CACHE_DIR)
        displayName: Cache uv packages
      - script: uv sync
        displayName: install
        workingDirectory: backend
      - script: uv run python manage.py check
        displayName: smoke
        workingDirectory: backend
      - script: uv run pytest -v
        displayName: test
        workingDirectory: backend
      - script: uv run mypy .
        displayName: typecheck
        workingDirectory: backend
      - script: uv run ruff check .
        displayName: lint
        workingDirectory: backend
      - script: uv run ruff format --check .
        displayName: format:check
        workingDirectory: backend

  - job: frontend
    displayName: 'frontend (npm)'
    pool:
      vmImage: ubuntu-latest
    timeoutInMinutes: 20
    steps:
      - task: NodeTool@0
        inputs:
          versionSpec: '20.x'
      - task: Cache@2
        inputs:
          key: 'npm | "$(Agent.OS)" | frontend/package-lock.json'
          path: $(npm_config_cache)
        displayName: Cache npm packages
      - script: npm ci
        displayName: install
        workingDirectory: frontend
      - script: npm test
        displayName: test
        workingDirectory: frontend
      - script: npm run typecheck
        displayName: typecheck
        workingDirectory: frontend
      - script: npm run lint
        displayName: lint
        workingDirectory: frontend
      - script: npm run build
        displayName: build
        workingDirectory: frontend
```

Adapt job count, package_manager-specific setup, and step lists to whatever `STACK.md` (or
auto-detection) actually found — the examples above are illustrative, not literal output for
every project. A single-component project gets a single job.

### 6 — Repair mode: diff, don't clobber

If the target file already exists:

1. **Read the managed-job-ids header comment.** If present, only those job ids are this
   command's to touch. If absent (a hand-written file, or one from before this convention
   existed), treat any job whose id exactly matches a current `STACK.md` component name as
   managed, say so explicitly, and offer to add the header comment going forward. Every other
   job (`deploy`, `release`, a hand-rolled `lint-docs`, …) is **never** read, diffed, or
   modified, regardless of what it contains.
2. **Regenerate the expected job** for each `STACK.md` component (Steps 4-5) and diff it
   against the current managed job with that id, step by step.
3. **Classify the diff:**
   - **No managed jobs differ, and every `STACK.md` component has a matching managed job** →
     **in sync** — report that and change nothing (see Idempotence below).
   - **A managed job's steps differ** (a step added/removed/changed because `STACK.md`
     changed) → propose replacing just that job's step list, in place.
   - **A `STACK.md` component has no managed job yet** → propose **adding** a new managed job,
     appended after the existing managed jobs.
   - **A managed job's component no longer exists in `STACK.md`** → propose **removing** that
     job. Flag this one separately as destructive and get an explicit yes/no on it, even inside
     the general confirmation gate in Step 7.
4. Produce the **minimal patch** — only the managed jobs that actually changed, leaving
   unrelated file content (unmanaged jobs, comments, `env:`/variable blocks the user added)
   byte-for-byte untouched.

**Idempotence:** running this command again against an up-to-date, in-sync workflow must
report "in sync" and write nothing — no reordering, no re-formatting, no touching unmanaged
content. If a re-run would produce a diff on a file it generated unmodified, that's a bug in
the render logic, not a real change to propose.

### 7 — Show and confirm

CI files are trust-sensitive — they run with repo permissions and, in generate mode, replace
whatever gate (or lack of one) currently guards merges. **Always** show the full generated (or
patched — as a diff) YAML in a fenced ```yaml block and get explicit user confirmation before
writing anything. Never write silently, even when the change looks obviously correct.

### 8 — Write and report

On confirmation, write the file (generate mode) or apply the patch (repair mode). Report what
happened per component.

## Output

```
CI SETUP — .github/workflows/validate.yml (GitHub, generate)
──────────────────────────────────────────────────────────────
backend  (uv)   install → smoke → test → typecheck → lint → format:check   cache: uv.lock
frontend (npm)  install → test → typecheck → lint → build                  cache: package-lock.json
                (frontend has no smoke/format:check mapped — skipped)

Trigger: push→main, pull_request     Timeout: 20m/job     Matrix: none (single runtime/job)
Secrets required: none

[full YAML shown above, confirmed]
Written: .github/workflows/validate.yml
```

Repair mode instead reports **in sync** (no write) or a **before/after diff per managed job**
plus which unmanaged jobs were left alone.

## Quality checklist

- [ ] Every `STACK.md` component has a job (or its absence from CI is explicitly stated)
- [ ] Each job runs only its component's *mapped* steps, in `install → smoke → test →
      typecheck → lint → format:check → build` order — no step invented, none silently dropped
- [ ] Each job's working directory matches the component's `working_dir`
- [ ] Dependency caching is wired for every component's `package_manager`, scoped to its
      `working_dir`/lockfile
- [ ] Matrix present only if `STACK.md` declares multiple `versions:` — never speculative
- [ ] No secrets/credentials referenced or fabricated
- [ ] Repair mode: unmanaged jobs (deploy, etc.) byte-for-byte untouched; destructive removals
      confirmed separately
- [ ] Re-running against an in-sync file changes nothing
- [ ] Full YAML (or diff) shown and confirmed before any write

## Handoff

**Chain:** After writing (or confirming in-sync), suggest `/cc:verify:run` to confirm the
local gate actually passes before pushing — a CI file that mirrors a currently-red local gate
just moves the failure somewhere slower to see.

**Solo:** Report what was written (or that the file was already in sync) and point at the
target file path. If the user is missing a forge account/permissions to actually run it (e.g.
no Actions enabled, no ADO pipeline created yet), say so — this command only writes the file.

**Abort rules:** No `STACK.md` and auto-detection finds no component → stop and route to
`/cc:setup:stack`; do not generate an empty or fabricated workflow. Forge detection ambiguous
with no `--forge` override → ask, don't guess. User declines the Step 7 confirmation → stop,
write nothing.
