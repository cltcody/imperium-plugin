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
| `/cc:verify:all` | verify | One-shot "run everything" verification orchestrator — sequences the verify:* gate and reviews, then reports a single scorecard with a GO / FIX FIRST verdict |
| `/cc:verify:api` | verify | Review the API design for consistency, correctness, and developer experience |
| `/cc:verify:code` | verify | Technical code review of uncommitted or branch changes, with severity-rated findings saved to ${user_config.workspace_dir}/code-reviews/ |
| `/cc:verify:code-review-fix` | verify | Auto-fix CRITICAL/HIGH and obvious MEDIUM findings from the latest code review, then re-validate |
| `/cc:verify:codebase` | verify | Full codebase scan — static analysis, AI-smell detection, and security spot-check across all source files. Use periodically, before a major release, or when onboarding to a codebase. |
| `/cc:verify:coverage` | verify | Analyse test coverage, find gaps, and generate targeted suggestions for missing tests |
| `/cc:verify:debug` | verify | Systematically diagnose a failing test or error — reproduce, classify, hypothesize, fix the root cause with a regression test |
| `/cc:verify:dependencies` | verify | Audit dependencies and supply chain — known CVEs, version hygiene, lockfile drift, CI action pinning, install-script risk |
| `/cc:verify:design` | verify | Architecture review of the change — UX, AI design, and cross-system seams — via relevance-gated parallel heads, findings saved by severity |
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
| `/cc:find` | entry | Find the right cc command or skill from a plain-language description of what you want to do. |
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
| `/cc:maintain:specify` | maintain | Archive completed workspace docs — move finished plans, reports, and reviews out of the active [WORKSPACE_DIR] folders into [WORKSPACE_DIR]/completed/ when a feature ships |
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

## Dev Skills (11)

These are brand-neutral and need no configuration.

