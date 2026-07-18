# Command Center — Command & Skill Inventory

## Dev Commands

<!-- BEGIN GENERATED: dev-commands -->
| Command | Group | Description |
|---------|-------|-------------|
| `/cc:piv:loop` | piv | Run the full autonomous PIV loop on a feature — plan, implement, verify, gate, commit |
| `/cc:piv:ship` | piv | Full plan-or-idea → merged-PR chain with per-task dynamic model routing — plan (or reuse a plan), implement across routed subagents, verify every phase, gate on commit, ship. Use when the ask is "take this idea all the way to a merged PR" or "run the whole thing, but route the grunt work to a cheaper model" |
| `/cc:plan:agent` | plan | Scaffold a Pydantic AI agent as a vertical slice in the FastAPI backend |
| `/cc:plan:api` | plan | Design REST API contract before implementing endpoints |
| `/cc:plan:feature` | plan | Deep implementation planning — produce a context-rich plan that enables one-pass implementation |
| `/cc:plan:prd` | plan | Write a product requirements document through structured questioning |
| `/cc:plan:project` | plan | Greenfield project inception — interview a fuzzy idea into an implementation-ready project charter. Use when starting a new project, "I have an idea for an app," or planning something new from scratch. |
| `/cc:plan:service` | plan | Add a new service to this project (database, cache, auth, AI/RAG, storage, email, etc.) |
| `/cc:plan:setup` | plan | Initialize a new project or claim an existing one — scaffold basics, install dependencies, start services, prove a green baseline |
| `/cc:plan:spec` | plan | Convert a PRD into a technical specification with module breakdown, contracts, data model, and a slice-by-slice delivery order |
| `/cc:plan:task` | plan | Lightweight planning for small, well-understood changes — same plan format, minimal process |
| `/cc:implement:execute` | implement | Core Execute — turn a spec or plan into working, validated code, task by task |
| `/cc:implement:migrate` | implement | Guided Alembic migration — generate, review line-by-line, test up→down→up, apply safely |
| `/cc:implement:refactor` | implement | Restructure code without changing behaviour — baseline green, small reversible steps, re-validate each step |
| `/cc:verify:a11y` | verify | Accessibility audit of the change-set or full repo — static WCAG checks plus optional runtime axe pass, severity-rated findings, PASS/WARNINGS/FAIL verdict |
| `/cc:verify:all` | verify | One-shot "run everything" verification orchestrator — sequences the verify:* gate and reviews, then reports a single scorecard with a GO / FIX FIRST verdict |
| `/cc:verify:api` | verify | Review the API design for consistency, correctness, and developer experience |
| `/cc:verify:bundle` | verify | Build-artifact budget audit — build what ships (route JS, chunks, assets, images, container), measure it against STACK.md budgets, and report trend deltas with a PASS/WARNINGS/FAIL verdict |
| `/cc:verify:code` | verify | Technical code review of uncommitted or branch changes, with severity-rated findings saved to ${user_config.workspace_dir}/code-reviews/ |
| `/cc:verify:code-review-fix` | verify | Auto-fix CRITICAL/HIGH and obvious MEDIUM findings from the latest code review, then re-validate |
| `/cc:verify:codebase` | verify | Full codebase scan — static analysis, AI-smell detection, and security spot-check across all source files. Use periodically, before a major release, or when onboarding to a codebase. |
| `/cc:verify:coverage` | verify | Analyse test coverage, find gaps, and generate targeted suggestions for missing tests |
| `/cc:verify:debug` | verify | Systematically diagnose a failing test or error — reproduce, classify, hypothesize, fix the root cause with a regression test |
| `/cc:verify:dependencies` | verify | Audit dependencies and supply chain — known CVEs, version hygiene, lockfile drift, CI action pinning, install-script risk |
| `/cc:verify:design` | verify | Architecture review of the change — UX, AI design, and cross-system seams — via relevance-gated parallel heads, findings saved by severity |
| `/cc:verify:e2e` | verify | Run the project's end-to-end suite — provision the device/simulator environment (e2e:setup), then execute the smoke subset (or the full suite with --full). Opt-in per project via STACK.md e2e:* steps; unmapped projects report "not configured" and exit green. Use on "run e2e", "run the maestro/detox/playwright suite", "device QA gate". |
| `/cc:verify:execution-report` | verify | Write the execution report — plan vs actual, classified divergences, validation results — before the commit gate |
| `/cc:verify:gdpr` | verify | GDPR/privacy gate — scan the change-set for new personal-data processing, or run a full compliance assessment |
| `/cc:verify:performance` | verify | Static performance review of the diff or a target area — N+1s, missing indexes, unbounded queries, sync-in-async, cache candidates |
| `/cc:verify:pr` | verify | Full branch review before merge — diff vs main, commit hygiene, breaking changes, validation, MERGE READY / NEEDS CHANGES verdict |
| `/cc:verify:qa` | verify | Generate a manual QA testing checklist for the current change-set — feature, cross-cutting, and regression tests, as a self-contained interactive HTML companion (with an optional Markdown version) |
| `/cc:verify:rca` | verify | Write a root cause analysis document for a complex or recurring bug — timeline, evidence, 5 whys, prevention |
| `/cc:verify:run` | verify | Fast verification gate — tests + types + lint (PIV Phase 3) |
| `/cc:verify:security` | verify | Security scan of the current change-set or the full repo — OWASP checks, severity-rated findings, PASS/WARNINGS/FAIL verdict |
| `/cc:verify:system` | verify | Post-commit system review — analyze plan adherence across the loop and improve the process itself |
| `/cc:verify:system-health` | verify | Holistic system health check before release, on schedule, or post-deployment |
| `/cc:verify:test` | verify | Author tests for the changed code — detect the project's framework, cover the diff with happy-path, edge, and failure cases, and run them green |
| `/cc:verify:test-quality` | verify | Audit whether the tests actually catch bugs — nine test-smell checks (assertion-free, mock-the-subject, snapshot-only, flaky waits, …) plus an optional guarded mutation-lite probe, with a PASS/WARNINGS/FAIL verdict |
| `/cc:verify:type-ignores` | verify | Audit all type/lint suppressions — find every suppression, investigate why it exists, recommend resolution |
| `/cc:release:changelog` | release | Generate or refresh CHANGELOG.md from commits since the last tag, in Keep a Changelog format |
| `/cc:release:cleanup` | release | Find and remove dead code, debug artifacts, and stale content — with confidence classification and confirmation before deleting |
| `/cc:release:commit` | release | Create well-structured conventional commits — the single approval gate of the PIV chain |
| `/cc:release:deploy` | release | Pre-deployment readiness gate — validation, security, env audit, migrations, container build, smoke test, changelog — ends in GO / NO-GO |
| `/cc:release:docs` | release | Update project documentation to match the current code and verify every count, path, and claim against reality |
| `/cc:release:env` | release | Audit environment variables for security, completeness, and documentation |
| `/cc:release:rollback` | release | Incident rollback playbook — classify the failure, return to the last known-good state safely, verify health, capture the timeline |
| `/cc:release:ship` | release | End-to-end ship pipeline for an already-implemented feature branch — full verify gate, diff review, QA, and the commit gate — then hands off to the PR/merge step |
| `/cc:release:validate` | release | Full pre-release validation — tests, types, lint, local server, and Docker deployment |
| `/cc:git:guide` | git | Interactive git mentor — describe what happened (or what you want), get a diagnosis from real repo state, the exact commands with safety tiers, and the why behind them |
| `/cc:github:digest` | github | Sweep your open PRs (and stale local branches) into a needs-you-now / ready-to-merge / in-flight board |
| `/cc:github:draft` | github | Open a draft pull request for early feedback while implementation is still in progress |
| `/cc:github:fix` | github | Fast-path bug fix from a GitHub issue — reproduce, minimal fix, validate, PR |
| `/cc:github:issue` | github | Pick up a GitHub issue end-to-end — read, plan, branch, run the PIV chain, link the PR back |
| `/cc:github:list` | github | List and filter open issues and PRs to pick what to work on next |
| `/cc:github:pr` | github | Create and manage pull requests with gh — push, PR body with summary and test plan, review handling, merge |
| `/cc:github:sync` | github | Sync the current branch with main — fetch, choose rebase or merge, resolve conflicts, re-validate |
| `/cc:github:worktree` | github | Create git worktrees for parallel branch development, each validated with the project's own toolchain |
| `/cc:github:worktree-cleanup` | github | Clean up git worktrees after a PR merges — kill ports, remove the worktree, prune refs, optionally delete branches |
| `/cc:radar:brief` | radar | Turn a trade-regulatory change into an account-facing shortlist with outreach angles. Use when the ask is "which accounts does this tariff/sanctions change matter to" or you're handed a /cc:radar:scan digest entry |
| `/cc:radar:impact` | radar | Assess whether a trade-regulatory change touches this codebase's reference data, fixtures, or rate tables, and scope the fix. Use when the ask is "does this tariff/sanctions change break anything here" or you're handed a /cc:radar:scan digest entry |
| `/cc:radar:scan` | radar | Scan the curated trade-regulatory source map for MAJOR/ROUTINE changes since the last run and produce a triaged digest. Use when the ask is "what changed in trade regs this week" or "run the regulatory radar" |
| `/cc:debug:logs` | debug | Parse and analyse structured logs — error clusters, request_id tracing, timeline, correlation with recent changes |
| `/cc:find` | entry | Find the right cc command or skill from a plain-language description of what you want to do. Use when the user asks "what should I use for…", "which command/skill does X", "how do I … with cc", "is there a tool for…", "what's the command to…", "help me find the right tool", or simply describes a goal without naming a command. Routes across dev, sales, life, and setup, and hands off to /cc:guide (sales depth) or /cc:next (dev cycle) when those fit better. |
| `/cc:guide` | entry | Interactive router — find the right skill or command for your situation, or browse the full phase map |
| `/cc:memory` | entry | One-glance status of every memory/context-persistence surface for this project — session cursor, cross-machine store, task-list, native auto-memory |
| `/cc:next` | entry | Diagnose where you are in the PIV cycle and run (or recommend) the right next step |
| `/cc:pause` | entry | Save a lightweight cursor of where you stopped — task, in-flight files, next action — so /cc:prime --resume can pick it back up next session |
| `/cc:prime` | entry | Load full project context — structure, docs, tooling, and git state — at session start |
| `/cc:setup:brand` | setup | Guided brand setup — add your logo, colors, and fonts through a conversation; no file editing required |
| `/cc:setup:ci` | setup | Generate or repair a CI pipeline (GitHub Actions or Azure DevOps) that mirrors the project's STACK.md verify gate |
| `/cc:setup:configure` | setup | Interactive first-time setup — walk through cc.config.json and apply substitutions |
| `/cc:setup:design` | setup | Guided design-system setup — apply your brand to the generic design tokens through a conversation; no file editing required |
| `/cc:setup:project` | setup | One-shot init for a NEW or EXISTING repo — git init, classify (personal/corporate/shared-oss), scaffold [WORKSPACE_DIR]/, generate STACK.md, offer CI, and (personal only, confirmed) plant per-repo plugin settings. Use when the ask is "set this repo up for cc", "init this project", or you've just cloned/created a repo and want the full one-shot setup instead of running setup:stack, setup:ci, and classification by hand. |
| `/cc:setup:stack` | setup | Detect the current project's stack and generate an editable STACK.md the dev commands read |
| `/cc:maintain:audit` | maintain | Health check for the cc plugin — placeholders, broken refs, frontmatter, inventory drift |
| `/cc:maintain:deps` | maintain | Dependency UPDATE loop — apply verify:dependencies findings in risk tiers (security, then patch/minor, majors only with --major), each tier gated by STACK.md's verify steps and rolled back independently on red |
| `/cc:maintain:issues` | maintain | Recurring GitHub issue-hygiene sweep — zombie issues shipped by merged PRs, consolidation orphans, metadata gaps, stale status labels, duplicate suspects — batched close/fold/relabel recommendations, never auto-closing |
| `/cc:maintain:lessons` | maintain | Re-harvest project LESSONS.md files into the shared lessons-learned reference — additive, generalized, dated |
| `/cc:maintain:release` | maintain | Publish the next plugin version — bump manifests, write the CHANGELOG entry, tag, and snapshot-publish the mirror, with one approval gate before anything irreversible |
| `/cc:maintain:specify` | maintain | Archive completed workspace docs — move finished plans, reports, and reviews out of the active [WORKSPACE_DIR] folders into [WORKSPACE_DIR]/completed/ when a feature ships, or run the `sweep` mode to auto-archive every Status-closed, PR-merged plan into [WORKSPACE_DIR]/archive/<year>/ |
| `/cc:life:benefits-navigator` | life | US government & admin process navigator — which agency, forms, documents, deadlines, costs, and pitfalls for a bureaucratic task (SSA / IRS / USCIS / DMV / state benefits / VA). Orientation only, confirm on the official .gov site. |
| `/cc:life:big-purchase-council` | life | A quick council for a significant purchase — total-cost-of-ownership / need-vs-want / timing-&-financing / risk-&-regret hats give a buy / wait / skip / alternative call |
| `/cc:life:council` | life | Convene a personal decision council for any dilemma — assemble the right expert hats, reason from each lens, resolve the conflicts into one prioritized recommendation |
| `/cc:life:family-council` | life | Family decision council — whole-family / communication / values / practical / conflict-repair hats weigh a family decision into a fair path forward plus how to have the conversation. Decision prep, not therapy. |
| `/cc:life:finance-council` | life | Personal finance advisory council (US) — investment / budget / holistic-planner / tax hats weigh a money decision, then resolve the conflicts into prioritized next steps. Decision prep, not financial advice. |
| `/cc:life:health-council` | life | Personal health decision council (US) — generalist / specialist / lifestyle / risk-&-benefit hats prepare you to talk to your clinician. STRICTLY decision prep, NOT medical advice or diagnosis; emergencies → call 911/988. |
| `/cc:life:home-council` | life | Housing decision council (US) — money / life-fit / property / market-&-timing hats weigh a buy-vs-rent, renovate, refinance, or relocate decision into a prioritized recommendation. Decision prep, not real-estate advice. |
| `/cc:life:insurance-review` | life | Insurance coverage review (US) — health / auto / home / life / disability / umbrella checked for gaps, over-insurance, and wrong limits, then a prioritized action plan. Decision prep, not insurance advice. |
| `/cc:life:subscriptions-audit` | life | Audit recurring costs & subscriptions (US) — find waste, duplicates, forgotten trials, and renewal traps; produce a prioritized savings + cancellation plan with a template |
<!-- END GENERATED: dev-commands -->

