---
description: Full plan-or-idea → merged-PR chain with per-task dynamic model routing — plan (or reuse a plan), implement across routed subagents, verify every phase, gate on commit, ship. Use when the ask is "take this idea all the way to a merged PR" or "run the whole thing, but route the grunt work to a cheaper model"
argument-hint: "[plan path | feature description] [--merge] [--no-qa]"
size-budget: exempt — full chain orchestration with per-task routing tables
---

# Ship — Idea to Merged PR, Dynamically Routed

Take a feature from a plan (or a bare description) all the way to a merged pull request,
hands-off except for the commit gate. This orchestrator stays on the session model
throughout — model routing in this command routes the *work* the chain dispatches, not
the chain itself, per
`${CLAUDE_PLUGIN_ROOT}/references/dev/dynamic-routing.md`. Read that file for the full
routing policy; this command applies it, it doesn't restate it.

## How this relates to `/cc:piv:loop`, `/cc:release:ship`, `/cc:ship-pr`

Four commands cover overlapping spans of the same road — chain any subset, or invoke one
standalone:

| Command | Starts from | Ends at | Routing |
|---|---|---|---|
| `/cc:piv:loop` | a feature description | a committed, validated feature | single model — the whole loop runs on the session model |
| `/cc:release:ship` | code already on the branch | a committed, validated, review-clean branch + PR handoff prompt | single model |
| `/cc:ship-pr` | an open or about-to-open PR | a squash-merge to the base branch | single model — PR tail only |
| `/cc:piv:ship` (this command) | a plan path *or* a bare idea | a merged PR (or an opened one, without `--merge`) | **per-task dynamic routing** — the orchestrator stays on the session model; each implementation task is routed to the cheapest model tier that clears its acceptance bar |

`/cc:piv:ship` is the whole arc: plan-or-idea → merged PR, with the plan's tasks fanned
out to routed subagents instead of executed serially on one model. Use `/cc:piv:loop` or
`/cc:release:ship` when the work is small enough that per-task routing overhead isn't
worth it; use this command when the plan has enough independent, file-disjoint tasks
that routing and parallelizing them actually pays for itself.

## Scope

`$ARGUMENTS`

Parse for `--merge` (hand off to `/cc:ship-pr` at the end instead of stopping at an opened
PR) and `--no-qa` (skip the QA checklist in the full-verification step, same flag
`/cc:release:ship` uses). Whatever remains is either a plan path (e.g.
`${user_config.workspace_dir}/plans/<slug>.md` or `.specify/plans/<slug>.md`) or a feature description.

## Steps

### 0. Resolve the plan

- `$ARGUMENTS` (minus flags) looks like a path to an existing file → read it **entirely**
  before anything else. It is the contract for every later step.
- Otherwise treat it as a feature description → invoke `/cc:plan:feature <description>` on
  the **session model** — planning is never routed down, regardless of how mechanical the
  eventual implementation looks. That command enforces its own ≥9/10 confidence gate.
  - Confidence **≥ 9/10** → continue with the plan it wrote.
  - Confidence **< 9/10** → **STOP**. Surface the open questions/gaps it reported. Do not
    proceed to routing or implementation on a sub-9 plan.
- If no plan path and no feature description were given, ask for one now.

### 1. Parse routing

Apply the routing precedence in
`${CLAUDE_PLUGIN_ROOT}/references/dev/dynamic-routing.md` to every task in the plan, in
order: plan-declared routing table/heading tags → invoked-command frontmatter →
task-type heuristics → inherit session model. Build the **routing ledger**: one row per
task, `task → model + effort`, with the precedence rule that decided it.

Show the ledger to the user as part of the kickoff summary, alongside the plan's scope
and phase breakdown. This is transparency, not a gate — do not wait for approval here;
continue straight into execution.

### 2. Execute by phase

Phases are hard barriers: every task in a phase must land before the next phase starts,
because later phases consume earlier phases' outputs.

