---
name: piv-orchestrator
description: Diagnoses where you are in the development cycle (PIV loop) by inspecting actual project state — git, plans, execution reports, code reviews, validation — and routes to the right slash command, skill, or agent; can launch the next step directly. Use when the user says "what should I do next", "what's next", "where was I", "I'm stuck", "guide me", "PIV status", "which command should I use", "continue where we left off", or "orchestrate this".
---

# PIV Orchestrator

The "what should I do next" concierge for this project's PIV workflow. It does not guess and it does not interrogate the user about things it can detect: it inspects the repo, maps the evidence to a PIV phase (Prime → Plan → Implement → Verify → Release), and recommends exactly one next action — offering to run it immediately.

---

## Step 1 — Diagnose actual state (don't ask what you can detect)

Run these checks before saying anything. Each is cheap; run them in parallel where possible.

| Check | How | What it tells you |
|-------|-----|-------------------|
| Working tree | `git status --short` | Uncommitted changes = work in flight; clean = between cycles |
| Branch | `git branch --show-current` | On main = nothing started or just synced; feature branch = mid-cycle |
| Recent history | `git log --oneline -10` | What was last shipped; whether the last commit matches the stated goal |
| Plans | List `${user_config.workspace_dir}/plans/` by modified time | The newest plan is the active intent |
| Execution reports | List `${user_config.workspace_dir}/execution-reports/` | **A plan without a matching execution report = work in flight** (planned but not implemented, or implemented but not reported) |
| Code reviews | List `${user_config.workspace_dir}/code-reviews/`; read the newest | Open findings (CRITICAL/HIGH not marked resolved) = fix loop pending |
| System reviews | List `${user_config.workspace_dir}/system-reviews/` | Recent process pain already captured |
| Security / GDPR reports | List `${user_config.workspace_dir}/reports/security/` and `${user_config.workspace_dir}/reports/gdpr/` | Whether a pre-release audit exists for the current state |
| Validation signals | Look for failing-test output in recent context; if unknown and changes exist, validation status is **unknown**, not "passing" | Whether /cc:verify:run has run on the current diff |
| Open PRs | `gh pr list --limit 10` (skip silently if `gh` unavailable or not a GitHub repo) | Review/merge work outstanding |
| Open issues | `gh issue list --limit 10` (optional, same caveat) | Candidate next goals |

Only ask the user one thing, and only if the evidence doesn't answer it: **"What is the goal right now?"** — and only when nothing is in flight.

## Step 2 — Map state to PIV phase

Apply the first matching row, top to bottom:

