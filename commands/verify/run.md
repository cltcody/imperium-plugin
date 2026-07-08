---
description: Fast verification gate — tests + types + lint (PIV Phase 3)
---

# PIV Phase 3: Verify

Run the verification gate — tests, types, lint — and report per component. This is Phase 3
of the PIV loop and the validation gate of every chain. It is **stack-agnostic**: the
concrete commands come from the project's `STACK.md`, not from this file.

## Steps

### 1. Resolve the stack

Read the project's `STACK.md` and resolve commands per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. This gate runs these steps, in
order, **for every component** from that component's `working_dir`:

```
smoke → test → typecheck → lint → format:check
```

Skip any step a component does not map (not an error). No `STACK.md` → auto-detect once and
recommend `/cc:setup:stack`.

For a large or slow suite, the `validation-runner` agent may be delegated to run the gate
and return a compact, decision-ready result instead of the raw output — optional, not
required for a normal-sized run.

### 2. Fail-fast on smoke

Run each component's `smoke` step first (the cheap import / type / compile check). If any
component's `smoke` fails, stop and report — do not run the expensive suite behind a broken
build.

### 3. Run the gate per component

For each component, run `test`, `typecheck`, `lint`, `format:check` from its `working_dir`,
capturing pass/fail per step. **Run all components and aggregate** — do not stop at the
first component's failure. Report results per component.

### 4. Evaluate the PIV checklist

After running all mapped steps, evaluate against the Quality checklist below and compile
the report.

## Output

A per-component verify report, e.g. (a FastAPI + Next.js monorepo):

```
VERIFY REPORT — fastapi + nextjs (from STACK.md)
────────────────────────────────────────────────
backend  (uv)   smoke ✅  test ✅ (121)  typecheck ✅  lint ✅  format ⚠️ (7 to reformat)
frontend (npm)  typecheck ✅  lint ✅                  (test, smoke, format: unmapped)

Overall: ❌ RED — backend format:check (run the project's formatter)
         ✅ GREEN — ready to commit
```

Adapt the rows to whatever components and steps the project's `STACK.md` actually defines.

## Quality checklist

- [ ] `smoke` passes for every component that maps it
- [ ] All tests pass (including new tests for the feature)
- [ ] `typecheck` clean for every component that maps it
- [ ] `lint` and `format:check` clean where mapped
- [ ] No new suppressions (`# type: ignore`, `# pyright: ignore`, `eslint-disable`, `# noqa`)
      added without justification
- [ ] If the schema changed: migration created/applied (`migrate` step) and any new
      route/module wired in, per the project's conventions

## Handoff

**Chain:** When running as part of the full chain (e.g. invoked by `/cc:piv:loop` or after
`/cc:implement:execute`):
- **Green** → invoke `/cc:verify:code` next.
- **Red** → fix the obvious failures once, re-run `/cc:verify:run`.
- **Still red** → invoke `/cc:verify:debug`, then stop the chain.

**Solo:** Report the verify results. If green, suggest `/cc:release:commit`; if red, suggest
`/cc:verify:debug` for non-obvious failures.

**Abort rules:** Never proceed in a chain with a red validation — a red `/cc:verify:run`
halts everything downstream (review, commit, release). Only one self-fix attempt is allowed
before escalating to `/cc:verify:debug` and stopping.
