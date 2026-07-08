---
description: End-to-end ship pipeline for an already-implemented feature branch — full verify gate, diff review, QA, and the commit gate — then hands off to the PR/merge step
argument-hint: "[optional: feature/plan path or description, for context only] [--no-qa to skip the QA checklist]"
disable-model-invocation: true
---

# Release: Ship

Take a feature branch that already has code on it — committed or not — through the full quality gate and out to a clean, reviewed commit, then hand off to whichever PR flow the user wants. This is the **upstream half** of shipping: it ends exactly where `/cc:ship-pr` begins. It never pushes, opens a PR, or merges anything itself.

This command does **not** plan or implement. If there is nothing on the branch yet, it says so and points at `/cc:piv:loop` (new feature, hands-off) or `/cc:plan:feature` (plan only).

Stack-agnostic throughout: every check this pipeline runs (`/cc:verify:run`, `/cc:verify:code`, `/cc:verify:security`, `/cc:verify:qa`) resolves its own concrete commands from the project's `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. This file hardcodes no toolchain and runs no test/lint/build command directly — it only sequences the commands that do.

## Scope

$ARGUMENTS

If a feature description or a plan path (e.g. `.specify/plans/<slug>.md` or `${user_config.workspace_dir}/plans/<slug>.md`) was given, read it for context — acceptance criteria to weigh the QA checklist against, and the intended scope to sanity-check the diff against. Never implement from it; this command assumes the work is already done.

## How this relates to `/cc:piv:loop` and `/cc:ship-pr`

Three commands cover three spans of the same road — chain them in sequence, or invoke any one standalone:

| Command | Starts from | Ends at | Human gates |
|---|---|---|---|
| `/cc:piv:loop` | a feature description | a committed, validated feature | 1 — before commit |
| `/cc:release:ship` (this command) | code already on the branch | a committed, validated, review-clean branch + PR handoff prompt | 1 — before commit |
| `/cc:ship-pr` | an open or about-to-open PR | a squash-merge to the base branch | 0 (autonomous — explicitly invoked only) |

Full chain: `/cc:piv:loop` (plan + implement) → `/cc:release:ship` (verify + review + QA + commit) → `/cc:ship-pr` (PR + resolve + merge) **or** `/cc:github:pr` (PR, human-merged). This command is the missing piece: piv:loop stops at commit, ship-pr assumes a PR already exists — this turns already-written code into a commit worth opening that PR from.

## Steps

### Step 0 — Confirm scope & branch state

```bash
git branch --show-current
git status --short
git log main...HEAD --oneline --no-merges
git diff --stat
```

- If the current branch is `main`/`master` → **STOP**. Ask the user to create a feature branch first; never run this pipeline against the base branch.
- If there are no commits ahead of `main` **and** no uncommitted changes → nothing to ship. Report that, point at `/cc:piv:loop` or `/cc:plan:feature`, and do not proceed.
- Otherwise, summarize what's being shipped (commits ahead, files changed, uncommitted work) before continuing — this is the scope the rest of the pipeline validates.

### Step 1 — Full verify gate

Invoke `/cc:verify:run`. This resolves `smoke → test → typecheck → lint → format:check` per component from `STACK.md` and reports per-component pass/fail.

- **Green** → continue to Step 2.
- **Red** → fix the obvious failures once, re-run `/cc:verify:run`.
- **Still red** → invoke `/cc:verify:debug`, then **STOP** and report. Do not proceed to review, QA, or commit on a red gate.

### Step 2 — Diff review: code + security

1. Invoke `/cc:verify:code branch` — reviews the full branch diff (`git diff main...HEAD`), not just uncommitted changes, since code already committed on this branch is still in scope.
   - Any CRITICAL finding → **STOP** immediately and report.
   - Non-critical findings → go to Step 3 (auto-fix loop) before continuing.
   - Clean → continue to 2.2.
2. Invoke `/cc:verify:security` (diff scope — the default; it already unions uncommitted changes with `git diff main...HEAD`).
   - Any CRITICAL finding → **STOP** immediately and report.
   - HIGH findings do not halt the pipeline but **must** be restated at the commit gate (Step 5) — never unmentioned.
   - PASS or PASS WITH WARNINGS → continue to Step 4.

### Step 3 — Auto-fix loop (mechanical findings only)

Only entered when Step 2's code review returned non-critical findings.

- Invoke `/cc:verify:code-review-fix` with the Step 2 report. It triages findings itself — CRITICAL/HIGH and mechanical MEDIUM get fixed now; anything needing a design decision is deferred and listed, never guessed at.
- Re-run `/cc:verify:run` to confirm the fixes broke nothing.
- **Cap: 2 fix → re-validate loops** (matching `/cc:verify:code-review-fix`'s and `/cc:piv:loop`'s own contract). If findings persist after 2 rounds, or any deferred finding is rated CRITICAL, **STOP** and surface the remaining findings — do not guess on judgment calls.
- Once clean (or the only remainder is an explicitly deferred, non-critical list), continue to Step 2.2 (security) if it hasn't run yet, then Step 4.

