# Industry Solutions PIV Loop Cheatsheet
**v1.2 — Plan — Implement — Verify, on loop. Then Release.**

---

## How to Use This Sheet

Every session begins with `/prime`. Then run the PIV loop — Plan, Implement, Verify — until the gate is green. Only then do you Release.

If Verify fails, return to Plan or Implement. The loop continues until green.

> **Loop the loop. Plan, Implement, Verify. Release is the reward — not the reflex.**

---

## The Four Phases

### P — PLAN (15-30 min)
Build shared understanding before writing code.

| Command | What it does |
|---|---|
| `/prime` | Load project context. Every session. |
| `/plan:task` | Plan any single change — the minimum for any work. |
| `/plan:prd` | Define WHAT and WHY for a brand-new feature. |
| `/plan:spec` | Convert PRD into a technical spec. |
| `/plan:api` | Design the REST contract before coding endpoints. |
| `/plan:feature` | Scaffold the feature folder once the plan is approved. |
| `/plan:service` | Adding Redis, Supabase or other infra? Start here. |

**RULE: Never implement without a plan.**

---

### I — IMPLEMENT (30 min to hours)
Build exactly what the plan says — nothing more.

| Command | What it does |
|---|---|
| `/implement:execute` | Build the feature or function end-to-end. |
| `/implement:migrate` | Guided DB migration: generate — review — apply. |
| `/implement:refactor` | Restructure code without changing behaviour. |

**RULE: If you find yourself wandering off the plan, stop and replan.**

---

### V — VERIFY (5-20 min)
All gates green before you commit.

**Fast — every change:**

| Command | What it does |
|---|---|
| `/verify:run` | Tests + types + lint. After every change. |
| `/verify:code-review-fix` | Auto-fix obvious issues. Run before review. |
| `/verify:code` | Review your own diff. Always before commit. |

**Specialised — when the situation calls:**

| Command | What it does |
|---|---|
| `/verify:debug` | Diagnose a failing `/verify:run`. |
| `/verify:execution-report` | Summary of changes for the team. |
| `/verify:pr` | Full branch review before merging to main. |
| `/verify:api` | API design review after new endpoints. |
| `/verify:coverage` | Find test coverage gaps. |
| `/verify:performance` | Profile slow queries or suspected N+1. |
| `/verify:security` | OWASP audit before production deploy. |
| `/verify:dependencies` | Outdated and vulnerable packages. |
| `/verify:system-health` | Holistic health check before deploy. |
| `/verify:type-ignores` | Audit type suppressions. Quarterly cleanup. |
| `/verify:rca` | Root cause analysis. Required after production incidents. |

**RULE: If it isn't green, it isn't done.**

---

### R — RELEASE (5-60 min)
Ship to production safely, never blindly.

**Commit chain — in order:**

| Command | What it does |
|---|---|
| `/release:commit` | Create a git commit with a sensible message. |
| `/release:docs` | Update README and architecture docs. |
| `/release:changelog` | Generate changelog before a version bump. |
| `/release:cleanup` | Remove dead code and debug prints. Quarterly. |

**Deploy chain — in order:**

| Command | What it does |
|---|---|
| `/release:validate` | Full validation: tests + Docker + types. |
| `/release:env` | Audit env vars and secrets before prod. |
| `/release:deploy` | Pre-deploy checklist — final go / no-go. |
| `/release:rollback` | Reverse the last deploy if things go sideways. |

**RULE: Friday deploys are weekend deploys in disguise.**

---

## Which Loop Are You Running?

### Scenario 1 — From Scratch
**Brand-new feature. Brand-new folder.**

Use when no folder yet exists for this domain. Bigger plan, full scaffold, broad test coverage.

**Steps:**
1. `/prime` — load context
2. `/plan:prd` — what and why
3. `/plan:spec` — API + schema + logic
4. `/plan:api` — REST contract
5. `/plan:feature` — scaffold the folder
6. `/implement:execute` — build everything
7. `/verify:run` — `/verify:code-review-fix` — `/verify:code` — gate green
8. `/github:draft` — `/github:sync` — team feedback
9. `/release:commit` — `/release:deploy` — `/verify:system-health --post-deploy` — ship and watch

**Time: 3-5 hours**

---