| Observed state | Phase | Route to |
|----------------|-------|----------|
| Fresh session, no context loaded yet | Prime | `/prime` |
| User states a goal, full hands-off cycle wanted | All | `/cc:piv:loop "<goal>"` |
| No plan exists for the stated goal | Plan | `/cc:plan:feature` (or `/cc:plan:prd` for a whole product area, `/cc:plan:task` for a small change) |
| Plan exists, no matching execution report, working tree clean | Implement | `/cc:implement:execute` with that plan |
| Plan exists, partial/uncommitted changes match it | Implement | Resume `/cc:implement:execute` from where the diff stops |
| Bug reported, root cause unknown | Verify | `/cc:verify:rca` (or `/cc:github:fix` if it's a GitHub issue) |
| Uncommitted changes, validation status unknown | Verify | `/cc:verify:run` |
| Validation green, no code review for the diff | Verify | `/cc:verify:code` |
| Code review has open findings | Verify | `/cc:verify:code-review-fix` (max 2 fix→re-validate loops, then `/cc:verify:debug`) |
| Validation failing repeatedly / confusing error | Verify | `/cc:verify:debug` |
| Diff touches auth, secrets, input handling, or deps | Verify | `/cc:verify:security` before the commit gate |
| All green, execution report missing | Verify | `/cc:verify:execution-report` |
| All green, uncommitted, report exists | Release ⛔ | `/cc:release:commit` — **this is the approval gate; never auto-commit** |
| Committed, PR wanted or branch behind main | Release | `/cc:github:pr` / `/cc:github:draft` / `/cc:github:sync` |
| Committed, docs or changelog stale | Release | `/cc:release:docs`, `/cc:release:changelog` |
| Recurring process pain, repeated friction across cycles | Improve | `/cc:verify:system` |
| Pre-release or officer review needed | Audit | `security-audit` skill (full report) or `gdpr-check` skill |
| Brand-new/unconfigured project, nothing runs yet | Plan | `/cc:plan:setup` |
| PRD exists but work spans many features/slices | Plan | `/cc:plan:spec`, then `/cc:plan:feature` per slice |
| Schema or data migration pending | Implement | `/cc:implement:migrate` |
| Deployment imminent | Release | `/cc:release:deploy` (GO/NO-GO checklist) |
| Production incident, bad deploy live | Release | `/cc:release:rollback`, then `/cc:verify:rca` |
| Perf-sensitive change or slowness reported | Verify | `/cc:verify:performance` |
| Dependency hygiene due (routine or pre-release) | Verify | `/cc:verify:dependencies` |
| Nothing in flight, no stated goal | — | Ask for the goal; suggest `/cc:piv:loop "<goal>"` or `/cc:plan:feature`, or `/cc:github:list` to pick an issue |

**The chain** (what `/cc:piv:loop` runs hands-off): prime → plan:feature → implement:execute → verify:run → verify:code (→ verify:code-review-fix loop, max 2) → verify:security → verify:execution-report → ⛔ GATE (user approval) → release:commit → optional verify:system.
**Bug fast path:** `/cc:github:fix` or `/cc:verify:rca` → plan → execute → validate → commit gate.

## Step 3 — Recommend and (optionally) run

Output exactly this shape:

```
**Where you are:** <one or two lines of evidence — branch, plan name, diff size, review status>

**Next:** /<command> — <one-line why>

Alternatives (max 2):
- /<alt-1> — <when you'd prefer it>
- /<alt-2> — <when you'd prefer it>

Run the next step now? [y/n]
```

- Exactly **one** primary recommendation. Never a menu of five.
- Offer to launch it immediately via the SlashCommand tool.
- In an explicit "run it" or autonomous context (user said "just do it", "continue", or the session is inside `/cc:piv:loop`): skip the question and invoke the command directly.
- Exception: never auto-run `/cc:release:commit` — it is the approval gate and always requires explicit user confirmation of the summary.
- Some commands are user-invoked only (`disable-model-invocation: true` — deliberate entry points like `/cc:verify:pr` or `/cc:plan:api`). If one can't be invoked for that reason, don't retry — give the user the exact command line to type, arguments pre-filled.

---

## Routing map — the full pack (reference)

This skill is the single map of this project's development commands. One line per item: use when.

### Commands

| Command | Use when |
|---------|----------|
| `/prime` | Start of any session — load project context before doing anything |
| `/cc:piv:loop` | You want the full PIV chain run hands-off on a feature, gated only at commit |
| `/next` | Command form of this skill — diagnose state, run/recommend the next step |
| `/guide` | Print the how-to guide: the loop, all commands, scenario playbook |
| `/cc:plan:setup` | New or unconfigured project — scaffold to a first green validate |
| `/cc:plan:prd` | A whole product area or multi-feature effort needs a requirements document |
| `/cc:plan:spec` | PRD → technical blueprint for multi-slice work (contracts, data model, slice order) |
| `/cc:plan:feature` | A single feature needs a researched implementation plan in `${user_config.workspace_dir}/plans/` |
| `/cc:plan:task` | A small, scoped change still deserves a written plan before code |
| `/cc:plan:agent` | Scaffold a new Pydantic AI agent feature slice |
| `/cc:plan:api` | Design the REST API contract before implementing endpoints |
| `/cc:plan:service` | Add Supabase, Redis, pgvector, auth, email, or another service |
| `/cc:implement:execute` | A plan exists and it's time to build it |
| `/cc:implement:refactor` | Restructure code without changing behaviour |
| `/cc:implement:migrate` | Schema/data migration — reviewed and bidirectionally tested before it lands |
| `/cc:verify:run` | Run the fast validation gate — tests + types + lint (may delegate to the `validation-runner` agent for large suites) |
| `/cc:verify:coverage` | Find coverage gaps and generate missing test suggestions |
| `/cc:verify:api` | API design review — naming, status codes, pagination, auth |
| `/cc:verify:type-ignores` | Audit every `# type: ignore` / `# pyright: ignore` suppression |
| `/cc:verify:system-health` | Operational health check — endpoints, DB, Docker, env vars |
| `/cc:verify:code` | Review the current diff before committing (delegates to `code-reviewer`) |
| `/cc:verify:code-review-fix` | Auto-fix the correctable findings from a code review, then re-validate |
| `/cc:verify:pr` | Full review of a branch/PR, not just the working diff |
| `/cc:verify:debug` | Diagnose a failing test or confusing error methodically |
| `/cc:verify:rca` | Root-cause analysis of a bug before planning the fix |
| `/cc:verify:security` | Quick security scan of the current diff (delegates to `security-auditor`); CRITICAL halts the chain |
| `/cc:verify:gdpr` | Quick GDPR/data-protection check of the current diff (delegates to `gdpr-auditor`) |
| `/cc:verify:performance` | Static performance review — N+1s, missing pagination, sync-in-async, cache wins |
| `/cc:verify:dependencies` | Dependency & supply-chain audit — CVEs, outdated packages, unpinned CI |
| `/cc:verify:execution-report` | Write the execution report to `${user_config.workspace_dir}/execution-reports/` |
| `/cc:verify:system` | Post-commit process review — what about the *workflow* should improve |
| `/cc:release:commit` | ⛔ The approval gate — present summary, get explicit approval, then commit |
| `/cc:release:changelog` | Generate/update the changelog from commits |
| `/cc:release:docs` | Bring documentation in line with what shipped |
| `/cc:release:cleanup` | Remove dead code/content after a change settles |
| `/cc:release:deploy` | Pre-deployment readiness checklist with a GO / NO-GO verdict |
| `/cc:release:rollback` | Production incident — safe reversal, then hand off to `/cc:verify:rca` |
| `/cc:release:env` | Env var security audit — secrets, missing vars, .env in git |
| `/cc:release:validate` | Full validation including the Docker build (pre-release) |
| `/cc:verify:system-health --post-deploy` | Watch health endpoints after a deployment |
| `/cc:github:issue` | Pick up a GitHub issue end-to-end (plan → fix → PR) |
| `/cc:github:fix` | Fast-path bug fix straight from an issue |
| `/cc:github:pr` | Create or manage a pull request |
| `/cc:github:draft` | Open a draft PR for early feedback |
| `/cc:github:sync` | Get the branch back in sync with main |
| `/cc:github:list` | List/filter open issues to choose the next goal |
| `/cc:debug:logs` | Parse and analyse log files for errors and patterns |

### Skills

| Skill | Use when |
|-------|----------|
| `piv-orchestrator` | (this skill) Unsure what to do next — diagnose state and route |
| `security-audit` | Full, officer-ready security report with gap analysis → `${user_config.workspace_dir}/reports/security/` |
| `gdpr-check` | GDPR/data-protection report with remediation backlog → `${user_config.workspace_dir}/reports/gdpr/` |
| `skill-creator` | Create or improve a skill in this project |
| `sop-creator` | Write a runbook, SOP, or playbook for a repeatable process |
| `rulecheck` | Autonomous code-quality cycle — finds and fixes CLAUDE.md rule violations, opens a PR |
| `triage` | Label GitHub issues with type/effort/priority/area via the `triage-agent` |
| `archon` | Delegate a workflow to the Archon remote agentic platform |

### Subagents

| Agent | Use when |
|-------|----------|
| `code-reviewer` | Technical review of a diff or branch — used by `/cc:verify:code` and `/cc:verify:pr` |
| `security-auditor` | Security analysis of code/diffs — used by `/cc:verify:security` and the `security-audit` skill |
| `gdpr-auditor` | Data-protection analysis — used by `/cc:verify:gdpr` and the `gdpr-check` skill |
| `validation-runner` | Runs full validation suites and returns a compact result — optional delegate for `/cc:verify:run` and `/cc:release:validate` on large suites |
| `validator` | Creates simple focused unit tests for what was just built and runs them — auto-invoked after implementation |
| `codebase-analyst` | Deep codebase scan for patterns and conventions — invoked before implementing |
| `rulecheck-agent` | Autonomous quality enforcer behind the `rulecheck` skill |
| `triage-agent` | GitHub issue triage specialist behind the `triage` skill |

### Working directories

| Path | Contents |
|------|----------|
| `${user_config.workspace_dir}/plans/` | Implementation plans (`<kebab-name>.md`) |
| `${user_config.workspace_dir}/execution-reports/` | What was actually built, per plan |
| `${user_config.workspace_dir}/code-reviews/` | Review findings per diff/branch |
| `${user_config.workspace_dir}/system-reviews/` | Process retrospectives |
| `${user_config.workspace_dir}/reports/security/` | Security audit reports |
| `${user_config.workspace_dir}/reports/gdpr/` | GDPR check reports |

---

## Quality checklist

- [ ] State was diagnosed from evidence (git + `${user_config.workspace_dir}/` artefacts), not from asking the user detectable facts
- [ ] Exactly one primary recommendation, with a one-line why
- [ ] No more than 2 alternatives offered
- [ ] Recommendation cites the evidence that led to it
- [ ] Offered to run the next step (or ran it, in an autonomous context)
- [ ] `/cc:release:commit` was never auto-run — the gate always asks