<!-- BEGIN GENERATED: dev-skills -->
| Skill | Description |
|-------|-------------|
| `architecture-board` | Pre-deploy architecture board — UX, AI, and systems heads review the release together, resolve |
| `archon` | Run Archon CLI workflows in isolated git worktrees, or set up / configure Archon. Use on "use/run/ask archon to", "set up archon", "archon config/settings". Only for delegating to the Archon CLI, not direct Claude Code work. |
| `benefits-navigator` | US government and admin process navigator — which agency, forms, documents, deadlines, costs, and pitfalls (SSA, IRS, USCIS, DMV, Medicaid/SNAP, ACA, VA). Orientation only, NOT legal advice — confirm on the official .gov site. Use for "how do I apply for [benefit]", "what forms do I need", "deal with the DMV/IRS". |
| `big-purchase-council` | Council for a significant purchase — four hats (total cost of ownership, need-vs-want, timing & |
| `council` | Convene a personal decision council for any dilemma — assemble expert "hats", reason from each lens, resolve the conflicts into one prioritized recommendation. Use on "help me decide", "should I…", "I'm torn between", or any genuine trade-off. Money, purchases, home, and recurring costs have dedicated councils — prefer those. |
| `diagram` | Generate software architecture and flow diagrams in Excalidraw format. For a company's supply-chain / logistics map use the `supply-chain-map` skill instead; for Theory-of-Constraints thinking-process trees and clouds use `toc-bbit-expert`. |
| `family-council` | Family decision council — communication, values, practical, and conflict-repair hats weigh a family decision, then resolve the tensions into a fair path forward. Decision preparation, NOT therapy or counseling. Use for "help our family decide", "we disagree about", "talk through a decision with my partner". |
| `feature-interview` | Lightweight feature-planning interview — one question at a time, no repo access needed — |
| `finance-council` | Personal finance advisory council (US) — investment / budget / planner / tax hats weigh a money decision, then resolve the conflicts into prioritized next steps. Decision preparation, NOT financial or tax advice. Use for "should I invest / pay down debt / buy vs rent", "Roth conversion", "money decision", "finance council". |
| `gdpr-check` | GDPR compliance assessment of a project or feature — officer-ready report with status dashboard, |
| `health-council` | Personal health decision council (US) — several lenses prepare you to talk to your clinician. STRICTLY decision preparation, NOT medical advice, diagnosis, or treatment; emergencies → 911. Use for "help me think through this health decision", "what should I ask my doctor", "weigh treatment options", "second opinion". |
| `home-council` | Housing decision council (US) — money / life-fit / property / market-timing hats weigh buy-vs-rent, renovate, relocate, or refinance, resolved into one prioritized recommendation. Decision preparation, NOT financial or real-estate advice. Use for "should I buy or rent", "renovate or move", "home council", "is this house worth it". |
| `humanize` | Strip AI tells from user-facing prose — em-dash overuse, stock AI vocabulary, rule-of-three |
| `insurance-review` | Insurance coverage review (US) — health, auto, home/renters, life, disability, umbrella — for |
| `piv-orchestrator` | Diagnoses where you are in the PIV development cycle from actual project state (git, plans, |
| `rulecheck` | Autonomous rule adherence checker. Scans the codebase for rule violations, |
| `save-task-list` | Save current task list for reuse across sessions |
| `security-audit` | Full defensive security audit of a codebase or change-set — officer-ready clearance report with |
| `ship-pr` | Autonomous PR autopilot — create the PR, validate (project checks + independent review), resolve |
| `skill-creator` | Guide for creating or updating skills in this project — structure, frontmatter, triggering, and |
| `sop-creator` | Create runbooks, playbooks, and technical documentation for engineering teams. Use on "create a |
| `subscriptions-audit` | Audit recurring costs and subscriptions (US) for waste, duplicates, forgotten trials, and renewal traps; produce a prioritized savings and cancellation plan with a template. Use for "audit my subscriptions", "where can I cut costs", "lower my monthly bills", "subscription creep", "free trial about to renew". |
| `triage` | Triage GitHub issues by applying type, effort, priority, and area labels. |
<!-- END GENERATED: dev-skills -->

---

## Sales Skills (28)

Skills marked **⚙** contain `[COMPANY]` / `[PRODUCT_X]` placeholders sourced from `cc.config.json`. Populate them with `/cc:setup:configure` (or `bash scripts/cc-apply.sh --apply`) before first use; unmarked skills work out of the box. See `WHAT_TO_UPDATE.md` for the full placeholder list.

<!-- BEGIN GENERATED: sales-skills -->
| Skill | Config | Description |
|-------|:------:|-------------|
| `account-intelligence` |  | Full account intelligence pipeline — runs supply-chain mapping and ${user_config.company} |
| `business-case-stress-tester` |  | Pressure-tests a business case or ROI model before the customer's finance team does — challenges |
| `champion-health` |  | Diagnoses champion strength in a live deal — separates friendly contacts from advocates actively |
| `competitive-battlecard` |  | Rapid competitive positioning card against any named competitor in trade compliance, supply |
| `confidence-tagger` | ⚙ | Applies the ${user_config.company} confidence-tagging standard to presales output — every claim |
| `critical-business-issue-finder` |  | Surfaces the Critical Business Issues hiding in a discovery summary, meeting notes, or account |
| `demo-dryrun-coach` |  | Coaches a demo dry-run before a major session — checks Tell-Show-Tell compliance, pain-to-module |
| `demo-storyboard` |  | Builds a Tell-Show-Tell demo storyboard with Limbic Persona-Based Selling and Pain-Capability- |
| `discovery` | ⚙ | Full-lifecycle discovery for ${user_config.company} solutions — researches (Salesforce + |
| `exec-briefing-prep` |  | Preps the SC and AE for a C-suite meeting — tight agenda, persona-calibrated talking points |
| `field-comms-writer` |  | Writes customer-facing follow-up emails, recaps, and Slack messages after calls, demos, or key |
| `grill-me` |  | Interviews the user relentlessly about a plan or design until reaching shared |
| `handoff` |  | Compact the current conversation into a handoff document for another agent to pick up. |
| `integration-complexity` |  | Assesses a prospect's integration landscape and rates the complexity and risk of connecting to |
| `linkedin-post` | ⚙ | LinkedIn content engine — ideate, posts, articles, Live scripts, podcast notes, and style reviews, with config-driven voice profiles (personal or company). Use on "write a LinkedIn post/article", "turn this into a post", "draft a Live script", "topic ideas", "review this post". |
| `meeting-notes-structurer` |  | Structures raw customer-meeting notes into an action-oriented summary — |
| `negotiation-prep` |  | Builds a negotiation brief before any commercial discussion — walk-away point, trade levers, |
| `osd-architect` |  | Generates a full Optimal Solution Design from discovery notes and POC results per the |
| `presales-coach` |  | Situational presales coach — diagnoses the real deal constraint via |
| `pricing-positioning` |  | Structures how to introduce and defend pricing — value sandwich, ROI anchoring, "too expensive" |
| `rfx-navigator` |  | Entry-point skill for any RFX document -- RFI, RFP, RFQ, ITT, or tender -- identifies the |
| `supply-chain-map` |  | Builds a structured visual supply chain map for any named company from public research — |
| `tactical-empathy-coach` |  | Coaches objection handling with tactical empathy (Voss: labels, mirrors, calibrated questions, |
| `toc-bbit-expert` |  | Theory of Constraints + Black Belt in Thinking coach — full BBiT process (UDEs, CRT, Evaporation |
| `video-demo-creator` | ⚙ | Guides the full presales demo-video lifecycle — brief, Tell-Show-Tell script, recording |
| `win-loss-analyzer` |  | Structured win/loss debrief on any closed deal — the real reason for the decision, what to |
| `workshop-agenda-builder` |  | Builds a time-boxed customer workshop or EBC agenda from a modular section library, plus |
| `write-a-skill` |  | Creates a new Claude skill for the Industry Solutions Skills library -- guides |
<!-- END GENERATED: sales-skills -->

---

## Design Skills (4)

These read brand tokens before generating any artefact. Configure your brand via `/cc:setup:configure` (writes `cc.config.json` → `skills/brand/brands/template/brand.json`); see `BRAND_SETUP.md` for logo assets and fonts. For UI/front-end work, configure the design system via `/cc:setup:design`.

<!-- BEGIN GENERATED: design-skills -->
| Skill | Config | Notes |
|-------|:------:|-------|
| `brand` |  | Shared brand registry read by output skills (pptx-generator, docx-generator) before any branded |
| `design-system` |  | Generate on-brand UI from a neutral, config-driven design system — brand tokens plus a component kit in vanilla CSS, Tailwind/DaisyUI, React, and Vue adapters. Use when building or restyling UI, prototypes, or components: "design system", "UI kit", "style this page", "theme the app", "make a button/card/modal". |
| `docx-generator` |  | Generates on-brand Word documents (.docx) — proposals, executive summaries, solution designs, |
| `pptx-generator` |  | Generates and edits professional presentation slides as PPTX files, compatible with |
<!-- END GENERATED: design-skills -->
