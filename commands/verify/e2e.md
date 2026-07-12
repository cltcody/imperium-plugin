---
description: Run the project's end-to-end suite — provision the device/simulator environment (e2e:setup), then execute the smoke subset (or the full suite with --full). Opt-in per project via STACK.md e2e:* steps; unmapped projects report "not configured" and exit green. Use on "run e2e", "run the maestro/detox/playwright suite", "device QA gate".
argument-hint: "[--full]"
---

# Verify E2E — Device / End-to-End Gate

Run the project's end-to-end tests. **Opt-in and stack-agnostic**: the concrete commands
come from the project's `STACK.md` `e2e:*` steps per
`${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md` — Maestro, Detox, Playwright,
whatever the project maps. This gate is deliberately **not** part of `/cc:verify:run`:
device provisioning is expensive and ordering-sensitive, so chains sequence it once, at
final HEAD, after all source edits have landed.

## Scope

`$ARGUMENTS` — `--full` runs the `e2e` step (full suite) instead of the default
`e2e:smoke`.

## Steps

### 1. Resolve the stack

Read the project's `STACK.md` and resolve the `e2e:setup`, `e2e:smoke`, and `e2e` steps
per component. A component with no `e2e:*` mappings is reported **"e2e: not configured"**
— stated, never silently skipped. If no component maps any `e2e:*` step, report that and
exit green: the gate is opt-in, absence is not a failure.

### 2. Provision the environment (`e2e:setup`)

Run `e2e:setup` from the component's `working_dir`. A setup failure is **RED
(environment)** — never "tests passed" and never green-by-omission; stop and report it as
the gate result. Ordering rule: setup builds/installs the app under test, so it must run
**after** the last source edit — a build kicked off before edits land bakes in a stale
bundle whose failures are indistinguishable from real bugs.

### 3. Run the suite

Run `e2e:smoke` (default) or `e2e` (`--full`) from the component's `working_dir`. Capture
per-flow pass/fail when the runner reports it, plus the paths of any failure artifacts
(screenshots, hierarchy dumps, logs).

### 4. Report

Per component: setup result, flows passed/failed/total, failure artifacts. Overall
verdict: **GREEN** / **RED** / **NOT CONFIGURED**.

## Output

```
E2E REPORT — expo-react-native (from STACK.md)
──────────────────────────────────────────────
app  setup ✅ (release build + install, sim UDID …)   e2e:smoke ✅ 2/2 flows
Overall: ✅ GREEN
```

Adapt rows to whatever components and steps the project's `STACK.md` actually defines; a
red flow's row names the flow and its artifact paths.

## Quality checklist

- [ ] Unmapped `e2e:*` steps reported as "not configured" — never silently skipped
- [ ] A setup failure reported as environment RED, never as a passing or skipped gate
- [ ] Suite ran against a build produced after the last source edit
- [ ] Per-flow results and failure-artifact paths included in the report

## Handoff

**Chain:** green → continue the chain. Red → one classify-and-fix round (app bug vs
flow/harness bug — read the failure artifacts before deciding); if the fix touched
source, re-run `e2e:setup` (rebuild) before the single re-run. A harness-classified fix
must be itemized in the chain's report/PR body with its classification rationale — and
never weaken or remove an assertion to green the gate. Still red → stop and report per
the chain's degrade rules.

**Solo:** report the verdict; on red, point at the failing flow's artifacts and the
project's e2e docs for flow repair.

**Abort rules:** setup failure → RED, stop — never run the suite against a broken or
stale environment. Never mark the gate green on a setup failure or by silently skipping
an unmapped step.
