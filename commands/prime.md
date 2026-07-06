---
description: Load full project context — structure, docs, tooling, and git state — at session start
argument-hint: [--resume]
disable-model-invocation: true
---

# Prime — Load Project Context

Build situational awareness of whatever repository you are in before doing any work. Run at the start of every session, after pulling changes, or whenever context feels stale. Project-agnostic: detect what the project actually is — never assume a stack.

## Steps

1. **Map the structure.** Run `git ls-files` (fall back to a recursive directory listing if not a git repo). Identify top-level layout, main source directories, and test directories.
2. **Read core documentation.** Read `CLAUDE.md`, `LESSONS.md` (or equivalent lessons/conventions file), `README.md` (root and major directories), and any architecture docs (`docs/`, `ARCHITECTURE.md`, `STACK.md`) that exist. Note project rules, constraints, and prior lessons learned. Cross-project engineering rules live at `${CLAUDE_PLUGIN_ROOT}/references/dev/lessons-learned.md` — the project's own `LESSONS.md` holds only project-specific lessons on top of it.
3. **Resolve the tooling.** Read the project's `STACK.md` and resolve the per-component commands per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` — report each component's resolved `install`, `test`, `typecheck`, `lint`, `build`, `dev` as the project's tooling. These are the validation commands every later PIV step will use. If there is no `STACK.md`, auto-detect once from project markers (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Makefile`, `Taskfile.yml`, CI config) and recommend the user run `/cc:setup:stack` to persist a manifest.
4. **Read key files.** Entry points (e.g. `main.py`, `index.ts`, `cmd/`), core config, key model/schema definitions, an important service or controller, and one or two representative modules to absorb conventions (naming, error handling, test style).
5. **Capture current state.** Run `git status --short`, `git branch --show-current`, and `git log --oneline -10`. Note uncommitted work and recent focus.
6. **Check PIV working dirs.** List `${user_config.workspace_dir}/plans/` and `${user_config.workspace_dir}/execution-reports/` if present — note any in-flight plans.

### Stack notes

- Read `STACK.md` first — its `components:` map is the single source of truth for which
  components are active and the concrete command each abstract step resolves to.
- Run each component's commands from that component's `working_dir`. For monorepos, report
  the tooling per component (e.g. `backend (uv)` / `frontend (npm)`).
- If `STACK.md` is missing, detect tooling once from project markers and recommend
  `/cc:setup:stack` to persist a manifest — never hardcode a stack assumption.
- If `STACK.md` **is** present, do a cheap drift heuristic (not a full re-detection — prime
  must stay fast): compare its `components:` map against the marker files currently visible
  (`package.json` + lockfile, `pyproject.toml`, `manage.py`, monorepo roots). If a marker
  implies a component or package manager the manifest doesn't reflect, print one line:
  "STACK.md may be stale (markers changed since generation) — run `/cc:setup:stack --check`."

### Resuming a session

`/cc:pause` writes `${user_config.workspace_dir}/session.md` — a small cursor (branch, where work stopped,
in-flight files, open threads, next action) — before a session ends. `/cc:prime` reads it back:

- **`$ARGUMENTS` contains `--resume`:** read `${user_config.workspace_dir}/session.md` *before* step 1. Scope
  the rest of the steps to what it references (its branch, the plan/review docs it links, the
  files it names) rather than the full repo. Verify its claims against current reality
  (`git status --short`, `git log -1`) instead of re-deriving from scratch, and flag anything it
  claims that no longer holds (a branch that's gone, a file it names that's been deleted). End by
  restating session.md's "Next action" verbatim and offering to continue it — via the
  SlashCommand tool if the user confirms, otherwise waiting for the go-ahead.
- **`--resume` not passed but `${user_config.workspace_dir}/session.md` exists:** run the normal steps above,
  and add one line to the Project Brief noting the paused session exists and that
  `/cc:prime --resume` will load it — don't read its contents unprompted.

## Output

A concise Project Brief in the conversation (no file written):

- **Project** — purpose, type of application
- **Stack** — languages, frameworks, package manager, test framework (from `STACK.md` components, or detected)
- **Validation commands** — resolved per-component commands for test / lint / typecheck / build (the `STACK.md` map, or detected)
- **Architecture** — key directories, patterns, conventions observed
- **State** — branch, last commit, uncommitted changes, in-flight plans
- **Concerns** — anything that looks off

## Quality checklist

- [ ] Validation commands are real — resolved from `STACK.md` (or detected from project files), not guessed
- [ ] CLAUDE.md (or equivalent rules file) read and constraints noted
- [ ] Git state captured: branch, status, recent commits
- [ ] Brief is scannable — headers and bullets, no prose walls
- [ ] In-flight plans in `${user_config.workspace_dir}/plans/` surfaced if any exist

## Handoff

**Chain:** when running inside a PIV chain (`/cc:piv:loop`), immediately invoke `/cc:plan:feature` with the feature description via the SlashCommand tool — do not ask.
**Solo:** end by asking what to build or fix, and suggest `/cc:plan:feature` for features, `/cc:plan:task` for small changes, or `/cc:verify:rca` for bugs.
**Abort rules:** if the directory is not a code project (no source files, no manifest), report that and stop — do not fabricate a brief.
