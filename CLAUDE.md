# Command Center — Claude Project Rules

## Plugin Identity
- Plugin name: cc
- Command prefix: /cc:
- All commands invoked as /cc:<group>:<name>

## Directory Structure

- `.claude-plugin/` — Plugin manifest and registration metadata
- `.claude/` — Local Claude configuration, settings, and memory for this project
- `agents/` — Autonomous agent definitions used by commands (e.g. PIV loop agents)
- `commands/` — All slash command definitions, organized by group
- `skills/` — Reusable skill modules invoked by commands
- `references/` — Static reference content (brand setup, qualification frameworks, templates; `domains/<pack>/` holds industry packs — first pack: `trade`)

## Command Groups

### Dev Commands

- **plan**: `prd`, `spec`, `feature`, `task`, `api`, `agent`, `service`, `setup`, `project` (greenfield inception interview)
- **implement**: `execute`, `migrate`, `refactor`
- **verify**: `run`, `all`, `code`, `code-review-fix`, `security`, `design` (architecture review — UX / AI / systems heads, via the `ux-reviewer`, `ai-architect`, `systems-architect` agents), `test` (author + run tests for the diff), `gdpr`, `rca`, `debug`, `pr`, `api`, `performance`, `dependencies`, `coverage`, `qa`, `codebase`, `execution-report`, `type-ignores`, `system`, `system-health` (`system-health` includes post-deployment mode — see `/cc:verify:system-health --post-deploy`)
- **release**: `validate`, `env`, `deploy`, `changelog`, `docs`, `cleanup`, `commit`, `ship`, `rollback`
- **github**: `list`, `issue`, `fix`, `pr`, `draft`, `sync`, `worktree`, `worktree-cleanup`
- **radar**: `scan`, `impact`, `brief` (regulatory-change radar — see `references/domains/trade/`)
- **debug**: `logs`
- **maintain**: `audit`, `specify`, `deps`
- **piv**: `loop` (autonomous PIV chain, ends at commit), `ship` (full chain plan→PR with dynamic model routing)
- **entry/session**: `prime` (`--resume`), `pause`, `next`, `find`, `guide`, `memory` (unified status across session cursor, memory-sync, task-list, native auto-memory)
- **setup**: `configure`, `brand`, `design`, `stack`, `ci`, `project` (one-shot init: classify + scaffold + stack + settings)

### Sales Commands

- **discovery**: `qualify`, `prep`, `questions`, `summary`, `ftq`, `golden-hours`
- **account**: `brief`, `champion`, `map`, `exposure`
- **demo**: `storyboard`, `script`, `pre-invite`, `post-followup`
- **value**: `pain-to-value`, `roi-case`, `wosr`
- **deal**: `objection-drill`, `poc-plan`, `poc-readout`, `exec-summary`, `champion-enable`, `proposal`, `strategic-think`
- **rfp**: `analyze`, `respond`, `present`
- **handover**: `osd-draft`, `doc`

### Life Commands

Personal decision-support (US-anchored, brand-neutral) — the `/cc:life:*` council & checklist pack.
All councils instantiate the shared council pattern (`references/life/council-pattern.md`).

- **life**: `council` (general decision engine), `finance-council`, `big-purchase-council`, `subscriptions-audit`, `home-council`, `insurance-review`, `health-council`, `family-council`, `benefits-navigator`

## Skills

- **Dev skills (14)**: Planning, implementation, verification (incl. post-deployment health), release, GitHub integration, PR autopilot (`ship-pr`), debugging, PIV loop, code review, security review, `architecture-board` (deliberative pre-deploy UX/AI/systems GO-NO-GO), `humanize` (strip AI tells from user-facing prose — EN + DE rulebooks), `feature-interview` (chat-portable planning interview → Feature Brief consumed by `/cc:plan:feature`)
- **Sales skills (28)**: Discovery, account intelligence, demo scripting, value framing, deal strategy, RFP response, handover documentation
- **Design skills (4)**: `brand` registry, `design-system` (neutral UI token layer + components in 4 adapters), `docx-generator`, `pptx-generator`
- **Life skills (9)**: `council` (general decision engine), `finance-council`, `big-purchase-council`, `subscriptions-audit`, `home-council`, `insurance-review`, `health-council`, `family-council`, `benefits-navigator` — all run the shared `references/life/council-pattern.md`; health/finance/family carry a "decision prep, not professional advice" frame
- **References**: Brand templates, qualification framework docs, persona guides, `life/council-pattern.md` (the council engine)

## Configuration & Maintenance

This plugin ships brand-neutral. All company- and product-specific values live as
`[PLACEHOLDER]` tokens, driven by a single source of truth: **`cc.config.json`**.

- **First-time setup**: run `/cc:setup:configure` (interactive) — it fills in
  `cc.config.json`, then applies it everywhere.
- **Apply config manually**: `bash scripts/cc-apply.sh` (dry-run) then
  `bash scripts/cc-apply.sh --apply`. Idempotent — safe to re-run any time you
  edit `cc.config.json` or add new assets containing placeholders.
- **Ongoing maintenance**: run `/cc:maintain:audit` after adding/editing any
  skill, command, or agent. It checks for unresolved placeholders, brand leakage,
  missing frontmatter, broken internal references, INVENTORY.md drift, and MCP coverage.

