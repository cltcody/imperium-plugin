---
description: Update project documentation to match the current code and verify every count, path, and claim against reality
---

# Update Documentation

Audit and update the project's documentation so it matches what is actually on disk. Run after significant features, restructures, or whenever docs are suspected of drifting. The rule: **every number, path, command, and claim in a doc must be verifiable against the tree.** This is **stack-agnostic**: where a doc claims something a command can confirm (a version, a build step, a route list), resolve that command from the project's `STACK.md` rather than assuming a stack.

## Steps

### 1. Resolve the stack

Read the project's `STACK.md` and resolve commands per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. You'll use it to confirm
doc claims against reality — version numbers, the components and their `working_dir`s, and
any `build`/`dev`/`test` steps a doc references. If there is no `STACK.md`, auto-detect
once from project markers and recommend the user run `/cc:setup:stack` to persist a
manifest.

### 2. Inventory the docs

The standing targets in most projects: `STACK.md`, `CLAUDE.md`, `README.md`, `CHANGELOG.md`, and any in-tree docs (`docs/`, `reference/patterns/`, `${user_config.workspace_dir}/context/`, API/route docstrings). Glob for any other top-level or `docs/` markdown making factual claims.

### 3. Build ground truth from the tree

Compute real counts and lists with Glob/Grep, **not from memory**, against whatever this project actually contains. Common ground-truth sources, used only where they exist:

- Commands / skills / agents — count the files under their directories (`.claude/commands/`, `.claude/skills/`, etc.).
- Services — entries in `docker-compose.yml` / `compose.yaml`, if present.
- Config / env vars — keys in `.env.example` or the project's config schema.
- Modules / feature areas / routes — directories and route declarations per the project's layout (resolve the component layout from `STACK.md`).
- **Version numbers** — read from the project's manifest (`package.json`, `pyproject.toml`, `Cargo.toml`, …) or resolve a `version` step from `STACK.md`; never assume a fixed version.

### 4. Verify claims doc by doc

- **STACK.md** — cross-check every declared component and command against reality: does each `working_dir` exist, and does each mapped step's tool actually resolve in that directory? Cross-check declared services against `docker-compose.yml` / the project's service definitions, and their config against `.env.example`.
- **CLAUDE.md** — directory-structure diagram matches the actual tree; every listed command/script exists; essential commands still run as written; new patterns/constraints since the last update are captured.
- **README.md** — quick-start steps work as written; command examples accurate; any port numbers / URLs match what the app actually serves (resolve the `dev` step from `STACK.md` to confirm); service and feature lists match `STACK.md`.
- **API / route docstrings** — every public endpoint has a description where the framework surfaces it. Find the project's route/endpoint declarations with Grep (the pattern depends on the framework — e.g. decorator-based routers, handler registrations) and confirm each carries a docstring/description.
- **reference/patterns/** (if present) — code examples still match actual code patterns; options now active are noted; missing patterns for newly added components flagged.
- **${user_config.workspace_dir}/context/** (if present) — `architecture.md` and `decisions.md` reflect new services, changed decisions, and structure changes.

### 5. Fix the drift

Update the docs to match reality — never "fix" the code to match the docs without asking. Keep each doc's existing voice and structure; change only what is wrong or missing.

### 6. Cross-reference sweep

Grep the updated docs for links and cross-references (relative links, command names) and confirm each target resolves.

### 7. Report

Produce the audit table (see Output) with the specific corrections made.

## Output

Updated documentation files in place, plus an audit summary. Adapt the rows to whatever docs this project actually has:

```
DOCS AUDIT
──────────
STACK.md:      ✅ current / updated (<what changed>)
CLAUDE.md:     ✅ current / updated (<e.g. command count 38→41>)
README.md:     ✅ current / updated
CHANGELOG.md:  ✅ current / stale → run /cc:release:changelog
API docs:      X/Y endpoints have descriptions
reference/:    ✅ current / <n> files updated
${user_config.workspace_dir}/:       ✅ current / updated

Files updated: <list>
```

## Quality checklist

- [ ] Every count in the docs equals a number computed from the actual tree
- [ ] Every referenced path, command, and script exists
- [ ] Version numbers match the project's manifest / resolved `version` step
- [ ] New features/commands/services added since the last doc update are documented
- [ ] No stale references to removed or renamed content
- [ ] Doc tone and structure preserved — minimal, surgical edits

## Handoff

**Chain:** when part of a release flow, invoke `/cc:release:cleanup` next with the SlashCommand tool if stale content was discovered, otherwise proceed to `/cc:release:commit`.
**Solo:** suggest `/cc:release:commit` to commit the doc updates (`docs: sync documentation with current tree`).
**Abort rules:** docs and code disagree on intended behavior (not just description) → stop and ask the user which is correct before editing either. A claimed feature has no corresponding code at all → flag it rather than silently deleting the claim.
