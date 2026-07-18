---
description: Deep implementation planning — produce a context-rich plan that enables one-pass implementation
argument-hint: [feature-description or prd-path]
---

# Plan: Feature — Deep Implementation Plan

Transform a feature request (or a PRD from `/cc:plan:prd`) into a comprehensive implementation plan. **Context is King — no code is written in this phase.** The plan must contain ALL information needed for implementation — file references, patterns, ordered tasks, validation commands, gotchas — so `/cc:implement:execute` succeeds in one pass with zero additional research. It is **stack-agnostic**: the validation commands the plan prescribes come from the project's `STACK.md`, not from this file.

## Feature

$ARGUMENTS

## Steps

### Phase 1 — Feature understanding

1. Extract the core problem, user value, and feature type (new capability / enhancement / refactor / bug fix). Assess complexity (low/medium/high) and the systems affected.
2. Write or refine the user story: *As a `<user>` I want `<action>` so that `<benefit>`.*
3. **Quick feasibility check** — is this possible with the current architecture? Any obvious blockers (missing dependency, incompatible pattern)? Does something similar already exist that should be *extended* rather than rebuilt? If a hard blocker exists, stop and report it — do not plan the impossible.
4. If requirements are ambiguous, ask the user now — never carry ambiguity into the plan.

### Phase 2 — Codebase intelligence gathering

Goal: find patterns to **mirror, not invent**. Launch **parallel subagents** (Explore/general-purpose) for these analyses; consolidate their findings:

5. **Structure** — languages, frameworks, directory layout, architectural boundaries, config files, build process.
6. **Patterns** — similar existing implementations; naming, error-handling, and logging conventions; CLAUDE.md rules; anti-patterns to avoid. Capture *actual code excerpts* (with file:line) for the structures you'll follow — not generic descriptions. **If the feature touches a user-facing surface** (forms/validation, auth screens, tables/pagination/async states, layout/modal/toast/destructive-confirm), resolve the portfolio's component reference library per `${CLAUDE_PLUGIN_ROOT}/references/dev/component-reference-library.md` and check it for a canonical component **before inventing one**: plan those tasks as COPY + ADAPT with the library file as the PATTERN reference and its NOTES.md "breaks guarantees" list carried into the GOTCHA field. No library resolved → skip silently.
7. **Dependencies** — relevant libraries, how they are integrated, versions and compatibility constraints.
8. **Testing** — test framework and layout, representative test examples to mirror, coverage expectations, mocking patterns.
9. **Integration points** — existing files needing updates, new files to create with exact locations, registration/wiring patterns (routers, DI, exports).
10. **Resolve the project's actual validation commands** from its `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` — the plan's prescribed validation must match the project's mapped `smoke` / `test` / `typecheck` / `lint` / `format:check` / `migrate` steps (per component, from each component's `working_dir`). No `STACK.md` → auto-detect once and recommend `/cc:setup:stack`. Never assume a specific test runner, type checker, or linter.

### Stack notes

Mirror the project's own architecture and conventions — discover them in Phase 2 rather than imposing a default layout. Follow the existing module/feature boundaries, naming, file organization, and wiring/registration patterns already in the codebase (e.g. how routes/handlers, dependency injection, exports, and migrations are registered). The plan's validation suite must be the commands resolved in step 10 from the project's `STACK.md` — not a hardcoded stack.

### Phase 3 — External research

11. **Reuse prior research first** — if the project keeps research reports (e.g. `${user_config.workspace_dir}/reports/`, `docs/`, `ai_docs/`), read the relevant ones in full and do a gap analysis: what's mentioned but not fully explained? Fill those gaps before researching from scratch.
12. For any non-trivial library use, verify current docs: latest patterns, breaking changes, known gotchas, security notes. Record links with section anchors and a one-line "why" each.
13. **Verify any new dependency's real API before planning against it** — package name often differs from import/module name, and class/method names are easy to guess wrong. Install it and inspect the actual API using the language's own introspection (e.g. a REPL/help, type stubs, or generated docs), then record the *verified* import/require statements and method signatures in the plan. This prevents import-resolution and missing-symbol errors during implementation.

### Phase 4 — Strategic thinking

14. Think hard about: fit with existing architecture, order of operations, edge cases and failure modes, security implications, performance, testability, maintainability. Choose between alternatives with explicit rationale.
15. **Define what's out of scope** — list what you are deliberately *not* building (abstractions, config knobs, edge cases deferred to v1) so the implementer doesn't over-engineer.

