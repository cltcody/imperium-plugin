# Command Center (cc)

A unified personal Claude Code plugin combining developer workflow tools, sales methodology, and personal life-decision councils — stripped of company branding and ready for you to customize with your own identity, products, and process. **Only want the personal decision-support side (`/cc:life:*`)?** It needs none of that setup — see [Just want the Life councils?](#just-want-the-life-councils) below.

**New here?** Just describe what you want to do and run **`/cc:find`** — it routes you to the right command or skill. Prefer to browse? [`CHEATSHEET.md`](CHEATSHEET.md) maps "I'm trying to do X" → the right tool, and [`INVENTORY.md`](INVENTORY.md) is the full catalogue.

## Daily driver (once installed and configured)

| Moment | Command |
|---|---|
| Start a session | `/cc:prime` — or `/cc:prime --resume` to pick up where `/cc:pause` left off |
| Plan the work | `/cc:plan:feature` (small change: `/cc:plan:task`) |
| Build it | `/cc:implement:execute` |
| Gate it | `/cc:verify:all` — one scorecard, GO / FIX FIRST (fast inner loop: `/cc:verify:run`) |
| Ship it | `/cc:release:ship` → the `ship-pr` skill for the PR/merge tail |
| Stopping mid-task | `/cc:pause` — writes a session cursor for next time |
| Everything else | `/cc:find` routes by description · [`CHEATSHEET.md`](CHEATSHEET.md) maps situations · `/cc:next` reads project state |

## Quick Start

The canonical setup flow — each step links to its detail below:

1. **Install it** — make `/cc:*` available everywhere (see [Install Command Center globally](#install-command-center-globally)), or drop `.claude/` into a single project.
2. **Set your identity** — run `/cc:setup:configure` to fill `cc.config.json` (company, products, brand colors) and apply it across every asset.
3. **Add brand assets** — run `/cc:setup:brand`; it walks you through adding your logo and confirming colors/fonts and does the file work for you (only needed for the document/slide generators).
4. **Teach each project its stack** — run `/cc:setup:stack` in every code project so the dev commands use that project's real test/lint/build commands.
5. **Verify** — run `/cc:maintain:audit` to catch unresolved placeholders, broken references, or drift.

Steps 2–4 are explained in depth under [Adapting the toolkit](#adapting-the-toolkit). New to the commands themselves? [`CHEATSHEET.md`](CHEATSHEET.md) maps situations to the right tool; `/cc:guide` routes interactively.

### Just want the Life councils?

The `/cc:life:*` pack (`council`, `finance-council`, `big-purchase-council`, `home-council`,
`health-council`, `family-council`, `insurance-review`, `subscriptions-audit`,
`benefits-navigator`) is fully self-contained — no company identity, brand, or per-project
stack config required. Skip straight to step 1 (install), then just describe your decision
or run `/cc:life:council` directly. Steps 2–4 above are only for the dev/sales sides of the
toolkit. See the **Life — personal decisions** section of [`CHEATSHEET.md`](CHEATSHEET.md).

## Set up on a new machine

**Setting up a teammate instead of a machine?** The plugin is built to be shared — it ships
brand-neutral, and the repo-root [`README.md`](../README.md) → **Sharing with your team**
covers what's shareable vs private, the clean-room guarantee, and the three install paths.
The steps below apply to a teammate's machine unchanged.

Cloning fresh (e.g. a work computer):

1. **Prereqs** — Claude Code installed (the plugin runs inside it), the `claude` CLI on your PATH, and git.
2. **Clone + install** — from the repo root:
   ```bash
   git clone https://github.com/cltcody/imperium.git ~/code/imperium
   cd ~/code/imperium
   bash global/scripts/cc-publish.sh     # registers the marketplace (path-relative) + installs cc@imperium at user scope
   ```
   Then **restart Claude Code or `/reload-plugins`**. The dev commands (`plan`/`implement`/`verify`/`release`/`github`) are brand-neutral and work immediately, and the `/cc:life:*` councils need zero configuration at all — if you only want either of those you can stop here.
3. **Make it yours (once)** — `/cc:setup:configure` (identity), then optionally `/cc:setup:brand` (logo) and `/cc:setup:design` (UI). Re-run `bash global/scripts/cc-publish.sh` to bake those into the live install.
4. **Per project (once each)** — `cd <your-project> && /cc:setup:stack` writes a `STACK.md` so dev commands use that project's real toolchain.
5. **Verify** — `/cc:maintain:audit`.

**Your values stay local.** `cc.config.json` is the tracked, brand-neutral template; your real
company/product/brand values are written to **`cc.config.local.json`** (gitignored — never
committed), which overrides the template. The setup commands write there for you, and
`cc-publish` restores the source after baking, so the repo stays token-pristine — you can
`git pull` updates without clobbering your config.

## Install Command Center globally

### From a marketplace (no clone needed)

If you received this plugin via a marketplace link, you don't need the source repo:

```
/plugin marketplace add <owner>/<mirror-repo>
/plugin install cc@imperium
```

When you enable the plugin, Claude Code prompts for your company, products, brand colors,
and workspace directory (all optional — sensible defaults apply). Change them any time via
`/plugin` → cc → **Configure**. Values live in your own `~/.claude/settings.json`, survive
plugin updates, and substitute automatically wherever skills reference
`${user_config.<key>}` — no file editing, no re-baking. Updates arrive when the maintainer
bumps the plugin version. (Maintainers: publish the mirror with
`bash global/scripts/cc-mirror.sh` — see `docs/marketplace-release-runbook.md` in the
source repo.)

### From a clone (this repo)

Make `/cc:*` available in **every** project on your machine (user scope):

```bash
# from the repo root — in a Claude Code session or via the CLI:
/plugin marketplace add ./global          # or an absolute path, for stability
/plugin install cc@imperium          # installs at user scope by default
```

Or one-shot with the bundled script (validates manifests, applies `cc.config.json`, then
(re)installs at user scope):

```bash
bash scripts/cc-publish.sh
```

**Updating after you edit the plugin:** Claude Code copies the plugin into a cache on
install, so edits aren't picked up until you re-publish. Re-run `bash scripts/cc-publish.sh`,
then `/reload-plugins` (or restart). For quick local iteration without installing:
`claude --plugin-dir ./global` and `/reload-plugins` after edits. (Interactive sessions
opened on the imperium repo itself get a one-time install prompt via the repo's
`.claude/settings.json` — accept once per environment and `/cc:*` is live; fully headless
fresh environments still need `--plugin-dir`. See the repo-root README → Sharing with your
team.)

Check what's installed with `claude plugin list`; compare against your existing global
commands/skills with `bash scripts/cc-compare.sh`.

### Developing the plugin

Day-to-day edits to `global/` don't need a reinstall at all. Run Claude Code straight
against the working tree:

```bash
claude --plugin-dir ~/code/imperium/global
```

Then `/reload-plugins` after each edit to pick up the change. This is the whole
iteration loop — `install.sh` and `bash scripts/cc-publish.sh` are for cutting a release
into the real plugin cache and for pulling updates onto other machines, not for
every-edit iteration.

Before committing, run the repo's own CI gate locally — it's the same check that runs
in CI on every PR:

```bash
bash scripts/cc-audit.sh
```

It catches broken references, unresolved placeholders, frontmatter issues, CRLF
contamination, INVENTORY drift, and stale-path regressions — the mechanical checks
`/cc:maintain:audit` also runs, but scriptable and fast enough to run on every change.
The full quality stack is described in [How quality is enforced](#how-quality-is-enforced).

## How quality is enforced

Five layers keep the plugin honest. Know these before your first edit — especially the
INVENTORY one.

**`cc-audit.sh` + CI.** [`scripts/cc-audit.sh`](scripts/cc-audit.sh) is the deterministic
gate: reference existence (`${CLAUDE_PLUGIN_ROOT}` paths), stale-pattern denylist,
frontmatter validation, placeholder sync against `cc.config.json`, JSON validity,
fenced-bash lint, INVENTORY drift, model-routing tier coverage (mechanical commands
missing `model:`/`effort:`), and the `CLAUDE.md` line budget (≤500 lines, per
`references/dev/context-engineering.md`). CI ([`.github/workflows/audit.yml`](../.github/workflows/audit.yml))
runs it on every push and PR, plus shellcheck over all scripts and a `cc-apply.sh` dry-run.
Run it locally before committing; `/cc:maintain:audit` adds the judgment-only checks
(brand-leakage nuance, description quality) on top. To run the gate on a schedule instead
of remembering it, see [`references/dev/scheduling.md`](references/dev/scheduling.md).

**INVENTORY.md is GENERATED — edit frontmatter, not tables.** The tables in
[`INVENTORY.md`](INVENTORY.md) between `<!-- BEGIN/END GENERATED -->` markers are written by
[`scripts/cc-inventory.sh`](scripts/cc-inventory.sh) from each command/skill file's
frontmatter `description:`. Editing a table row by hand is futile: the next regeneration
overwrites it, and `cc-inventory.sh --check` flags the drift in CI meanwhile. To change a
catalogue entry, edit the source file's `description:` and run
`bash scripts/cc-inventory.sh`. Prose outside the markers is yours to edit normally.

**cc-eval golden tasks.** [`../evals/`](../evals/README.md) (repo root — deliberately not
shipped in the plugin payload) holds regression tests for command *prompts*: each case runs
a command against a tiny synthetic fixture and asserts the output's shape (plan file lands
in the right place, required sections present, no leftover placeholders); quality-critical
artifacts add an LLM judge with a stingy rubric. `bash scripts/cc-eval.sh --dry-run`
validates cases without needing the `claude` binary. Touch a command's prompt → run its case.

**The severity ladder is the review standard.**
[`references/dev/severity-and-rubrics.md`](references/dev/severity-and-rubrics.md) is the
single canonical severity ladder (CRITICAL→INFO), finding anatomy, and verdict tiers for
every reviewing command and agent — `verify:code/pr/security/codebase`, `code-reviewer`,
`security-auditor`, `gdpr-auditor`. Individual files declare only their deltas; if a local
text contradicts the reference, the reference wins.

**Exemplars are the output bar.** [`references/dev/exemplars/`](references/dev/exemplars/)
holds one gold-standard artifact each for a code review, a feature plan, and an RCA. When
judging whether a command's output is good enough — or writing an eval rubric — compare
against these, not vibes.

## What's Included

Full catalogue: [`INVENTORY.md`](INVENTORY.md). When-to-use map: [`CHEATSHEET.md`](CHEATSHEET.md).

**Dev workflow commands** — **stack-aware** (resolve test/lint/typecheck/build/migrate from each project's `STACK.md`; work across Next.js, Django, FastAPI, Expo, and monorepos — see `STACK_SETUP.md`):
- `plan/`, `implement/`, `verify/` — the PIV loop: plan → build → validate (`verify/system-health`
  includes a post-deployment mode — no separate monitoring group)
- `release/`, `github/`, `debug/` — shipping, PRs, deploys, diagnostics
- `prime`, `next`, `guide`, `memory`, `piv/` — onboarding, routing, memory status, and the hands-off PIV chain

**Sales methodology commands**:
- `discovery/`, `account/`, `demo/` — qualification, account intelligence, demos
- `value/`, `deal/`, `rfp/`, `handover/` — value framing, deal strategy, RFP response, handover

**Skills (43: 11 dev · 28 sales · 4 design)** — invoked by description:
- Dev: `piv-orchestrator`, `security-audit`, `gdpr-check`, `skill-creator`, `diagram`, and more
- Sales: discovery, competitive battlecards, exec prep, demo coaching, negotiation, and more
- Design: `brand`, `docx-generator`, `pptx-generator`

**Agents** (plugin `agents/`): `code-reviewer`, `security-auditor`, `gdpr-auditor`, `validator`, `validation-runner`, `codebase-analyst`, `rulecheck-agent`, `triage-agent`.

**References**: `dev/` (stack resolution + profiles; model routing; [scheduling](references/dev/scheduling.md) — how to run a cc command recurringly; the [severity ladder](references/dev/severity-and-rubrics.md) every review runs on; [exemplars](references/dev/exemplars/) — gold-standard outputs; plus distilled pattern references: PIV methodology, context engineering, agent design, AI project setup, RAG/knowledge patterns), `piv/` (PIV loop cheatsheet + numbered project convention files), `presales/` (sales methodology).

**Hooks** (plugin `hooks/hooks.json`): a `PreToolUse` guardrail (`block-secrets.py`) that
pattern-matches Read/Bash/Grep/Edit/Write/Glob calls to catch common *accidental* exposure of
`.env` files, credentials, SSH keys, and similar secrets. It ships with the plugin, so it's active
in every session once installed. **This is a guardrail against accidental secret exposure, not a
security boundary** — it's regex over tool-call text, not a sandbox, and a determined bypass is
possible. Use real secret management (vaults, env injection at deploy time, `.gitignore`) as your
actual control. A `PreCompact` hook (`pre-compact-snapshot.py`) writes a coarse, disk-derived
session cursor before `/compact` runs (manual or automatic), in the same `session.md` format
`/cc:pause` uses, so a compaction event never silently loses the "where am I" cursor — it never
overwrites a real `/cc:pause` file, writing to `session.auto.md` instead when one already exists.
See `references/dev/context-engineering.md` → "Native memory & caching" and `/cc:memory` (below)
for the full picture of where project memory lives.

## Plugin Prefix

All commands use the `/cc:` prefix with colon-separated groups (e.g. `/cc:implement:execute`, `/cc:account:brief`).

## Customization

- **`BRAND_SETUP.md`** — configure your company name, product names, tone, and visual identity
- **`STACK_SETUP.md`** — how the dev commands learn each project's stack; run `/cc:setup:stack` to generate a project's `STACK.md`
- **`WHAT_TO_UPDATE.md`** — a checklist of every placeholder across commands, skills, and references that needs your specific content
- **`INVENTORY.md`** — the full catalogue of every command and skill in this plugin (its tables are generated — see [How quality is enforced](#how-quality-is-enforced) before editing)

## Adapting the toolkit

Three layers of customization, in order:

1. **Identity** — run `/cc:setup:configure` to set company, products, and brand colors. Your values are written to `cc.config.local.json` (gitignored — overrides the tracked `cc.config.json` template) and applied across every asset. Manual path: copy `cc.config.json` → `cc.config.local.json`, edit it, then `bash scripts/cc-apply.sh --apply`. Full placeholder list in `WHAT_TO_UPDATE.md`.
2. **Brand** — run `/cc:setup:brand` for a guided walkthrough that places your logo and sets colors/fonts (no file editing required). `BRAND_SETUP.md` is the manual reference if you prefer.
3. **Per-project stack** — run `/cc:setup:stack` in each code project; it writes that project's `STACK.md` so the dev commands use that project's real test/lint/build/migrate commands (works across Next.js, Django, FastAPI, Expo, monorepos). Details in `STACK_SETUP.md`.

Then run `/cc:maintain:audit` any time to catch drift — unresolved placeholders, brand leakage, broken references, inventory drift, or a hardcoded-stack regression.

## Using across multiple projects

Command Center is installed **once, globally** and shared by every project — it is not copied
into each repo. That keeps it safe to use across many projects at once:

- **Each session is scoped to its own project.** Commands act on the current project's
  directory and write outputs there (`.specify/…`, `STACK.md`), so projects never bleed into
  each other — even with several sessions open.
- **Per-project behavior comes from `STACK.md`.** Run `/cc:setup:stack` once per code project;
  the shared dev commands then resolve the right test/lint/build commands for *that* project
  (Django, Next.js, Expo, monorepo, etc.).
- **Identity is global.** `/cc:setup:configure` brands the shared plugin to your one company —
  it's a one-time setup, not per-project. (If you produce output documents for *different*
  clients, use the `brand` skill's `brands/<name>/` registry to pick a brand per document.)
- **One thing to avoid:** don't *also* drop a copy of `.claude/` into individual projects
  while the global plugin is installed — you'd get duplicate commands. Pick one method
  (the global install is recommended).

## Directory Structure

```
global/
├── .claude/
│   ├── agents/         # Specialized sub-agents (dev-project template copies)
│   └── settings.json   # Local/dev-project settings template (no hooks — see hooks/ below)
├── hooks/
│   ├── hooks.json           # Plugin hook registration (SessionStart/PreCompact/PreToolUse, auto-discovered)
│   ├── block-secrets.py     # Accidental-secret-exposure guardrail (not a security boundary)
│   ├── pre-compact-snapshot.py  # PreCompact safety-net session cursor (never clobbers /cc:pause)
│   └── test-block-secrets.sh
├── commands/
│   ├── account/        # Account intelligence commands
│   ├── deal/           # Deal management
│   ├── debug/          # Debugging utilities
│   ├── demo/           # Demo preparation
│   ├── discovery/      # Discovery workflows
│   ├── github/         # GitHub integration
│   ├── handover/       # Handover docs
│   ├── implement/      # Implementation commands
│   ├── piv/            # Plan-implement-verify
│   ├── plan/           # Planning
│   ├── release/        # Release management
│   ├── rfp/            # RFP response
│   ├── value/          # Value articulation
│   ├── verify/         # Verification
│   ├── setup/          # configure, brand, design, stack, ci
│   ├── maintain/       # audit, specify, deps
│   ├── guide.md        # Onboarding guide
│   ├── next.md         # Next-step planner
│   ├── prime.md        # Codebase primer (--resume picks up a /cc:pause cursor)
│   ├── pause.md        # Session cursor writer
│   ├── memory.md       # Unified memory status (session cursor, memory-sync, task-list, auto-memory)
│   └── find.md         # Cross-toolkit router
├── references/
│   ├── dev/            # stack-resolution.md + stack-profiles/ · model-routing · scheduling
│   │                   #   · severity-and-rubrics · exemplars/ · distilled pattern refs
│   ├── piv/            # Dev methodology references
│   └── presales/       # Sales methodology references
├── skills/             # Dev + sales + design skills
├── scripts/            # cc-apply · cc-audit · cc-compare · cc-eval · cc-inventory
│                       #   · cc-publish · memory-sync · repo-autoupdate
├── cc.config.json      # Company/product identity (drives substitutions)
├── CLAUDE.md           # Project rules
├── INVENTORY.md        # Command & skill catalogue (GENERATED tables — see "How quality is enforced")
├── CHEATSHEET.md       # When to use which command / skill
├── STACK_SETUP.md      # Per-project stack-manifest guide
├── BRAND_SETUP.md
├── MCP_SETUP.md        # Which skills use which MCP servers (all optional)
├── WHAT_TO_UPDATE.md
└── README.md
```