Placeholder → config mapping is defined in the `placeholders` block of
`cc.config.json`. To add a new substitutable token, add it there and re-run the script.

**Validating changes to this plugin.** This repo has no test/lint/build stack — so
`/cc:verify:run` is hollow here. The real validation gate for content changes is
`/cc:maintain:audit` (placeholders, brand leakage, broken refs, INVENTORY drift) **plus**
`/cc:verify:code` whenever a command/skill contains **executable bash** — a malformed
grep/regex or an unguarded path move is a real bug, not a style nit. Smoke-test non-trivial
snippets before commit.

## Brand Setup

Reference `BRAND_SETUP.md` to configure company branding before using sales commands. Fill in your company name, product names, positioning, and ICP before running any discovery or demo commands. Brand colors and sign-off also flow from `cc.config.json` into `skills/brand/brands/template/brand.json` when you run `/cc:setup:configure`.

## Dev Stack Awareness

The dev commands (`/cc:verify:*`, `/cc:implement:*`, `/cc:release:*`, `/cc:plan:*`,
`/cc:github:*`, `prime`, `debug:logs`) are **stack-agnostic**. They resolve abstract steps
(`test`, `typecheck`, `lint`, `build`, `dev`, `migrate`, `smoke`, `coverage`) from a
per-project `STACK.md` instead of hardcoding any toolchain.

- **First-time, per project**: run `/cc:setup:stack` — detects the stack (package.json
  scripts, lockfiles, pyproject.toml, manage.py, monorepo layout) and writes an editable
  `STACK.md` at the project root. Monorepos get one `component` per root (e.g. a uv
  backend + an npm frontend), each with its own `working_dir`.
- **How it resolves**: see `references/dev/stack-resolution.md` (step vocabulary, schema,
  algorithm). Seed profiles live in `references/dev/stack-profiles/`. User guide:
  `STACK_SETUP.md`.
- **Exceptions**: a few commands are intrinsically framework-specific and carry a
  `stack_scope:` frontmatter marker + a visible "Stack scope" note — `plan/agent`,
  `plan/service` (python-fastapi), `implement/migrate` (sqlalchemy-alembic). The audit
  exempts these from the hardcoded-literal check.

> Note: the **project** `STACK.md` (a project's tech stack) is unrelated to this plugin's
> own `INVENTORY.md` (the command/skill catalogue) — different file, different repo.

## Model Routing

Commands run on the cheapest model (and effort level) that does the job well, to cut
cost/tokens — enforced via `model:` and `effort:` frontmatter (model aliases
`haiku`/`sonnet`/`opus`/`fable`/`best`/`opusplan`, plus `[1m]` long-context variants; never
pinned IDs). Chain commands (`piv:ship`) additionally route per-task at runtime — see
`references/dev/dynamic-routing.md`. Mechanical commands (`github:list`,
`github:worktree(-cleanup)`, `release:changelog`) are tagged `haiku` + `effort: low`;
reasoning-heavy / high-stakes commands (`plan:*`, `implement:execute`,
`verify:code/security/rca`, `release:deploy`) are left **untagged** so they inherit the session
model and effort. A few genuinely read-only commands also carry `allowed-tools` (least
privilege, fewer permission prompts). Policy + how to extend: `references/dev/model-routing.md`.

## Qualification Framework

Default: **MEDDPICC** — can be swapped to MEDDIC, SPIN, or BANT by updating the qualification framework reference in `references/`.

## Operating Cadence

**One-time (per machine/environment):** accept the plugin install prompt when opening this
repo · `/cc:setup:configure` (identity) · per code project: `/cc:setup:stack` then
`/cc:setup:ci` · optionally `bash install.sh --with-memory-sync` (cross-machine memory).

**Recurring** (automate via `references/dev/scheduling.md` instead of remembering — Desktop
Tasks / Routines / headless recipes exist for each):

| When | Run | Why |
|---|---|---|
| Monday | `/cc:radar:scan` | Regulatory-change digest (Recipe 4) |
| Friday | `/cc:verify:dependencies` (Recipe 1) — then run `/cc:maintain:deps` manually against its findings | Unattended audit; the update loop is interactive by design |
| Monthly | `/cc:maintain:audit` | The judgment checks CI can't do (brand nuance, description quality) — CI already runs `cc-audit.sh` mechanically on every push |
| Monthly | review `[WORKSPACE_DIR]/accounts/watchlist.md` · `memory-sync.sh doctor` | Keep radar targets fresh; catch orphaned memory links |
| Before committing plugin edits | `bash scripts/cc-audit.sh` | Same gate CI runs — fail locally, not in the PR |
| Ending a work session mid-task | `/cc:pause` (→ `/cc:prime --resume` next time) | Session cursor beats re-priming from scratch |

## Getting Started

The canonical setup flow lives in `README.md` → **Quick Start** (single source of truth). In brief:

**install → `/cc:setup:configure` (identity) → `BRAND_SETUP.md` (assets) → `/cc:setup:stack` (per project) → `/cc:maintain:audit` (verify).**

Full placeholder reference: `WHAT_TO_UPDATE.md`. Deeper customization detail: `README.md` → Adapting the toolkit.