Within a phase, group tasks by their declared file lists. File-disjoint tasks run as
**parallel `Agent` tool calls sent in a single message** (per the Agent tool's own
concurrency guidance); tasks whose file lists overlap run sequentially, in the plan's
stated order. Each dispatch uses the routed `model:`/`effort:` from the ledger.

Each subagent gets a **task-slice brief only** — never the whole plan or the chain
transcript:
- that task's spec (ACTION, target file(s), IMPLEMENT, PATTERN, IMPORTS, GOTCHA)
- its VALIDATE command
- the acceptance criteria that apply to it
- the named files it touches — nothing else

Each subagent must return **summary-only**: files changed, acceptance-check results, any
deviation from the task spec (one line each), and a self-reported confidence (1-10). The
orchestrator never ingests a subagent's raw diff — it can `git diff` the named files
itself if it needs to check something.

**Per-task validation** runs whatever the plan's task specifies as its VALIDATE command.
**Escalation** on failure follows
`${CLAUDE_PLUGIN_ROOT}/references/dev/dynamic-routing.md` exactly: one tier up
(haiku → sonnet → session model), one retry, same task-slice brief plus the failure
detail. A second failure at the escalated tier **STOPS the chain** — this is a
plan-quality problem, surface it rather than trying a third tier.

### 3. Phase gate

After every phase's tasks have landed (including any escalations), run the resolved
verify gate for the whole tree so far:

- **Default:** `/cc:verify:run` — the `STACK.md`-resolved
  `smoke → test → typecheck → lint → format:check` gate per
  `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`.
- **Content repos where the plan names its own gate** (no `STACK.md`, or the plan
  explicitly declares a different check — e.g. `bash global/scripts/cc-audit.sh` for a
  content/prompt repo like this plugin itself) — run exactly the gate the plan names,
  not a fabricated substitute.

**Green** → continue to the next phase (or, after the last phase, to full verification).
**Red** → route to the responsible task's escalation path above if the failure traces to
one task's output; if it's a genuine cross-task integration break, route to
`/cc:verify:debug`. **Two consecutive red phase gates** (this phase and the previous one,
after their respective fix attempts) → **STOP** the chain and report — do not keep
grinding through phases on a foundation that won't hold.

### 4. Full verification

