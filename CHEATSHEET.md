# Command Center — When to Use What

A situational map: *"I'm trying to do X → reach for Y."* For the full catalogue see
[`INVENTORY.md`](INVENTORY.md); for interactive routing run `/cc:guide`; to find where you
are in a dev cycle run `/cc:next`.

Commands are `/cc:<group>:<name>`. Skills are invoked by description (just say what you want,
e.g. *"stress-test this plan"* → `grill-me`).

> **Surface note:** commands run only in Claude Code (CLI/desktop/web) — they need the repo.
> Skills also work on claude.ai chat, where commands never load; see README → *Where things
> work*. Chat-side feature planning: the `feature-interview` skill.

---

## Dev — the core loop (PIV)

The dev flow is **Plan → Implement → Verify → Release**. Pick the entry point by task size:

| Situation | Use |
|-----------|-----|
| Brand-new project from an idea | `/cc:plan:project` (scope/intent interview → charter) → `/cc:setup:project` (init) → slice 1 via `/cc:plan:feature` |
| New/unconfigured existing project | `/cc:setup:project` (classify + scaffold + stack, one shot) — or piecemeal: `/cc:setup:stack` → `/cc:plan:setup` |
| Non-trivial feature | `/cc:plan:feature` → `/cc:implement:execute` → `/cc:verify:run` → `/cc:release:commit` |
| Small, well-understood change | `/cc:plan:task` → `/cc:implement:execute` → `/cc:verify:run` → `/cc:release:commit` |
| Product spec first | `/cc:plan:prd` → `/cc:plan:spec` → `/cc:plan:feature` |
| Want it hands-off | `/cc:piv:loop` (runs the whole chain, one approval gate at commit) |
| Hands-off through to a PR, cheapest models per task | `/cc:piv:ship` (dynamic routing per `references/dev/dynamic-routing.md`) |
| Restructure without behaviour change | `/cc:implement:refactor` |
| "Where was I / what next?" | `/cc:next` · prime a fresh session with `/cc:prime` |
| Stopping mid-task for the day | `/cc:pause` (writes a session cursor) → next session `/cc:prime --resume` |
| "What does this project already remember?" | `/cc:memory` (session cursor, memory-sync, task-list, native auto-memory — one glance) |
| Branch is done — ship it | `/cc:release:ship` (verify → review → QA → commit) → `/cc:ship-pr` for the PR/merge tail |

## Dev — verifying & reviewing

| Situation | Use |
|-----------|-----|
| Fast gate before committing | `/cc:verify:run` (test + types + lint, per component) |
| One-shot "run everything" sweep | `/cc:verify:all` (`--quick`/`--full`/`--release` scorecard) |
| A test/error is failing | `/cc:verify:debug` |
| Review uncommitted/branch changes | `/cc:verify:code` → auto-fix with `/cc:verify:code-review-fix` |
| Final review before merge | `/cc:verify:pr` (diff vs main + CI + verdict) |
| Security / privacy / performance pass | `/cc:verify:security` · `/cc:verify:gdpr` · `/cc:verify:performance` |
| Test-coverage gaps | `/cc:verify:coverage` |
| Dependency & supply-chain audit | `/cc:verify:dependencies` |
| Regulation changed — what breaks in our code? | `/cc:radar:impact` (weekly digest: `/cc:radar:scan`) |
| Suppressions (`# type: ignore`, `eslint-disable`) piling up | `/cc:verify:type-ignores` |
| Holistic pre-release health | `/cc:verify:system-health` |
| Recurring/complex bug needs a writeup | `/cc:verify:rca` |
| Did the plan match reality? | `/cc:verify:execution-report` · `/cc:verify:system` |
| Check an API contract/design | `/cc:verify:api` |

## Dev — shipping

| Situation | Use |
|-----------|-----|
| Full pre-release validation | `/cc:release:validate` |
| Deploy readiness GO/NO-GO | `/cc:release:deploy` |
| Environment-variable audit | `/cc:release:env` |
| Update the changelog | `/cc:release:changelog` |
| CI pipeline from STACK.md | `/cc:setup:ci` (GitHub Actions or Azure Pipelines) |
| Apply dependency updates safely | `/cc:maintain:deps` (tiered: security → minor → major) |
| Bring docs back in sync with code | `/cc:release:docs` |
| Remove dead code / debug artifacts | `/cc:release:cleanup` |
| Something broke in prod | `/cc:release:rollback` |
| Post-deploy health watch | `/cc:verify:system-health --post-deploy` |
| Dig through logs | `/cc:debug:logs` |

## Dev — GitHub

| Situation | Use |
|-----------|-----|
| Pick up an issue end-to-end | `/cc:github:issue` |
| Fast bug fix from an issue | `/cc:github:fix` |
| Open / manage a PR | `/cc:github:pr` (early feedback: `/cc:github:draft`) |
| Sync your branch with main | `/cc:github:sync` |
| Decide what to work on | `/cc:github:list` |
| Which PRs actually need me right now | `/cc:github:digest` |

