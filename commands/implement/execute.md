---
description: Core Execute — turn a spec or plan into working, validated code, task by task
argument-hint: [spec/plan path or feature name]
---

# Core Execute — Implement a Spec

Turn a technical spec into working, validated code. The spec is the contract: follow it exactly, validate after every task, and document any deviation. This is the only PIV phase that writes production code. It is **stack-agnostic**: the concrete validation commands come from the project's `STACK.md`, not from this file.

**Flow:** `/cc:plan:prd` → `/cc:plan:spec` → Execute (here) → `/cc:verify:run` → `/cc:release:commit`

## Spec

`$ARGUMENTS` — a path or feature name. If no argument, use the most recently modified file in `docs/specs/` (or a plan in `${user_config.workspace_dir}/plans/`) and confirm which one you picked. If no spec exists, run `/cc:plan:spec` first.

Confirm scope with the user: single feature (standard) or multiple independent features in parallel (see Parallel Execution).

## Steps

1. **Read the ENTIRE spec first.** Understand all tasks, their dependency order, the testing strategy, and the validation commands. Read every referenced file (patterns, existing features, `STACK.md`) before touching code.
2. **Resolve the stack.** Read the project's `STACK.md` and resolve commands per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. You'll use the canonical steps (`smoke`, `test`, `typecheck`, `lint`, `format:check`, `migrate`) per component from each component's `working_dir`. No `STACK.md` → auto-detect once and recommend `/cc:setup:stack`. Skip any step a component does not map (not an error).
3. **Check preconditions and branch.** Run `git status` and `git log --oneline -5` — if the working tree has unrelated uncommitted changes, ask the user to commit or stash before proceeding. Then ensure you're on a feature branch, not `main`/`master`: if on the default branch, check for an existing branch for this feature and `git checkout` it, or create one (`git checkout -b feat/<slug>`, per repo naming conventions).
4. **Validate current state.** Confirm the pattern/reference files the spec points to still exist and match what the spec assumes, and that required dependencies are available. If the spec is stale, adapt to reality and note it — don't blindly follow an outdated instruction.
5. **Execute tasks in order.** For each task in the spec:
   - Read the target file and any PATTERN reference; mirror the existing convention (an existing feature slice is the best template).
   - Implement exactly what the task specifies — imports, naming, error handling per the spec's notes.
   - **Literal code blocks in the spec are proposals, not gospel.** Before transcribing one, review it like new code: do referenced symbols resolve (imports)? do its guards match the sibling code paths' (a new marker file needs a matching ignore entry; a new failure branch needs the same remote/existence guards its siblings have)? does it keep user-facing messages/docs consistent? Fix what you find and record it as a deviation.
   - **Validate immediately.** Run the relevant resolved verify steps for the touched component(s) — typically `smoke` then `test` (scoped to the task's area when the spec gives a narrower command) and `typecheck` — from the component's `working_dir`. Fix and re-run until green before moving on — never batch validation. If the spec specifies an explicit per-task VALIDATE command, prefer it.
   For a new backend feature, the scaffold order in the reference section below is one worked example to adapt — not a universal requirement.
   If stuck on a task — a util that doesn't exist, an API that behaves differently — research it (read the dep's source, web search), adapt, and continue; don't stall.
