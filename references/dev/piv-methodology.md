# PIV Methodology — Plan, Implement, Verify

> Distilled from imported course/workshop notes, 2026-07. Original synthesis for this
> plugin — no third-party text reproduced.

Why the PIV loop works, how to right-size it, and the prompting discipline that makes
each phase reliable. This is the **rationale** document; the operational command map
(which `/cc:*` command to run when) lives in `references/piv/PIV_Loop_Cheatsheet.md`.

---

## The core idea

Every unit of work — feature, fix, refactor — runs the same cycle:

1. **Prime** — bootstrap the agent's context for this session.
2. **Plan** — turn the request into a self-contained implementation plan. No code yet.
3. **Implement** — execute the plan exactly. Nothing more.
4. **Verify** — run deterministic gates (tests, types, lint) plus a review pass.
   Red gate → loop back to Plan or Implement. Green gate → commit.

Two principles drive everything:

- **Plan quality determines implementation success.** A plan that contains every
  pattern, file reference, gotcha, and validation command lets the implementation
  pass on the first attempt. A vague plan guarantees mid-implementation research,
  drift, and rework.
- **Green checks = done.** "It looks right" is not a completion state. The agent is
  finished when every gate passes, not when it stops typing.

Every branded AI-coding framework in circulation (PRP, spec-driven kits, multi-agent
methods) is a flavor of this same loop with different artifact names: a generate/plan
phase producing a context-rich document, an execute phase consuming it, and validation
gates closing the loop. Learn the loop, and every framework becomes a skin over it.

---

## Phase by phase

### Prime — load context deliberately

A fresh conversation knows nothing about the project. Priming is a scripted context
bootstrap, not an open-ended "look around":

- Structure: file listing, directory tree (depth-limited, noise-excluded).
- Documentation: global rules (CLAUDE.md), root README, architecture notes.
- Key files: entry points, config manifests, core models.
- State: recent git log, current branch/status — the git log doubles as project memory.

Output is a scannable summary: purpose, architecture, stack, conventions, current
state. On large codebases use **specialized primes** scoped to the area being touched —
see `context-engineering.md`.

### Plan — research first, template last

An effective planning pass runs in ordered stages:

1. **Understand the feature.** Extract the real problem, classify the work
   (new capability / enhancement / refactor / bug fix), assess complexity, and ask
   clarifying questions *now* — ambiguity discovered mid-implementation is the most
   expensive kind.
2. **Codebase intelligence.** Find similar implementations, naming and error-handling
   conventions, test patterns, and integration points (which files change, where new
   files go, how routers/models register). Prefer **pattern extraction over invention**:
   only design something new when nothing in the codebase fits.
3. **External research.** Current library versions, official docs with section anchors,
   known gotchas and breaking changes. Run codebase analysis and external research in
   parallel (subagents) — they are independent.
4. **Strategic design.** Choose between alternatives with explicit rationale; think
   through edge cases, ordering, security, and performance *before* task breakdown.
5. **Generate the plan document** (contract below).
6. **Validate the plan** against a completeness checklist and assign a confidence
   score with reasoning. A plan you can't score honestly at 7+/10 is not ready.