---

## Sales — by deal stage

(Condensed from the `/cc:guide` phase map — run `/cc:guide` for interactive routing.)

| Stage | Use |
|-------|-----|
| Prospecting / first call | `/cc:account:brief`, `/cc:discovery:qualify`, `/cc:account:champion` |
| Discovery | `/cc:discovery:prep` · `:questions` · `:summary` · `:ftq` · `:golden-hours`; `discovery` skill |
| Demo | `/cc:demo:storyboard` → `:script` → `:pre-invite` → `:post-followup`; `demo-dryrun-coach` skill |
| Value & pricing | `/cc:value:pain-to-value` · `:roi-case` (real-domain-math levers: `references/domains/trade/valuation/`) · `:wosr`; `pricing-positioning`, `business-case-stress-tester` skills |
| Moving / unsticking a deal | `/cc:deal:strategic-think` · `:objection-drill` · `:poc-plan` · `:champion-enable`; `champion-health` skill |
| Proposal & exec | `/cc:deal:proposal` · `:exec-summary`; `exec-briefing-prep` skill |
| RFP / RFI / tender | `rfx-navigator` skill → `/cc:rfp:analyze` → `:respond` → `:present` |
| Handover to delivery | `/cc:handover:doc` · `:osd-draft`; `osd-architect` skill |
| Before anything goes to the customer | `confidence-tagger` skill (tag every unverified claim) |
| Prospect's tariff/regulatory exposure | `/cc:account:exposure` · watchlist outreach: `/cc:radar:brief` |
| PoC ended — score it for the champion | `/cc:deal:poc-readout` |

---

## Life — personal decisions (US-anchored, decision prep not professional advice)

None of these need company/brand setup — they work with zero configuration.

| Situation | Use |
|-----------|-----|
| A dilemma with no dedicated council below | `/cc:life:council` — the general engine, assembles whichever expert "hats" fit |
| A big purchase (car, appliance, tech) | `/cc:life:big-purchase-council` |
| Money — invest, pay down debt, buy vs rent, Roth conversion | `/cc:life:finance-council` |
| Buy vs rent, renovate, refinance, relocate | `/cc:life:home-council` |
| A health decision, what to ask your clinician | `/cc:life:health-council` (decision prep, NOT medical advice) |
| A family disagreement or decision | `/cc:life:family-council` (decision prep, NOT therapy) |
| Recurring costs / subscriptions creeping up | `/cc:life:subscriptions-audit` |
| Is my insurance coverage right | `/cc:life:insurance-review` |
| A bureaucratic task (SSA / IRS / USCIS / DMV / state benefits / VA) | `/cc:life:benefits-navigator` |

---

## Skills worth knowing (say what you want)

| Want to… | Skill |
|----------|-------|
| Plan a feature from chat (no repo) → Feature Brief for `/cc:plan:feature` | `feature-interview` |
| Stress-test a plan/design before building | `grill-me` |
| Hand a session off to another agent | `handoff` |
| Draw an architecture/flow diagram | `diagram` |
| Run a full defensive security audit → report | `security-audit` |
| Run a GDPR/privacy assessment → report | `gdpr-check` |
| Write a runbook / SOP | `sop-creator` |
| Add or improve a cc skill | `skill-creator` / `write-a-skill` |
| Handle an objection live | `tactical-empathy-coach` |
| Map & qualify a prospect account | `account-intelligence`, `supply-chain-map` |

---

## Setup & maintenance (meta)

| Situation | Use |
|-----------|-----|
| First-time identity (company, products, brand colors) | `/cc:setup:configure` |
| Add your logo / confirm colors & fonts (guided, no file editing) | `/cc:setup:brand` |
| Teach a project its stack (test/lint/build commands) | `/cc:setup:stack` |
| Health-check the plugin (placeholders, drift, broken refs, hardcoded stack) | `/cc:maintain:audit` (mechanical half: `bash scripts/cc-audit.sh`) |
| Run a cc command on a schedule (weekly audit, post-deploy polling) | [`references/dev/scheduling.md`](references/dev/scheduling.md) — `/loop` vs Desktop Tasks vs Routines vs cron |
| Give the plugin to a teammate | repo-root [`README.md`](../README.md) → "Sharing with your team" |
| See everything available | read [`INVENTORY.md`](INVENTORY.md) or run `/cc:guide list` |

---

**Rule of thumb:** unsure which command? Just describe what you're doing — **`/cc:find`**
routes you across dev, sales, and life (it falls back to `/cc:guide` for deep sales routing or
`/cc:next` for the dev cycle). Unsure if a command fits your stack? It reads the project's
`STACK.md` — run `/cc:setup:stack` first (see [`STACK_SETUP.md`](STACK_SETUP.md)).