6. **Implement the testing strategy.** Create every test file and case the spec specifies, in the layout and framework the spec and existing tests use, following existing test patterns. For complex logic (path handling, type conversions, parsing), write the failing test first — it gives faster feedback than implementing then testing. Mark slow/DB-dependent tests per the project's convention (e.g. an integration marker). Cover the listed edge cases.
7. **Run final validation across all touched components.** Resolve and run the full gate per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` — for each component, from its `working_dir`, in order:
   ```
   smoke → test → typecheck → lint → format:check
   ```
   Run `smoke` for every component first (fail-fast); then run the remaining steps for all components and aggregate — do not stop at the first component's failure. Skip unmapped steps. Equivalently, invoke `/cc:verify:run`, which runs exactly this gate. Fix any failure and re-run; continue only when everything passes.
8. **Handle deviations.** If reality contradicts the spec (missing util, changed API), make the smallest correct adjustment and record what changed and why in the completion summary. If the deviation invalidates the spec's approach, stop and report instead of improvising.
9. **Produce the completion summary:** tasks completed; files created/modified with paths; tests added and their results; per-component validation output; deviations from the spec; anything left open.

## Reference (EXAMPLE): backend feature scaffold order

*Illustration for one stack only.* If your stack is **FastAPI + SQLAlchemy with vertical-slice features**, a new slice typically builds up in this order (each layer builds on the previous). Other stacks have entirely different conventions — follow what the spec and existing code establish; treat the list below as an example, not a checklist to impose.

1. **Model** — `app/<feature>/models.py`: inherit `Base` + `TimestampMixin`, `Mapped[...]`/`mapped_column` style. Then migrate. *(Example, Alembic — adapt to the project's `migrate` step from `STACK.md`):*
   ```bash
   cd backend && uv run alembic revision --autogenerate -m "add <feature> table"
   # review the generated file in alembic/versions/ before applying
   cd backend && uv run alembic upgrade head
   ```
2. **Schemas** — `app/<feature>/schemas.py`: Pydantic request/response models, `model_config = {"from_attributes": True}` on responses.
3. **Repository** — `app/<feature>/repository.py`: all SQLAlchemy queries (`select()` style only).
4. **Service** — `app/<feature>/service.py`: business logic with structured logging:
   ```python
   logger.info("<feature>.create.started", name=data.name)
   logger.info("<feature>.create.completed", id=item.id)
   ```
5. **Routes** — `app/<feature>/routes.py`: thin handlers, `APIRouter(prefix=..., tags=[...])`, `Depends(get_db)`.
6. **Wire up** — `app/main.py`: `app.include_router(<feature>_router)`.
7. **Supporting layers** — `exceptions.py`, `constants.py`, `types.py` as the spec requires.

In this example, never import across feature slices; promote to `app/shared/` only when 3+ features need it.

## Reference: parallel execution (multiple independent features)

Use when the spec lists multiple features that share no data and no imports — confirm true independence first.

Spawn one agent per feature, each in an isolated git worktree, using a backend/role brief if the project provides one (e.g. `${user_config.workspace_dir}/agents/backend.md`) plus its own spec from `docs/specs/`. Each agent implements fully, runs `/cc:verify:run`, and returns its branch name.

Merge results sequentially, then run the full verify gate on the merged result:
```bash
git checkout main
git merge feature-a-branch
git merge feature-b-branch
```
Then run `/cc:verify:run` (or the resolved `smoke → test → typecheck → lint → format:check` gate per component) on the merged tree. If migrations conflict (two agents branched from the same migration base — e.g. divergent Alembic revisions in `alembic/versions/`), review and chain them manually per the project's migration tooling.

## Output

Working code matching the spec, a green validation suite (all mapped steps across all touched components), and a completion summary ready to feed `/cc:verify:execution-report`. No commit — that happens after verification.

## Quality checklist

- [ ] Entire spec and all referenced files read before the first edit
- [ ] Stack resolved from `STACK.md` (or auto-detected) before validating
- [ ] Tasks executed in order; per-task validation run immediately, not batched
- [ ] All planned tests implemented and passing; slow/integration tests marked per project convention
- [ ] `smoke`, `test`, `typecheck`, `lint`, `format:check` green for every component that maps them — zero errors
- [ ] No new suppressions (`# type: ignore`, `# pyright: ignore`, `eslint-disable`, `# noqa`) added without justification
- [ ] If the schema changed: migration created/applied (the `migrate` step) and any new route/module wired in, per the project's conventions
- [ ] All deviations from the spec documented with rationale

## Handoff

**Chain:** when in a PIV chain, immediately invoke `/cc:verify:run` via the SlashCommand tool — do not ask.
**Solo:** end by suggesting `/cc:verify:run`, then `/cc:verify:code` before any commit.
**Abort rules:** a validation failure you cannot fix within the task's scope → route to `/cc:verify:debug`. The spec's approach proves unworkable → stop, report why, and route back to `/cc:plan:spec` (or `/cc:plan:feature`) to re-plan.