### Step 4 — QA checklist (skippable)

Skip entirely if `--no-qa` was passed — note the skip and move to Step 5.

Otherwise, determine whether this branch has a UI surface: check `git diff --name-only main...HEAD` against the languages/frameworks the resolved `STACK.md` components declare (a component `language`/framework pointing at a frontend/UI layer — e.g. changed `.tsx`, `.jsx`, `.vue`, `.svelte`, template, or view-layer files). No `STACK.md`, or no UI-layer files touched → skip automatically and note why (nothing to click through).

If a UI surface is detected, invoke `/cc:verify:qa` to generate the interactive HTML checklist at `${user_config.workspace_dir}/qa/<branch>-checklist.html`. This does not block the commit gate — it is a pre-merge artifact the user (or `/cc:ship-pr`'s reviewer pass) should work through before the PR is merged. Carry its path into the Step 5 gate and the final handoff.

### Step 5 — ⛔ Commit gate

Invoke `/cc:release:commit`. This is **the** human gate — never auto-commit or bypass it, even if every check above is green. Ensure the summary it presents includes, so the user approves with full context:

- What's being shipped (from Step 0)
- Verify results (Step 1)
- Review verdicts for code + security (Step 2), including any restated HIGH security findings and any deferred (non-blocking) review findings from Step 3
- QA checklist path, or the reason it was skipped (Step 4)
- The proposed commit message(s) and exact file list

Wait for explicit approval before anything is written to history. If the user rejects the proposal, revise and re-present — never commit the rejected version.

### Step 6 — Handoff (offer, don't act)

After the commit succeeds, offer the two ways to take it from here — do **not** push, open a PR, or merge anything; that is the line this command does not cross:

```
─────────────────────────────────────────
  SHIPPED — ready for a PR
─────────────────────────────────────────
  Branch:      <branch>
  Committed:   <hash> <message>
  Verify:      ✅ /cc:verify:run
  Review:      ✅ code + security clean (or: N findings deferred — listed above)
  QA:          <path to checklist> / skipped (<reason>)
─────────────────────────────────────────
  Next, pick one:
    /cc:ship-pr    — autonomous: opens/adopts the PR, validates it two ways,
                      resolves every finding, squash-merges when clean.
                      Hands-off; explicitly invoked only.
    /cc:github:pr  — manual: opens the PR with a summary + test plan body;
                      you review, respond to comments, and merge yourself.
─────────────────────────────────────────
```

Wait for the user's choice. Do not default to either path.

## Output

A clean, review-passed commit (or commits) on the feature branch; a QA checklist at `${user_config.workspace_dir}/qa/<branch>-checklist.html` when the branch has a UI surface and `--no-qa` was not passed; and the handoff prompt above. No branch is pushed and no PR is opened by this command.

## Quality checklist

- [ ] Never run against `main`/`master`; nothing-to-ship state reported and pipeline halted cleanly rather than fabricating work
- [ ] `/cc:verify:run` green before any review step runs
- [ ] Code review covers the **whole branch diff**, not just uncommitted changes
- [ ] Every CRITICAL finding (code or security) halts the pipeline immediately
- [ ] Auto-fix loop capped at 2 rounds; anything still outstanding is surfaced, not silently dropped
- [ ] QA checklist generated for any branch with a UI surface, unless `--no-qa` was passed
- [ ] Commit gate presents the full picture (verify + review + QA state) and waits for explicit approval — no auto-commit under any condition
- [ ] Nothing pushed, no PR opened or merged, by this command

## Handoff

**Chain:** this command IS a chain — it owns the sequencing above end to end, from branch state through the commit gate. It is a valid continuation after `/cc:piv:loop` (re-running its own verify/review/QA is fine — checks are cheap and idempotent) and a valid entry point on its own for a branch built by hand.
**Solo:** n/a — always runs the full pipeline; use the individual `/cc:verify:*` commands directly for surgical single-step checks instead.
**Abort rules:** on `main`/`master` → stop before running anything. `/cc:verify:run` red twice → `/cc:verify:debug`, then stop. Any CRITICAL code or security finding → stop immediately, never route through the auto-fix loop. Auto-fix loop still finding real issues after 2 rounds, or a deferred finding is CRITICAL → stop and surface to the user. User rejects the commit gate → revise and re-present, never commit the rejected version; leave the working tree intact for manual follow-up. Never push, open a PR, or merge — that is always `/cc:ship-pr`'s or `/cc:github:pr`'s job, invoked by explicit user choice at Step 6.
