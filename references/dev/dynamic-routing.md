# Dynamic Model Routing — runtime routing for chain commands

> How orchestrating commands (`/cc:piv:ship`) pick the cheapest capable model **per task at
> runtime**, instead of running an entire chain on the session model. Complements — does not
> replace — the static `model:`/`effort:` frontmatter policy in `model-routing.md`: static
> tags route *commands*; this document routes *tasks inside a chain*. Distilled from the
> session-model-inherits principle plus the context-firewall patterns in
> `piv-methodology.md` (subagents return summaries, never transcripts).

## Why

A chain run is mostly execution of decisions already made. Paying frontier-model rates for
mechanical file authoring wastes tokens; paying them for *judgment* (architecture, domain
rubrics, adversarial review) is the whole point. The router's job is to keep each task on
the cheapest tier that clears the task's acceptance bar — and to escalate automatically
when it doesn't.

## Routing precedence (first match wins)

1. **Plan-declared routing.** If the plan document declares models, obey it — the planner
   had the most context. Two recognized conventions (both used by house plans):
   - a **routing table**: any markdown table whose header row contains a `Model` column;
     rows map work items/phases to `fable | opus | sonnet | haiku` (row's first column is
     matched against phase/task headings by substring).
   - **phase-heading tags**: a heading containing `— model: **<alias>**` routes every task
     under that heading.
   A plan may mix both; a task-level entry beats a phase-level one.
2. **Invoked-command frontmatter.** When a chain step *is* a `/cc:` command that carries a
   `model:`/`effort:` tag, the tag applies (e.g. `radar:scan` is tagged `sonnet`).
3. **Task-type heuristics** (when the plan is silent):

   | Task type | Model | Effort | Rationale |
   |---|---|---|---|
   | File moves/renames, count updates, mechanical sweeps with exact specs | haiku | low | No judgment left; acceptance is a grep |
   | Authoring code/commands/docs against a fully-specified design | sonnet | default | The executing-a-≥9/10-plan tier |
   | Independent code review (intermediate rounds) | sonnet | default | Rubric-following, not rubric-writing |
   | Architecture/design decisions, domain rubrics/exemplars, adversarial red-team, final full-diff review before a merge | inherit (session) | default/high | Judgment where the ceiling is the product |
   | Deterministic verification (cc-audit, test gates, shellcheck) | — (bash, no model) | — | Never spend tokens on what a script does |

4. **Default:** inherit the session model. When genuinely unsure, route UP one tier, not
   down — a wasted sonnet call costs less than a shipped haiku mistake.

## Escalation rule (automatic, bounded)

A routed subagent's output **escalates one tier** (haiku → sonnet → session model) and
re-runs **once** when any of:
- it fails its task's stated acceptance criteria;
- it self-reports confidence below 7/10 or explicitly flags the task as beyond its brief;
- the verify pass or reviewer raises a HIGH+ finding against that task's output.

One escalation per task, ever — a task that fails at the escalated tier STOPS the chain and
surfaces (this is a plan-quality problem, not a model-tier problem). Never de-escalate a
task mid-chain, and never reclassify a failure as "acceptable" to avoid escalating.

## Context economy rules (the token savings beyond model choice)

1. **Task-slice briefs.** A task subagent receives its task's spec, acceptance criteria,
   and the named files it touches — never the whole plan, never the chain transcript.
2. **Summary-only returns.** Subagents report: files changed, acceptance results, one-line
   deviations, confidence. The orchestrator never ingests raw diffs it can `git diff` for.
3. **Fork the heavy, keep the ledger light.** Standalone heavy steps (full audits, large
   reference authoring) run in isolated subagent context; the orchestrator maintains only a
   compact ledger (task → model used → result → escalations) that feeds the execution
   report.
4. **Parallelize within a phase only.** Tasks in the same phase with disjoint file sets run
   as parallel subagents; phase boundaries are barriers (later phases consume earlier
   outputs). Disjointness is judged by the plan's per-task file lists — overlapping tasks
   run sequentially.
5. **Report the spend.** The chain's execution report includes the routing ledger so
   routing decisions are auditable and the heuristics table can be tuned from evidence.

### Adopting the ledger outside PIV chains

The four-column ledger (task → model used → result → escalations) isn't PIV-specific —
any multi-step command or skill that forks subagents can keep the same ledger and print
it in its own output. The pattern is exactly the rules above (task-slice briefs,
summary-only returns, fork-the-heavy, parallelize disjoint work, report the spend); a
chain doesn't need to be a registered PIV step to benefit from it. This is additive
guidance only — it doesn't change how `piv:ship` or any existing chain already uses the
ledger, it just says the same four columns are fair game anywhere a command orchestrates
several subagent calls and wants its cost/routing decisions to be auditable.

## Worked example

`.specify/plans/domain-trade-radar-research-valuation.md` declares: Phase 1 headings tagged
`— model: **fable**`, Phases 2–3 `— model: **sonnet**`, plus a routing-summary table adding
runtime tags. The router: Phase 1's five tasks → session-tier subagents (parallel where
file-disjoint); Phase 2's seven → sonnet; Phase 3 → sonnet with the deterministic gate steps
run as bash, no model. Escalation available sonnet → session on any acceptance failure.
