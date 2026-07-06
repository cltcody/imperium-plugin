# What To Update

This plugin ships **brand-neutral**. Every company- and product-specific value is a
`[PLACEHOLDER]` token wired to `cc.config.json` and filled automatically — you rarely edit a
file by hand. This page is the reference for **what the tokens are** and **how they get
filled**. Run the grep at the bottom to verify a configured install.

> The fastest path is the guided setup — you never touch JSON:
> `/cc:setup:configure` (identity, products, framework, colors) → `/cc:setup:brand` (logo) →
> `/cc:setup:design` (design system) → `/cc:setup:stack` (per project).

---

## How filling works

1. Set values once in `cc.config.json` (or via `/cc:setup:configure`).
2. `scripts/cc-apply.sh --apply` substitutes every token across `skills/`, `commands/`,
   `agents/`, `.claude/`, `references/` (`.md`, `.json`, `.py`, `.css`, `.html`, `.js`,
   `.jsx`, `.vue`). Idempotent — safe to re-run any time you change config or add assets.
3. `/cc:maintain:audit` flags anything still unresolved or any brand that leaked in
   un-tokenized.

The token → config mapping lives in the `placeholders` block of `cc.config.json`.

---

## Token reference

### Identity & products (set in `cc.config.json`)
| Token | Config field | Meaning |
|-------|--------------|---------|
| `[COMPANY]` | `identity.company` | Your company name (the vendor) — pervasive |
| `[COMPANY_PRODUCT]` | `identity.company_product` | Flagship product / platform name |
| `[PRODUCT_A]` | `products.product_a` | Product line A (e.g. AI-assisted classification) |
| `[PRODUCT_B]` | `products.product_b` | Product line B (e.g. AI document capture) |
| `[PRODUCT_C]` | `products.product_c` | Product line C (e.g. partner / restricted-party screening) |
| `[PRODUCT_D]` | `products.product_d` | Product line D (e.g. trade-agreement / rules-of-origin) |
| `[PRODUCT_E]` | `products.product_e` | Product line E (e.g. supply-chain planning) |
| `[SOLUTION_SUITE_1]` | `solutions.suite_1` | Primary solution suite name |
| `[SOLUTION_SUITE_2]` | `solutions.suite_2` | Secondary suite (optional) |

### Sales & brand (set in `cc.config.json`)
| Token | Config field | Default |
|-------|--------------|---------|
| `[QUALIFICATION_FRAMEWORK]` | `sales.qualification_framework` | `MEDDPICC` |
| `[PRIMARY_COLOR_HEX]` | `brand.primary_color` | `#000000` |
| `[ACCENT_COLOR_HEX]` | `brand.accent_color` | `#0066CC` |
| `[BACKGROUND_COLOR_HEX]` | `brand.background_color` | `#FFFFFF` |
| `[BRAND_FONT]` | `brand.font_family` | `Inter` |

> **Qualification-framework caveat:** the `[QUALIFICATION_FRAMEWORK]` token swaps the
> framework **name** everywhere, but the bundled discovery/qualification *methodology* is
> written for MEDDPICC's eight dimensions. Switching to MEDDIC/SPIN/BANT updates the name —
> review the dimension-level content by hand, as the frameworks differ.

---

## Runtime-read config (NOT placeholder tokens)

Two blocks in `cc.config.json` are read live, at command runtime, by their own resolution
logic — they are **not** wired into the `placeholders` map and `cc-apply.sh` never
text-substitutes them. Don't add them there; the placeholder-sync check in
`scripts/cc-audit.sh` would then flag them as unused-but-defined.

| Field | Read by | Real values live in | Reference |
|-------|---------|----------------------|-----------|
| `classification.personal_owners` / `.work_owners` / `.work_owner_suffixes` | Repo-class detection in `/cc:setup:project` / `/cc:setup:stack` (owner-forge-identity match against `git remote get-url origin`) | `cc.config.local.json` (ships as empty template arrays in `cc.config.json`) | `references/dev/repo-classification.md` §Detection rules |
| `paths.deals_workspace` | Every sales/deal/radar/rfp command, at output-path resolution time (first-hit precedence: `paths.deals_workspace` → `CC_DEALS_WORKSPACE` env var → `~/code/deals-workspace` default) | `cc.config.local.json` (or leave the `cc.config.json` default) | `references/presales/deals-workspace.md` §Resolving the workspace path |

Both are set the same way as everything else — `/cc:setup:configure` asks for them under a
**Classification** / **Deals workspace** section and writes the answers to
`cc.config.local.json` — but they resolve at the moment a command runs, not at
`cc-apply.sh` substitution time, so no `[BRACKET_TOKEN]` exists for either.

---

## Design system

The `design-system` skill ships **brand-neutral** with sensible defaults and renders out of
the box. To brand it, run **`/cc:setup:design`** — it reads `brand.*` from `cc.config.json`,
fills `skills/design-system/systems/template/design.json`, and applies your primary/accent/
background/font to the token layer (`tokens/tokens.css`). The skill provides four adapters
(vanilla CSS, Tailwind/DaisyUI, React, Vue), all driven by the same `--ds-*` tokens — a brand
change propagates everywhere. No design IP from any company is included; everything is generic.

---

## Brand assets (logos, templates)

Logos and document/slide templates are binary files config can't generate. Add them with
`/cc:setup:brand` (it copies the files and points the config at them). The neutral slot is
`skills/brand/brands/template/`; copy it to `skills/brand/brands/<company>/` for a named brand.

---

## Verify a configured install

```bash
BASE="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo .)/global"   # or just: BASE=global

# 1) No unfilled config tokens remain (after /cc:setup:configure):
grep -rnE "\[COMPANY\]|\[COMPANY_PRODUCT\]|\[PRODUCT_[A-E]\]|\[SOLUTION_SUITE_[0-9]\]|\[(PRIMARY|ACCENT|BACKGROUND)_COLOR_HEX\]|\[BRAND_FONT\]|\[QUALIFICATION_FRAMEWORK\]" \
  "$BASE/skills" "$BASE/commands" "$BASE/agents" 2>/dev/null | grep -v WHAT_TO_UPDATE
# (Before configuring, hits here are expected — they're the template tokens.)

# 2) No real company/product brand leaked in un-tokenized (should be empty;
#    supply-chain-map vendor reference tables are legitimate and excluded):
grep -rinE "wisetech|e2open|cargowise|easyclass|docai|graphik" \
  "$BASE/skills" "$BASE/commands" "$BASE/agents" 2>/dev/null \
  | grep -viE "supply-chain-map|WHAT_TO_UPDATE|maintain/audit|cc.config"
```

Both checks are also run by `/cc:maintain:audit`, and the placeholder-sync half runs
mechanically in `bash scripts/cc-audit.sh` (and in CI on every push) — so a clean tracked
tree can't silently regress. If you're sharing the plugin with a teammate, this is the
"clean-room" machinery: see the repo-root `README.md` → **Sharing with your team**.