**"Vibe planning" precedes formal planning.** Before invoking a structured planning
command, it is often faster to run a short freeform research conversation: have the
agent explore the relevant modules, present options in a fixed shape
(*option / description / tradeoffs / effort*), pick one, add constraints (e.g. "only
operate inside the configured root directory"), then ask it to distill the whole
conversation into the plan document. The conversation is scaffolding; the plan file is
the artifact.

### Implement — the plan is the spec

- Read the entire plan before touching a file.
- Execute tasks in dependency order; verify syntax/imports after each change.
- Build the tests the plan specifies, then run **all** validation commands from the
  plan, fixing and re-running until each passes.
- **If reality contradicts the plan, stop and replan** — don't improvise architecture
  mid-task. Small justified deviations are fine but must be recorded (see meta-loop).

### Verify — deterministic gates, then judgment

Order matters: cheap deterministic gates first (lint → typecheck → unit tests → smoke),
then judgment passes (self code review of the diff, security review when warranted).
Auto-fix trivial findings before human-style review so reviewer attention goes to
logic, security, and architectural fit — not formatting. In this plugin the gates are
resolved per project via `references/dev/stack-resolution.md`.

---

## The plan document contract

A plan enables **one-pass implementation** when it passes the *no-prior-knowledge
test*: someone (or some agent) who has never seen the codebase could implement from
the plan alone. Required content:

| Section | Must contain |
|---------|-------------|
| Feature description | Problem, user story, why this solution was chosen |
| Mandatory reading | Exact codebase files (with line ranges) and *why each matters* |
| Research references | Doc URLs with section anchors + one-line summaries |
| Implementation plan | Foundational → core → integration work, then atomic ordered tasks |
| Per-task detail | What to implement, which pattern to mirror (file:line), imports, gotchas, and an executable validation command |
| Testing strategy | Unit / integration / e2e cases, explicit edge cases |
| Acceptance criteria | Checkable statements, not vibes |
| Validation commands | Non-interactive commands proving zero regressions |
| Confidence score | n/10 with justification |

Quality bar: no generic references ("follow the pattern" is banned — cite file:line),
every task independently testable, tasks executable top-to-bottom.

---

## Right-sizing the loop

The most common failure is running the *wrong-sized* loop. Match ceremony to scope:

| Scope | Loop | Skip |
|-------|------|------|
| Brand-new feature domain | PRD → spec → API design → scaffold → implement → full gates | nothing |
| Add function/endpoint to existing feature | single task plan → implement → gates | PRD, spec, scaffold |
| Schema field change | task plan → migration → implement → gates | PRD, spec |
| Bug fix (obvious) | task plan → fix → gates | everything else |
| Bug fix (unclear) | RCA first (below) | — |

Anti-patterns: writing a PRD for a delete endpoint; scaffolding a folder that exists;
mixing a refactor and a feature in one loop; skipping the task plan "just this once";
committing on a red gate.

**Sub-loops for large features.** When a feature is too big for one plan, run an outer
loop (master plan splitting the feature into modules) and an inner PIV loop per module
— each module planned, implemented, verified, and committed independently — then an
outer integration-and-verify pass at the end. This keeps every context window small
and every commit green.

---

## The bug flow: RCA as a handoff artifact

For non-trivial bugs, split diagnosis from repair with a written Root Cause Analysis:

1. **RCA pass**: fetch the issue, search the codebase for the error/symptom, check
   recent history of the affected paths, identify the actual root cause (not the
   symptom), assess blast radius, and propose a fix strategy. Output: an RCA document
   (root cause with file:line evidence, fix plan, testing requirements).
2. **Fix pass** (fresh context): implement strictly from the RCA — verify the bug
   still reproduces, apply the fix, add regression tests, run validation, manually
   re-run the reproduction steps.

The RCA file is the same trick as the implementation plan: a durable artifact that
lets a clean-context agent execute reliably. If the fix pass discovers the RCA was
wrong, update the RCA — don't silently diverge.

---

## The meta-loop: improve the system, not just the code

After significant implementations, run two artifacts through a **system review**:

- **Execution report** (written by the implementer): what was built, what diverged
  from the plan and why, what was hard, validation results.
- **System review** (separate pass): compares plan vs. report. This is *process*
  review, not code review — you're hunting bugs in the workflow.

Classify each divergence:

- **Good divergence** — the plan assumed something false, or a better pattern was
  found. Signal: improve the *planning* instructions.
- **Bad divergence** — ignored constraints, invented architecture, shortcuts.
  Signal: improve requirement communication or add validation.

Route findings to durable assets: add patterns/anti-patterns to the global rules,
clarify planning/execution command instructions, automate any manual step seen three
or more times as a new command, add gates that would have caught the issue earlier.
This is how a command set gets better over months instead of decaying.

---

## Parallel PIV: worktrees

PIV loops parallelize cleanly because each loop is self-contained:

- One git worktree per feature branch, one agent per worktree.
- Allocate distinct dev-server ports per worktree; smoke-test health on setup.
- Track live worktrees in a registry (branch, path, port, status) so cleanup is
  mechanical.
- Merge protocol: create a temporary integration branch, merge feature A, run the
  full gate suite, merge feature B, run gates again, and only then fast-forward the
  target branch. Conflicts or red gates abort with rollback instructions — the target
  branch never sees an unverified merge.

Vertical-slice architecture (see `ai-project-setup-patterns.md`) is what makes this
safe: parallel features touch disjoint directories.

---

## Prompting discipline (the short list)

- One task per conversation; start fresh rather than pushing a long window.
- Never implement without a plan artifact; never plan without priming.
- Make the agent ask clarifying questions before planning, not during implementation.
- Demand options-with-tradeoffs before decisions; you pick, the agent executes.
- Every instruction to "follow the pattern" must name a file and line.
- Reports at each phase boundary (plan summary, execution report) — artifacts, not
  chat scrollback, carry state between phases.