---

## Sales Commands

<!-- BEGIN GENERATED: sales-commands -->
| Command | Group | Description |
|---------|-------|-------------|
| `/cc:discovery:ftq` | discovery | Technical Qualify [FTQ] — 7-dimension scoring before committing SC resources |
| `/cc:discovery:golden-hours` | discovery | Post-discovery golden hours — lock in what you learned before the momentum fades |
| `/cc:discovery:prep` | discovery | Build a discovery call prep sheet — research, hypotheses, question plan |
| `/cc:discovery:qualify` | discovery | Score an opportunity on ${user_config.qualification_framework} and surface gaps + next actions |
| `/cc:discovery:questions` | discovery | Generate tailored SPIN/MEDDIC/BANT discovery questions by persona and product |
| `/cc:discovery:summary` | discovery | Structure raw call notes or transcript into a discovery output document |
| `/cc:account:brief` | account | One-page company brief for a target account — firmographics, trade footprint, signals |
| `/cc:account:champion` | account | Build a champion enablement brief — internal talking points, objection responses, and selling tools |
| `/cc:account:exposure` | account | Build the tariff/regulatory exposure brief for a target account — five-vector scoring against the exposure-analysis framework |
| `/cc:account:map` | account | Build a Mutual Action Plan (MAP) — the mandatory post-call deliverable |
| `/cc:demo:post-followup` | demo | Draft the post-demo follow-up email — recap what resonated, confirm the pains we addressed, and lock in a specific next step |
| `/cc:demo:pre-invite` | demo | Draft the pre-demo invite email with agenda, recording notice, webcam ask |
| `/cc:demo:script` | demo | Generate a full scripted demo from an existing storyboard |
| `/cc:demo:storyboard` | demo | Build a Tell-Show-Tell + PIV demo storyboard from discovery pains |
| `/cc:value:pain-to-value` | value | Map customer pains to ${user_config.company} capabilities and value outcomes — with optional root-cause clustering, a capability heat map, and ranked recommendations with buyer personas |
| `/cc:value:roi-case` | value | Build a value/ROI business case with 3+ value drivers |
| `/cc:value:wosr` | value | Deal Review [WOSR] — cross-department deal alignment agenda |
| `/cc:deal:champion-enable` | deal | Build the champion enablement kit — give your internal champion the language, business case, and talking points they need to sell to the Economic Buyer on your behalf |
| `/cc:deal:exec-summary` | deal | One-page executive summary of a deal or account for leadership |
| `/cc:deal:objection-drill` | deal | Handle any objection using tactical empathy — label, mirror, calibrated question |
| `/cc:deal:poc-plan` | deal | Draft a POC evaluation plan with use cases, success criteria, owners, and timeline |
| `/cc:deal:poc-readout` | deal | Score a completed/ending PoC against its own plan's success criteria and produce the champion-ready readout |
| `/cc:deal:proposal` | deal | Build the formal commercial proposal — cover letter, solution narrative, expected outcomes, investment, implementation approach, and a specific next step |
| `/cc:deal:strategic-think` | deal | Apply TOC + BBiT structured thinking to a complex presales problem, stuck deal, or strategic conflict |
| `/cc:rfp:analyze` | rfp | RFP/RFI Go/No-Go Analyzer — should we bid? Pulls Salesforce account history, deal health, prior RFPs, and scores the opportunity before committing SC resources |
| `/cc:rfp:present` | rfp | RFP/RFI Response Presentation — build the polished consolidated response deck to accompany or replace the written response document |
| `/cc:rfp:respond` | rfp | RFP/RFI Response Writer — map every requirement to a capability, draft compliant responses, track coverage, and produce a submission-ready document |
| `/cc:handover:doc` | handover | Build the PreSales-to-PS handover package at technical win |
| `/cc:handover:osd-draft` | handover | Solution Design [OSD] — generate an Optimal Solution Design from discovery notes and POC results |
<!-- END GENERATED: sales-commands -->

