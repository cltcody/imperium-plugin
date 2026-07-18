---
description: Initialize a new project or claim an existing one — scaffold basics, install dependencies, start services, prove a green baseline
argument-hint: [project-name or feature-goal]
---

# Setup

Bootstrap a project so the PIV loop has solid ground to stand on: verify or scaffold repo basics, install the environment, bring up any baseline services, and prove everything works by reaching a first GREEN `/cc:verify:run`. Run once when starting a new project or when claiming an existing codebase for PIV work.

It is **stack-agnostic**: the concrete install and baseline commands come from the project's `STACK.md`, not from this file.

## Steps

### 1. Resolve the stack

Read the project's `STACK.md` and resolve commands per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. Setup uses the `install` step
to build the environment and the verify steps (`smoke → test → typecheck → lint`) per
component to prove the green baseline.

If there is **no `STACK.md`**, this command pairs naturally with `/cc:setup:stack` —
recommend the user run it first to detect the stack and persist a manifest. You may
auto-detect once (per the resolution spec) to get moving, but a claimed or new project
should end with a `STACK.md` so every future session starts informed.

### 2. Assess the starting point

Inspect the working directory: is this an empty/new project, or an existing codebase being claimed? Check for a git repo (`git status`), the manifests that `STACK.md` / auto-detection key off (per the resolution spec), CI config, and existing docs. If no project name/description is known and one is needed, ask.

### 3. Scaffold or verify repo basics

Create whatever is missing — never overwrite what exists:
- Git repo initialized (`git init` if absent), sensible `.gitignore` for the detected stack (env files, build output, caches, IDE dirs).
- `README.md` stub with name, one-line description, and how to run (only if no README exists).
- `CLAUDE.md` stub: stack summary, key commands (test/lint/build/run), and a pointer to `${user_config.workspace_dir}/plans/` as the planning dir.
- PIV working dirs: `${user_config.workspace_dir}/plans/`, `${user_config.workspace_dir}/execution-reports/`, `${user_config.workspace_dir}/code-reviews/`, `${user_config.workspace_dir}/system-reviews/`, `${user_config.workspace_dir}/reports/`.
- If a component reference library resolves for this project's stack (per `${CLAUDE_PLUGIN_ROOT}/references/dev/component-reference-library.md`), mention it in the CLAUDE.md stub's key-commands section as the first stop for form/auth/data/shell UI work — one line, no copying at this stage (`/cc:setup:project` owns the copy offer).

### 4. Install the environment

Run each component's `install` step, resolved from `STACK.md` (or auto-detection) per the
resolution spec — do not assume a package manager or runtime. For each component, run
`install` from its `working_dir`. Verify the required runtime version declared by the
project (e.g. `.nvmrc`, `.python-version`, `rust-toolchain.toml`, `global.json`) is
available before installing.

### 5. Configure environment variables

If `.env.example` (or equivalent) exists and `.env` does not: copy it, then walk through each var, filling sane local defaults and flagging the ones the user must supply (API keys, connection strings). Never invent secrets; confirm `.env` is gitignored.

### 6. Start baseline services — only those the project actually uses

If `docker-compose.yml`/`compose.yaml` exists: start the service dependencies (DB, cache, queue) and verify they are healthy (`docker compose ps`). If the project maps a `migrate` step in `STACK.md`, run it to apply pending migrations (see `/cc:implement:migrate` for tool detection). Skip this step entirely for projects with no services.

### 7. Prove the baseline

Run `/cc:verify:run` to execute the project's full gate suite. This runs the verify steps
(`smoke → test → typecheck → lint → format:check`) per component, resolved from `STACK.md`.
The setup is not done until verify reports GREEN — or every RED is explained and accepted by
the user as a pre-existing condition of a claimed codebase.

### 8. Record the result

Ensure `STACK.md` reflects the resolved install/baseline commands (run `/cc:setup:stack` if
it does not yet exist), and append the detected stack, install commands, and service startup
steps to the `CLAUDE.md` stub so every future session starts informed.

## Output

A working development environment: repo basics in place, dependencies installed, services running (if any), `${user_config.workspace_dir}/` dirs created, `STACK.md` describing the stack, `CLAUDE.md` summarizing it, and a GREEN validation baseline confirmed in the conversation. No plan file is written.

> **Front-end projects:** once the baseline is green, if the project has (or will have) a UI,
> point the user to `/cc:setup:design` to apply their brand to the generic design system; the
> `design-system` skill then generates on-brand components. Optional — don't run it unprompted.

## Quality checklist

- [ ] Stack resolved from `STACK.md` (or `/cc:setup:stack` recommended when absent) — not hardcoded
- [ ] Nothing existing was overwritten — scaffolding filled gaps only
- [ ] `install` run per component from its `working_dir`, using the project's real tooling
- [ ] `.env` populated from the example and confirmed gitignored
- [ ] Services started only if the project actually uses them
- [ ] `/cc:verify:run` reached GREEN (or REDs explicitly accepted as pre-existing)

## Handoff

**Chain:** on a GREEN baseline, if the user supplied a feature goal as the argument, immediately invoke `/cc:plan:feature` with that goal using the SlashCommand tool — do not ask. If no feature goal was given, stop here: setup is complete.
**Solo:** if there is no `STACK.md`, suggest `/cc:setup:stack` first; otherwise suggest `/cc:plan:prd` to define what to build, or `/cc:piv:loop "<feature>"` to run the full PIV chain on a first feature.
**Abort rules:** missing prerequisites (runtime not installed, Docker daemon unavailable, package manager absent) → list the exact install commands for the user's platform and stop; do not attempt system-level installs unprompted. Validation RED on a claimed codebase that the user does not accept → route to `/cc:verify:debug`.
