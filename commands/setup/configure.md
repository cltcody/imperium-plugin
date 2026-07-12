---
description: Interactive first-time setup — walk through cc.config.json and apply substitutions
---

# Setup: Configure Command Center

Guide the user through filling in `cc.config.json` and applying it across all skills, commands, and agents.

> **Marketplace install? Stop here — use the built-in config instead.** If this plugin was
> installed from a marketplace (its files live under `~/.claude/plugins/cache/` and there is
> no `cc.config.local.json` you can write next to a cloned repo), the values come from the
> plugin's `userConfig`: Claude Code prompts for them when the plugin is enabled, and they can
> be changed any time via `/plugin` → cc → **Configure**. Those values are stored in your
> `~/.claude/settings.json`, survive plugin updates, and substitute automatically wherever
> skills reference `${user_config.<key>}`. The steps below apply only to a cloned-repo
> install, where `cc-apply.sh` bakes values into the published copy.

## Steps

### 1 — Read current config

**Config layering:** `cc.config.json` is the tracked, brand-neutral template; your real values
go in **`cc.config.local.json`** (gitignored — overrides the template, never committed). Read
the active config — `cc.config.local.json` if it exists, else `cc.config.json`. Display each
value that still contains a `[PLACEHOLDER]` in a clean table:

| Key | Current value | What it controls |
|-----|--------------|-----------------|
| identity.company | [YOUR COMPANY NAME] | [COMPANY] placeholder everywhere |
| ... | | |

### 2 — Collect values interactively

For each unfilled field, ask the user. Group questions by section so it feels conversational, not like a form:

**Identity**
- Company name (replaces `[COMPANY]` — appears in ~165 places across skills and commands)
- Flagship product name (replaces `[COMPANY_PRODUCT]`)

**Products** — explain these replace `[PRODUCT_A]` through `[PRODUCT_E]`. Tell the user: "These are optional — if your company doesn't have distinct product lines, you can use your company name or leave them as-is."
- Product A through E (one at a time, skip if user says "skip" or "same as company")

**Brand** (for docx/pptx/diagram skills)
- Primary color (hex) — default: #000000
- Accent color (hex) — default: #0066CC
- Standard sign-off phrase for proposals/emails

**Classification** (repo-safety — see `references/dev/repo-classification.md`)
- Personal forge username(s) — the account(s) you own outright on any forge (public or
  private). Repos under these owners classify `personal`.
- Work username(s) / org(s) — the account(s) and org(s) your employer or client controls.
  Repos under these owners classify `corporate`.
- Work-handle suffix(es) — optional. Explain to the user: some employers issue forge
  accounts as `<yourname><SUFFIX>` (e.g. a company abbreviation appended to your normal
  handle); any repo owner ending with a listed suffix classifies `corporate` too, which
  catches coworkers' suffix-matched handles without listing each one individually. Skip if
  the user's employer doesn't do this.

**Deals workspace** (for sales/deal/radar artifacts — see `references/presales/deals-workspace.md`)
- Path to the deals workspace — default: `~/code/deals-workspace`. This is the one
  cwd-independent home for every sales/deal/radar artifact; offer the default and let the
  user override for a different path (e.g. a work-side path on a corporate machine).

### 3 — Preview

Show a before/after sample using one skill file (e.g. `skills/discovery/SKILL.md`, first occurrence of `[COMPANY]`) so the user can see the effect before committing.

### 4 — Write config

Write the collected values to **`cc.config.local.json`** (your gitignored override — never the
tracked `cc.config.json` template). If `cc.config.local.json` doesn't exist yet, create it by
copying `cc.config.json` first. Preserve all existing structure and comments.

### 5 — Apply

Run: `bash scripts/cc-apply.sh --apply --force-in-place`

The `--force-in-place` flag is **required** here: `cc-apply.sh` refuses a bare `--apply`
because baking config into the source and leaving it there de-templatizes the plugin (this
happened to the canonical repo on 2026-07-09). `--force-in-place` is the explicit
"permanently bake **this** clone" acknowledgment — correct for a user configuring their own
copy. **Never run this in the canonical/upstream plugin source** — to publish from there, use
`bash scripts/cc-publish.sh` (it bakes, publishes, then restores the source).

Capture stdout and report:
- How many files were updated
- Any skipped placeholders (values still unfilled)

### 6 — Update brand.json

Write the brand values (primary_color, accent_color, sign_off, company name) into `skills/brand/brands/template/brand.json` as well.

### 7 — Summary and next step

Report what was done. Then offer the natural next step conversationally — **don't** hand the
user a list of files to edit:

> "Identity's set. Want to add your **logo** and confirm colors/fonts? I can walk you through
> it — just run `/cc:setup:brand` and I'll place everything for you."

Only mention `WHAT_TO_UPDATE.md` / `BRAND_SETUP.md` if the user explicitly wants the manual
reference. The guided path is `/cc:setup:brand` (visual assets) and `/cc:setup:stack` (per
project). To change identity later, the user just re-runs this command.