---

## Dev Skills

These are brand-neutral and need no configuration.

<!-- BEGIN GENERATED: dev-skills -->
| Skill | Description |
|-------|-------------|
| `architecture-board` | Pre-deploy architecture board — UX, AI, and systems heads review the release together and return one GO/NO-GO (decision support, not a substitute for the team's call). Use on "architecture review", "deploy board", "are we ready to ship", or from /cc:release:deploy. |
| `archon` | Run Archon CLI workflows in isolated git worktrees, or set up / configure Archon. Use on "use/run/ask archon to", "set up archon", "archon config/settings". Only for delegating to the Archon CLI, not direct Claude Code work. |
| `device-qa` | Maintain a project's Device-QA tracker — the running board of QA that automated gates (typecheck/test/lint, cloud CI) and even the e2e suite can't judge, so a human must verify it on a real build/device: audio to hear, visuals to eyeball, biometric/Face ID, store-sandbox purchases, small-screen truncation, e2e flows authored-but-not-yet-run. Two modes — recompile the whole board from open QA-labelled issues + the "NOT YET RUN ON DEVICE" notes in the repo docs, or append a single item as it's discovered — then open a docs-only PR. Project-agnostic: reads per-repo labels/paths from the tracker's own config block and the automatable-vs-on-device boundary from STACK.md. Complements /cc:verify:e2e (which RUNS the e2e suite); this TRACKS the manual on-device work that no suite covers. Use on "device qa", "update the device-qa board", "record device qa", "what needs on-device verification", or after finishing work that leaves something to verify on device. |
| `diagram` | Generate architecture, flow, and process diagrams in Excalidraw format — system architecture, data flows, sequence and state diagrams, business process maps, decision trees. Not for supply-chain maps (use `supply-chain-map`) or Theory-of-Constraints trees (use `toc-bbit-expert`). |
| `feature-interview` | Lightweight feature-planning interview producing a structured Feature Brief that /cc:plan:feature turns into a full implementation plan. Use on "I have a feature idea", "help me plan/spec a feature", or "feature brief". |
| `gdpr-check` | GDPR compliance assessment of a project or feature — officer-ready report with gap analysis and remediation backlog. Use on "GDPR check", "privacy review", "DPIA", or whether a feature processes personal data lawfully. |
| `humanize` | Strip AI tells from user-facing prose — em-dash overuse, stock AI vocabulary, rule-of-three stacking, "not just X, but Y" — with separate English and German rulebooks. Use on "humanize this", "sounds like AI", "remove em dashes", "klingt nach KI". |
| `piv-autopilot` | Input-free PIV loop — plan (or adopt a plan/issue), implement with per-task model routing, validate (unit + opt-in e2e), review and security-scan until clean, then open a PR. Commits autonomously on its own branch in a dedicated worktree; NEVER merges — the human gate is the PR review. Explicitly invoked only. Use on "run the autopilot", "take this to a PR unattended", or "implement this plan hands-off". |
| `piv-orchestrator` | Diagnoses where you are in the PIV development cycle from actual project state (git, plans, reports, reviews) and routes to — or launches — the right command, skill, or agent. Use on "what should I do next", "where was I", "I'm stuck", "PIV status", or "continue where we left off". |
| `premerge-checklist` | Pre-merge checklist for known burns a regex gate can't catch: client-side API key exposure, platform/deploy config drift, mobile (EAS) credentials, OAuth token storage, git & branch hygiene, validation honesty. Use on "pre-merge check", "known burns", "before I merge", "am I safe to merge". |
| `rulecheck` | Autonomous rule adherence checker. Scans the codebase for rule violations, fixes the highest-impact ones in an isolated worktree, runs full validation, creates a PR. Uses memory to track progress across runs. |
| `save-task-list` | Save current task list for reuse across sessions |
| `security-audit` | Full defensive security audit of a codebase or change-set with severity-rated findings. Use on "security audit", "is this secure", "check for vulnerabilities", or before a release or compliance sign-off. |
| `ship-pr` | Autonomous PR autopilot — create the PR, validate (project checks + independent review), resolve EVERY finding, re-validate until clean, then squash-and-merge. Irreversible; explicitly invoked only, never auto-run. Use on "ship this PR" or "run the ship flow". |
| `skill-creator` | Guide for creating or updating skills in this project — structure, frontmatter, triggering, and packaging. Use on "create a skill", "add a skill", "new skill for", or "improve the skill". |
| `sop-creator` | Create SOPs, runbooks, playbooks, and process documentation. Use on "write an SOP", "create a runbook", "document this process", "escalation procedure", "write a playbook", or any repeatable-procedure documentation request. |
| `triage` | Triage GitHub issues by applying type, effort, priority, and area labels. Runs in an isolated context to avoid polluting the main conversation with issue details. Delegates to a specialized triage agent with label validation hooks. |
<!-- END GENERATED: dev-skills -->

---

## Sales Skills

Skills marked **⚙** contain `[COMPANY]` / `[PRODUCT_X]` placeholders sourced from `cc.config.json`. Populate them with `/cc:setup:configure` (or `bash scripts/cc-apply.sh --apply`) before first use; unmarked skills work out of the box. See `WHAT_TO_UPDATE.md` for the full placeholder list.

<!-- BEGIN GENERATED: sales-skills -->
| Skill | Config | Description |
|-------|:------:|-------------|
| `account-intelligence` |  | Full account intelligence pipeline — supply-chain mapping plus ${user_config.company} solution-fit qualification for any named company. Use on "full account analysis for [company]", "map and qualify [company]", or "prep me for a call with [company]". |
| `business-case-stress-tester` |  | Pressure-tests a business case or ROI model before the customer's finance team does. Use on "stress-test this business case", "challenge the ROI", "CFO prep", or a pasted ROI model. |
| `champion-health` |  | Diagnoses champion strength in a live deal — separates friendly contacts from advocates actively selling for you, and flags at-risk champions. Use on "how strong is my champion", "is my champion real", or "champion health check". |
| `competitive-battlecard` |  | Rapid competitive positioning card against any named competitor — where we win, their attacks, counter-plays. Use on "battlecard", "how do we beat [competitor]", or "how do we compare to X". |
| `confidence-tagger` | ⚙ | Applies the ${user_config.company} confidence-tagging standard to team output — every claim labelled 🟢 Confirmed, 🟡 Inferred, or 🔴 Unknown. Use on "tag this", "confidence check", or "what do we actually know". |
| `critical-business-issue-finder` |  | Surfaces the Critical Business Issues hiding in a discovery summary, meeting notes, or account brief — separating CBIs from symptoms. Use on "find the CBIs", "what's the real pain here", or "what's driving this deal". |
| `demo-dryrun-coach` |  | Coaches a demo dry-run before a major session — Tell-Show-Tell compliance, pain-to-module mapping, timing, objections. Use on "dry run my demo", "practice this demo", "review my storyboard", or "feedback on my demo". |
| `demo-storyboard` |  | Builds a Tell-Show-Tell demo storyboard with Limbic Persona-Based Selling and Pain-Capability-Value logic for any ${user_config.company} GTM product. Use on "demo prep", "storyboard", "demo script", or "build a demo flow". |
| `discovery` | ⚙ | Full-lifecycle discovery for ${user_config.company} solutions — research, the FTD opening framework, and a branded pre-discovery questionnaire or post-call summary. Use on "discovery prep", "FTD", "call prep", or "discovery summary". |
| `exec-briefing-prep` |  | Preps the team for a single C-suite meeting — persona-calibrated talking points (CEO/CFO/COO/CPO). Use on "exec briefing prep" or "briefing the CFO"; for a multi-day EBC or workshop agenda use `workshop-agenda-builder`. |
| `field-comms-writer` |  | Writes standalone customer-facing emails and Slack messages — chasers, confirmations, executive outreach, follow-ups; pulls Salesforce context when connected. Use on "write a follow-up email" or "draft an email to [customer]"; to structure raw meeting notes use `meeting-notes-structurer`. |
| `grill-me` |  | Interviews the user relentlessly about a plan or design until reaching shared understanding. Use when the user wants to brainstorm, stress-test an idea, get grilled on their design, or says "grill me" or "let's discuss an idea". |
| `handoff` |  | Compact the current conversation into a handoff document for another agent to pick up. |
| `integration-complexity` |  | Assesses a prospect's integration landscape and rates the risk of connecting to ${user_config.company} — maps ERP/WMS/TMS/carrier/customs systems. Use on "assess integration complexity" or "map their integrations". |
| `linkedin-post` | ⚙ | LinkedIn content engine — ideate, posts, articles, Live scripts, podcast notes, style reviews. Use on "write a LinkedIn post/article", "turn this into a post", "draft a Live script", "topic ideas", "review this post". |
| `meeting-notes-structurer` |  | Structures raw customer-meeting notes — ${user_config.qualification_framework} updates, next steps, red flags, and a follow-up email. Use on "structure these notes", "what are the action items", or pasted call notes. |
| `negotiation-prep` |  | Builds a negotiation brief BEFORE the meeting for commercial, scope, or renewal discussions. Use on "negotiation prep", "discount request", or "getting ready to negotiate"; for live in-conversation moves use `tactical-empathy-coach`. |
| `osd-architect` |  | Generates a full Optimal Solution Design per the ${user_config.company} OSD template — every claim tagged 🟢 Confirmed / 🟡 Proposed / 🔴 Assumption. Use at technical win, for the PS handover, or on "OSD", "solution design", "technical proposal". |
| `presales-coach` |  | Situational presales coach — diagnoses the real deal constraint via ${user_config.qualification_framework} and the ${user_config.company} Playbook stages. Use on "I'm stuck on a deal", "coach me", or "prospect has gone quiet". |
| `pricing-positioning` |  | Structures how to introduce and defend pricing — value sandwich, ROI anchoring, "too expensive" pushback. Use on "pricing conversation", "how to position our price", "price objection", or "defend the price". |
| `rfx-navigator` |  | Entry-point skill for any RFX document -- RFI, RFP, RFQ, ITT, or tender -- identifies the type and does a rapid fit assessment. Use when you say "we got an RFP", "RFQ just came in", "an RFX arrived", "should we bid", or "bid or no bid". |
| `supply-chain-map` |  | Builds a visual supply chain map for any named company — manufacturing networks, distribution, logistics flows, CMO vs owned plants, freight modes, sourcing. Use on "map / diagram / analyse the supply chain of X". Not for code diagrams — use `diagram`. |
| `tactical-empathy-coach` |  | Coaches live conversational moves with tactical empathy (Voss: labels, mirrors, calibrated questions, accusation audit) and NVC. Use on "objection", "they pushed back", "how do I respond to this objection", or to rehearse a high-stakes call; to build a brief beforehand use `negotiation-prep`. |
| `toc-bbit-expert` |  | Theory of Constraints + Black Belt in Thinking coach (UDEs, CRT, Evaporation Cloud, FRT, Transition Tree), with Excalidraw diagrams. Use for stuck deals, broken processes, team conflict, or "what's the real constraint", "draw a cloud". |
| `video-demo-creator` | ⚙ | Guides the full presales demo-video lifecycle — brief, Tell-Show-Tell script, recording, editing, validation; integrates Descript, Synthesia, goConsensus. Use on "create a demo video", "video brief", or "Synthesia script". |
| `win-loss-analyzer` |  | Structured win/loss debrief on any closed deal — the real reason, what to repeat or change, competitive intel; wins, losses, no-decisions. Use on "debrief this win", "why did we lose", or "post-mortem on this deal". |
| `workshop-agenda-builder` |  | Builds a time-boxed customer workshop or multi-day EBC agenda, half-day to 3-day. Use on "build a workshop agenda", "plan an EBC" (multi-day), or "customer discovery day"; for a single exec meeting use `exec-briefing-prep`. |
| `write-a-skill` |  | Creates a new Claude skill for the Industry Solutions Skills library -- guides requirements gathering, authoring a correctly-structured SKILL.md, placing reference files, updating INVENTORY.md, and installing via `bash install.sh` from the imperium root. Use when you say "write a skill", "create a skill", "add a skill", or "how do I add a skill". |
<!-- END GENERATED: sales-skills -->

---

## Design Skills

These read brand tokens before generating any artefact. Configure your brand via `/cc:setup:configure` (writes `cc.config.json` → `skills/brand/brands/template/brand.json`); see `BRAND_SETUP.md` for logo assets and fonts. For UI/front-end work, configure the design system via `/cc:setup:design`.

<!-- BEGIN GENERATED: design-skills -->
| Skill | Config | Notes |
|-------|:------:|-------|
| `brand` |  | Shared brand registry read by output skills (pptx-generator, docx-generator) before any branded artefact — color tokens, fonts, logo paths, templates. Configure in brands/template/brand.json. |
| `design-system` |  | On-brand UI from a config-driven design system — brand tokens plus a component kit in vanilla CSS, Tailwind/DaisyUI, React, and Vue adapters. Use when building or restyling UI, prototypes, or components: "design system", "UI kit", "style this page", "theme the app", "make a button/card/modal". |
| `docx-generator` |  | Generates on-brand Word documents (.docx) — proposals, executive summaries, solution designs, handover docs, ROI cases. Use on "generate a word doc", "docx", "create a proposal document", or "branded document". |
| `pptx-generator` |  | Generates and edits presentation slides as PPTX files, compatible with PowerPoint, Google Slides, and Keynote -- including PDF carousels for LinkedIn. Use when you say "create slides", "make a deck", "generate presentation", "build a slide deck", or "create a carousel". |
<!-- END GENERATED: design-skills -->

---

## Life Skills

Personal decision-support councils and checklists (US-anchored, brand-neutral). All instantiate the shared council pattern (`references/life/council-pattern.md`); health/finance/family carry a "decision prep, not professional advice" frame.

<!-- BEGIN GENERATED: life-skills -->
| Skill | Description |
|-------|-------------|
| `benefits-navigator` | US government and admin process navigator — which agency, forms, documents, deadlines, costs, and pitfalls (SSA, IRS, USCIS, DMV, Medicaid/SNAP, ACA, VA). Orientation only, NOT legal advice — confirm on the official .gov site. Use for "how do I apply for [benefit]", "what forms do I need", "deal with the DMV/IRS". |
| `big-purchase-council` | Council for a significant purchase — four hats weigh it; a moderator calls buy / wait / skip / alternative. Use for "should I buy [X]", "is it worth it", "buy vs lease", "new vs used", "talk me out of buying". |
| `council` | Convene a personal decision council for any dilemma — assemble expert "hats", resolve the conflicts into one recommendation. Use on "help me decide", "should I…", "I'm torn between", or any genuine trade-off. Money, purchases, home, and recurring costs have dedicated councils — prefer those. |
| `family-council` | Family decision council — communication, values, practical, and conflict-repair hats weigh a family decision. Decision prep, NOT therapy or counseling. Use for "help our family decide", "we disagree about", "talk through a decision with my partner". |
| `finance-council` | Personal finance advisory council (US) — investment / budget / planner / tax hats weigh a money decision. Decision prep, NOT financial or tax advice. Use for "should I invest / pay down debt / buy vs rent", "Roth conversion", "money decision", "finance council". |
| `health-council` | Personal health decision council (US) — several lenses prepare you to talk to your clinician. STRICTLY decision prep, NOT medical advice, diagnosis, or treatment; emergencies → 911. Use for "help me think through this health decision", "what should I ask my doctor", "weigh treatment options", "second opinion". |
| `home-council` | Housing decision council (US) — money / life-fit / property / market-timing hats weigh buy-vs-rent, renovate, relocate, or refinance. Decision prep, NOT financial or real-estate advice. Use for "should I buy or rent", "renovate or move", "home council", "is this house worth it". |
| `insurance-review` | Insurance coverage review (US) — health, auto, home/renters, life, disability, umbrella — for gaps, over-insurance, wrong limits, and duplicates. Decision prep, NOT insurance advice. Use on "review my insurance", "insurance gaps", "am I over-insured". |
| `subscriptions-audit` | Audit recurring costs and subscriptions (US) for waste, duplicates, forgotten trials, and renewal traps; produce a savings and cancellation plan. Use for "audit my subscriptions", "where can I cut costs", "lower my monthly bills", "subscription creep", "free trial about to renew". |
<!-- END GENERATED: life-skills -->
