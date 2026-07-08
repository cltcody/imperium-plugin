---
description: Restructure code without changing behaviour — baseline green, small reversible steps, re-validate each step
argument-hint: [refactor scope]
disable-model-invocation: true
---

# Refactor

Safely restructure existing code with zero behaviour change. The invariant: the test suite is green before you start, green after every step, and green at the end — with no test semantics altered along the way.

This command is **stack-agnostic**: the concrete validation commands come from the project's `STACK.md`, resolved per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`, not from this file.

## Scope

`$ARGUMENTS` — if unclear, ask: **what are we refactoring and why?** Common reasons:
- A pattern is used inconsistently across features
- A function or module has grown too large (a single unit doing too much)
- Logic is duplicated in 3+ places → promote to a shared location
- A module violates single responsibility
- A naming convention needs updating project-wide

Reduce to a one-sentence goal: *"Extract X into a shared utility because A, B, C duplicate it."*

## Steps

1. **Define the goal and non-goals.** A refactor changes structure, not behaviour. Any behaviour change belongs in `/cc:plan:task` or `/cc:plan:feature` instead.
2. **Map the blast radius.** Grep for every usage, import, and caller of the code being moved or reshaped — across the relevant components and file types:
   ```bash
   grep -rn "<symbol_or_pattern>" <source_dir>
   ```
   List every affected file — this is the change surface.
3. **Establish the behavioural baseline.** Resolve the project's `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` and run the verify steps (`smoke → test → typecheck`) for each affected component from its `working_dir` — or invoke `/cc:verify:run`. The baseline **must be green BEFORE anything changes**. Skip steps a component does not map; no `STACK.md` → auto-detect once and recommend `/cc:setup:stack`.
   If coverage over the refactor area is thin, run `/cc:verify:coverage` and write characterisation tests for the current behaviour first — never refactor untested code blindly.
4. **Refactor in small reversible steps.** For each step:
   - Add the new structure (new file/function/location) first.
   - Move or copy logic; update importers one file at a time.
   - Delete old code only after all references point to the new location.
   - **Re-run after every step:** the affected components' `test` and `typecheck` steps from `STACK.md` (resolve per the stack-resolution reference), or `/cc:verify:run`. Red → fix immediately or revert that step before continuing. Never proceed on red.
   - Keep steps small enough that `git checkout -- <file>` cleanly undoes one step. No big-bang rewrites across 10 files at once.
5. **Handle shared promotion correctly** (only if 3+ consumers use the code):
   1. Create the shared module/location and move the code there, per the project's conventions
   2. Update every importer to reference the new location
   3. Delete the original
   4. Grep to confirm no module reaches across boundaries it shouldn't (respect the project's module/slice rules)
6. **Final verification.** Run the full verify gate (`smoke → test → typecheck → lint → format:check`) for every affected component from its `working_dir` via `STACK.md` resolution, or invoke `/cc:verify:run`. Skip unmapped steps.
   Diff review: confirm the change is purely structural — no logic, contract, or test-expectation changes hiding in the diff.
7. **Summarise:** what moved where, files touched, validation results, and confirmation that no behaviour changed.

## Output

A restructured codebase with identical behaviour, a fully green validation suite, and a summary of the structural changes ready for review.

## Quality checklist

- [ ] Baseline verify run green BEFORE the first change
- [ ] Full blast radius mapped with Grep before editing
- [ ] Validation re-run after every step — never two steps on red
- [ ] No behaviour, public contract, or test expectation changed
- [ ] Old code deleted only after all importers updated; no dead duplicates left
- [ ] Shared promotion only with 3+ consumers; no cross-boundary imports introduced

## Handoff

**Chain:** when in a PIV chain, immediately invoke `/cc:verify:run` via the SlashCommand tool — do not ask.
**Solo:** end by suggesting `/cc:verify:run`, then `/cc:verify:code` to confirm no unintended changes before committing.
**Abort rules:** baseline verify already failing → stop; route to `/cc:verify:debug` before any refactoring. A step cannot be made green without changing behaviour → revert it, stop, and report — the refactor needs a plan (`/cc:plan:task`).