### Phase 5 — Plan generation

16. Write the plan to `${user_config.workspace_dir}/plans/<kebab-name>.md` (create the directory if needed) with this structure:
    - **Feature Description / User Story / Problem / Solution** and metadata (type, complexity, systems affected), including a `**Status:** in-progress` line **within the first 5 lines of the file** — the PIV state detector (`hooks/piv_state.py`) machine-reads it there to keep finished plans out of phase detection; `/cc:release:commit` flips it to `implemented` when the work ships (recognized closed values: `implemented`, `superseded`, `done`)
    - **CONTEXT REFERENCES** — files to read before implementing (`path` + line ranges + why), new files to create, documentation links (anchored, with why), patterns to follow with actual code excerpts from this project
    - **NOT BUILDING** — explicit out-of-scope items, to keep the implementer minimal
    - **STEP-BY-STEP TASKS** — dependency-ordered, atomic. Each task: `{ACTION} {target-file}` with **IMPLEMENT** (specifics), **PATTERN** (file:line reference), **IMPORTS**, **GOTCHA**, **VALIDATE** (executable command). Actions: CREATE / UPDATE / ADD / REMOVE / REFACTOR / MIRROR. Flag side-effect import order where registration depends on it (e.g. `# ruff: noqa: I001`). When a task introduces **new observable behavior** (a new file, marker, warning, guard, or failure path), its VALIDATE must include a positive check that *exercises that behavior* — syntax checks, presence greps, and "existing tests not worse than baseline" cannot catch a bug in the new path.
    - **TESTING STRATEGY** — unit, integration, and edge cases per project standards; name the test files to create and the existing test to mirror
    - **VALIDATION COMMANDS** — the commands resolved from the project's `STACK.md` (step 10), levelled: `smoke` (import/compile) → `lint`/`format:check` → `test` (unit) → integration → manual. Make level 1 the `smoke` step — a fast import/compile check, the cheapest catch for bad imports — before any test runs. For monorepos, list commands per component with its `working_dir`. If no `STACK.md`, note auto-detect and `/cc:setup:stack`.
    - **ACCEPTANCE CRITERIA** and completion checklist
    - **Confidence score X/10** that one-pass implementation succeeds, with reasoning. **Target ≥9/10. If the honest score is below 9, iterate the plan (pin more file:line patterns, verify APIs, decide seed content) or split it into smaller plans until each is ≥9 — do not ship a sub-9 plan to implementation.**
17. Report: plan path, approach summary, complexity, key risks, confidence score.

## Output

`${user_config.workspace_dir}/plans/<kebab-name>.md` — passes the "no prior knowledge test": someone unfamiliar with the codebase could implement using only the plan.

**Exemplar:** match the shape and bar of `${CLAUDE_PLUGIN_ROOT}/references/dev/exemplars/plan-feature-exemplar.md` — not its content.

## Quality checklist

- [ ] No code written — planning only
- [ ] Pattern references include specific file:line with real code excerpts; mirror existing patterns, don't invent
- [ ] New dependencies' import names and method signatures verified, not guessed
- [ ] Out-of-scope items listed; no over-engineering
- [ ] Every task atomic, dependency-ordered, with an executable VALIDATE command
- [ ] Validation commands resolved from the project's `STACK.md` (or auto-detected with `/cc:setup:stack` noted), non-interactive, runnable as-is; level 1 is the `smoke` import/compile check
- [ ] Gotchas and anti-patterns captured; no existing util reinvented
- [ ] Confidence score given with justification, and it is **≥9/10** (iterate or split the plan if below the bar)

## Handoff

**Chain:** when in a PIV chain, immediately invoke `/cc:implement:execute ${user_config.workspace_dir}/plans/<kebab-name>.md` via the SlashCommand tool — do not ask (but if confidence is **< 9/10**, do NOT auto-proceed: iterate/split the plan first, or surface the open questions).
**Solo:** end by suggesting `/cc:implement:execute ${user_config.workspace_dir}/plans/<kebab-name>.md`.
**Abort rules:** requirements remain ambiguous after clarification → stop and return the open questions instead of a speculative plan. Scope reveals a product-level decision → route to `/cc:plan:prd` first.
