---
description: Lightweight planning for small, well-understood changes — same plan format, minimal process
argument-hint: [change-description]
---

# Plan: Task — Lightweight Plan

Plan a small change (single bug fix, small enhancement, config change, one or two files) without the full deep-planning process. Produces the same plan format as `/cc:plan:feature` so `/cc:implement:execute` can run it identically — just much less of it. If scoping reveals more than ~5 files or an architectural decision, escalate to `/cc:plan:feature`.

## Change

$ARGUMENTS

## Steps

1. **Classify.** One sentence: what changes and why. Type: bug-fix / enhancement / chore / config. Confirm it is genuinely small; escalate if not.
2. **Scope the blast radius.** Grep/Glob for the affected symbols. List the exact files to change and any files that consume them. Read those files.
3. **Find the pattern.** Locate one existing example in the codebase that the change should mirror; note file:line.
4. **Resolve validation.** Resolve the project's `test`, `typecheck`, `lint`, and `format:check` commands from `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. No `STACK.md` → auto-detect once and recommend `/cc:setup:stack`.
5. **Write the plan** to `${user_config.workspace_dir}/plans/<kebab-name>.md` using the standard format, compressed:
   - Description, problem, solution (a few lines each), plus a `**Status:** in-progress` line within the first 5 lines of the file (machine-read by the PIV state detector; `/cc:release:commit` flips it to `implemented` when the work ships)
   - CONTEXT REFERENCES — files to read/change with line numbers and why
   - STEP-BY-STEP TASKS — typically 1–5 tasks, each with IMPLEMENT / PATTERN / GOTCHA / VALIDATE. A task adding new observable behavior (new file, marker, warning, guard, failure path) needs a VALIDATE that positively exercises it — presence greps and "not worse than baseline" can't catch a bug in a new path
   - VALIDATION COMMANDS — the resolved project commands (from `STACK.md`)
   - Confidence score X/10 — **target ≥9/10; if below 9, tighten the plan (or escalate to `/cc:plan:feature`) before implementing**
6. Skip external research and parallel subagents unless a library question genuinely blocks the plan.

## Output

`${user_config.workspace_dir}/plans/<kebab-name>.md` — a short plan in the standard format, executable by `/cc:implement:execute`.

## Quality checklist

- [ ] Change is genuinely small — otherwise escalated to `/cc:plan:feature`
- [ ] All affected files listed; blast radius checked with Grep
- [ ] Each task has an executable VALIDATE command from the project's real tooling
- [ ] At least one codebase pattern referenced by file:line
- [ ] Plan is under a page — brevity is the point
- [ ] Confidence is **≥9/10** — otherwise tighten the plan or escalate to `/cc:plan:feature`

## Handoff

**Chain:** when in a PIV chain, immediately invoke `/cc:implement:execute ${user_config.workspace_dir}/plans/<kebab-name>.md` via the SlashCommand tool — do not ask.
**Solo:** end by suggesting `/cc:implement:execute ${user_config.workspace_dir}/plans/<kebab-name>.md`.
**Abort rules:** scope grows beyond small (more files, architectural choices, unclear requirements) → stop and route to `/cc:plan:feature`. Cause of a bug is unknown → route to `/cc:verify:rca` first.