### Scenario 2 — Add a Function
**Feature exists. You are adding to it.**

Use when the folder is already in the codebase and you are adding one endpoint, query, or behaviour. Skip the PRD. Skip the scaffold.

**Steps:**
1. `/prime` — load context
2. `/plan:task` — scope this change only
3. `/implement:execute` — add function and tests
4. `/implement:migrate` — only if DB field changes
5. `/verify:run` — tests + types + lint
6. `/verify:code-review-fix` — auto-fix obvious issues
7. `/verify:code` — review the diff
8. `/release:commit` — done

**Time: ~50 min**

---

## Scenario Comparison

| Aspect | Scenario 1 — From Scratch | Scenario 2 — Add Function |
|---|---|---|
| Planning | `/plan:prd` + `/plan:spec` + `/plan:api` | `/plan:task` only |
| Scaffolding | `/plan:feature` creates folder | None — folder exists |
| Files | 10+ new files | Update 3-4 existing |
| Database | New table + migration | Only if adding a field |
| Tests | Cover all paths (10+) | 2-3 tests for new function |
| Time | 3-5 hours | 30-50 min |
| Complexity | High — many decisions | Low — clear direction |

---

## Start Here — What Are You Building?

**Brand-new feature — no folder yet?**
Scenario 1 — From Scratch
`/plan:prd` — `/plan:spec` — `/plan:api` — `/plan:feature` — approx. 3-5 hours

**Adding one endpoint or function to an existing feature?**
Scenario 2 — Add Function
`/plan:task` — `/implement:execute` — approx. 50 min

**Adding a new field to an existing model?**
Scenario 2 + migration
`/plan:task` — `/implement:migrate` — `/implement:execute` — approx. 1 hour

**Fixing a bug in existing code?**
Scenario 2 — Minimal
`/plan:task` — `/implement:execute` — `/verify:run` — approx. 20-40 min

---

## Use Scenario 1 — From Scratch When...

- The feature folder doesn't exist yet.
- The work needs PRD alignment with another team.
- It touches auth, payment, or another sensitive system.
- The API contract needs careful design discussion.
- Multiple endpoints and complex logic are involved.

## Use Scenario 2 — Add Function When...

- The feature folder already exists.
- You are adding one endpoint or one function.
- No PRD is needed — scope is clear.
- No cross-team discussion is required.
- The whole thing fits in `/plan:task`.

---

## Don't Do This

- Run `/plan:prd` for adding a delete endpoint.
- Run `/plan:feature` when the folder already exists.
- Mix a refactor and a feature in one change.
- Skip `/plan:task` "just this once."
- Commit on a red `/verify:run`.
- Deploy without `/release:env` — silent secrets bugs are the worst.

---

## Additional Tools

### Debug and Monitor
| Command | What it does |
|---|---|
| `/debug:logs` | Parse structured logs. Trace by request ID. |
| `/verify:system-health --post-deploy` | Check health endpoints. Post-deploy and continuous — see `references/dev/scheduling.md` for polling. |

### GitHub — Issues, PRs, Sync
`/github:list` — `/github:issue` — `/github:draft` — `/github:sync` before merge.

| Command | What it does |
|---|---|
| `/github:list` | Browse open issues by label or assignee. |
| `/github:issue` | Implement an issue end-to-end — plan, build, verify. |
| `/github:fix` | Fast-path bug fix from an issue ID. |
| `/github:assign` | Assign an issue to yourself or a teammate. |
| `/github:comment` | Post a status or clarifying comment. |
| `/github:close` | Close an issue with a wrap-up note. |
| `/github:draft` | Open a draft PR early for feedback. |
| `/github:sync` | Sync with main before merge. Every time. |
| `/github:pr` | Create, update, or merge PRs. Use `--merge` to ship. |

### Skills — Targeted Shortcuts
| Command | What it does |
|---|---|
| `/rulecheck` | Find and fix CLAUDE.md violations. |
| `/triage` | Label and sort GitHub issues. Weekly. |
| `/archon` | Delegate to remote agents for parallel work. |
| `/create:diagram` | Generate architecture diagrams after planning. |

---

> **Right-size the loop. The plan is cheap. The cleanup isn't.**
>
> **Every command has its place. Run them in order. The right command at the wrong time is still the wrong command.**