Once every phase is green, invoke `/cc:verify:all --quick` — or `--full` if the plan's
scope touches a security surface (auth, payments, PII, migrations, anything on the
escalation list in
`${CLAUDE_PLUGIN_ROOT}/references/dev/model-routing.md`'s "never downgrade" list).

- **GO** → continue to step 5.
- **FIX FIRST** → route findings into `/cc:verify:code-review-fix`, then re-run
  `/cc:verify:all` at the same tier. **Hard cap: 3 rounds total, global** — the same cap
  `/cc:ship-pr` enforces; a fix round that surfaces a new finding counts against the cap
  like any other. Round 4 does not exist: **STOP** and surface the remaining findings.
- The **final** clean verdict that clears this step must come from a review of the
  **full diff at the final HEAD** — not a stale review of an earlier round's delta.
  Intermediate rounds may review just the fix delta; the one that admits you to step 5
  never does.

### 5. Execution report

Invoke `/cc:verify:execution-report`. In addition to its normal contents (plan vs.
actual, divergences, validation results), include the **routing ledger** from step 1
annotated with what actually happened: model used per task, any escalations (task, tier
escalated to, reason), and per-task outcome. This is the evidence trail that lets the
task-type heuristics in `dynamic-routing.md` get tuned over time — a routing decision
nobody can see afterward can't be improved.

### 6. ⛔ THE human gate — `/cc:release:commit`

Never auto-commit, under any condition above. Invoke `/cc:release:commit`, which
presents the execution report (including the routing ledger), `git diff --stat`,
validation results, and the proposed commit message(s) with file lists, then waits for
explicit approval.

**Per-phase commits are allowed** — but only if the user pre-approved it at kickoff. Ask
this **once**, at the very start of execution (step 1's kickoff summary), the same way
`/cc:maintain:deps` asks its commit-strategy question once: *"Commit each green phase as
we go? (y/n)"* Capture the answer for the whole run. `y` means step 3's phase gate, once
green, routes straight into `/cc:release:commit` for that phase's diff before continuing
to the next phase — still gated, just gated per phase instead of once at the end. `n`
(the default if not asked or not answered) means accumulate everything and gate once,
here, at step 6.

### 7. Ship

- **`--merge` given** → hand off to `/cc:ship-pr`. Restate plainly before doing so: this
  merges autonomously — it creates/adopts the PR, validates it, resolves every finding
  regardless of severity, and squash-merges when clean, with no further human gate.
- **`--merge` not given (default)** → hand off to `/cc:github:pr` to open the PR with a
  summary + test plan body, then stop. The user reviews and merges by hand.

## Output

A routing ledger (task → model/effort, shown at kickoff and finalized in the execution
report); a plan (existing, or freshly written to `${user_config.workspace_dir}/plans/`); working,
validated code across every phase; an execution report at
`${user_config.workspace_dir}/execution-reports/`; one or more approved commits; and either a merged
PR (`--merge`) or an opened, review-ready PR awaiting the user's merge (default).

**Gate integrity.** All verdicts in this chain follow the validated-state and
declared-exception rules in `${CLAUDE_PLUGIN_ROOT}/references/dev/severity-and-rubrics.md`
→ "Gate integrity" — a moved head voids prior verdicts; shortcuts must be declared.

## Quality checklist

- [ ] Plan confidence ≥ 9/10 before any implementation task is dispatched (freshly
      planned or pre-existing)
- [ ] Routing ledger produced at kickoff and shown to the user before execution starts
- [ ] No subagent ever received the full plan or chain transcript — task-slice briefs
      only, spec + acceptance + named files
- [ ] Escalations ≤ 1 per task; a second failure at the escalated tier stopped the chain
      rather than trying a third tier
- [ ] File-disjoint tasks within a phase ran in parallel; overlapping tasks ran
      sequentially
- [ ] Phase gate ran after every phase, using the plan's own gate when it names one
      (content repos) or the `STACK.md`-resolved gate otherwise
- [ ] Two consecutive red phase gates stopped the chain rather than pushing forward
- [ ] Full verification's final clean verdict was a full-diff review at final HEAD, not a
      stale fix-delta review
- [ ] Code-review-fix loop capped at 3 rounds, global, matching `/cc:ship-pr`'s cap
- [ ] Commit-per-phase preference asked exactly once, honored for the whole run
- [ ] No commit without explicit approval at `/cc:release:commit`, regardless of
      per-phase or single-gate mode
- [ ] Execution report includes the routing ledger with actual models used and
      escalations, not just the planned assignments

## Handoff

**Chain:** this command IS the chain — it owns plan resolution, routing, phased
execution, phase gates, full verification, the commit gate, and the final PR handoff.

**Solo:** n/a — `/cc:piv:ship` is always a full chain; use `/cc:piv:loop` for a
single-model version of the same shape, or the individual `/cc:plan:*` / `/cc:implement:*`
/ `/cc:verify:*` commands for surgical single-step work.

**Abort rules:** plan confidence < 9/10 at step 0 → stop and surface open questions, no
implementation dispatched. A task fails at its escalated tier → stop the chain, report
which task and why, do not attempt a third tier. Two consecutive red phase gates → stop.
Any finding lands on `/cc:ship-pr`'s human-decision list (schema/data migration,
deleting user-facing content, security-sensitive code, anything needing a design
decision) → stop and hand back to the user rather than guessing. Merge conflicts at the
`--merge` handoff → stop, per `/cc:ship-pr`'s own guardrails. User rejects the commit
gate → revise and re-present, never commit the rejected version; leave the working tree
intact for manual follow-up.
