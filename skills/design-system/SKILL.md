---
name: design-system
description: >-
  On-brand UI from a config-driven design system — brand tokens plus a component kit in vanilla
  CSS, Tailwind/DaisyUI, React, and Vue adapters. Use when building or restyling UI, prototypes,
  or components: "design system", "UI kit", "style this page", "theme the app", "make a
  button/card/modal".
user-invocable: true
---

# Design System

A brand-neutral foundation for building consistent UI. **Nothing here names a company** — it
ships with sensible defaults and is brandable through configuration, so any team can adopt it.

**Read this before generating any UI, page, prototype, or component.**

---

## Precedence — check the project FIRST

A project's own design standards **always win**. Never override a project that already has a
design system. Before applying anything, determine who owns design here — check in order,
first match wins:

1. **Explicit override** — `<project>/${user_config.workspace_dir}/design.json`. If `authority: "project"`, **DEFER**:
   use the project's design per its `use` field and do **not** apply cc's tokens. If
   `authority: "cc"`, use the named cc `system`.
2. **Existing project authority** — a project-scoped design/theme skill, or a tokens file
   (`theme.css`, `theme.ts`, a Tailwind/DaisyUI theme, `design-tokens.*`, etc.). If present,
   **DEFER** (generate in the project's style by reading its tokens), and offer to record it
   in `${user_config.workspace_dir}/design.json` so it's explicit next time.
3. **cc default** — only if neither exists: use the configured `systems/<company>/`, else the
   neutral `systems/template/` (Modern theme).

`${user_config.workspace_dir}/design.json` schema:

| Key | Values | Meaning |
|-----|--------|---------|
| `authority` | `"project"` \| `"cc"` | who owns design in this repo |
| `use` | `"skill:<name>"` \| `"tokens:<path>"` \| `"system:<name>"` | what to read / apply |
| `note` | string | human-readable rationale |

When in doubt, **ask before overriding any existing styling.** `/cc:setup:design` can detect
an existing project design system and write this file for you.

---

## What this provides

| Part | Path | Use |
|------|------|-----|
| Token layer | `tokens/tokens.css` | The source of truth — CSS custom properties (`--ds-*`); two switchable themes: **modern** (Graphite) + **classic** (Warm Editorial). |
| Usage spec | `README.md` | Voice/content defaults + visual foundations (color, type, spacing, etc.). |
| Vanilla kit | `ui-kits/vanilla/` | Framework-free HTML + CSS components (the canonical reference). |
| Tailwind/DaisyUI | `ui-kits/tailwind-daisyui/` | Maps `--ds-*` → a DaisyUI `[data-theme]` object + demo. |
| React | `ui-kits/react/` | Token-consuming React components. |
| Vue | `ui-kits/vue/` | Token-consuming Vue components. |
| Preview cards | `preview/` | One reference card per concept (colors, type, spacing, elevation, components). |

---

## How to use

1. **Pick a system.** Default is `systems/template/`. For a named brand, copy
   `systems/template/` → `systems/<company>/` and fill `design.json`.
2. **Read tokens first.** Always load `tokens/tokens.css` and the chosen
   `systems/<system>/design.json` before generating, so output uses the real brand values —
   never hardcode colors or fonts.
3. **Pick the adapter** that matches the target project:
   - Plain HTML/CSS → `ui-kits/vanilla/`
   - Tailwind + DaisyUI → `ui-kits/tailwind-daisyui/` (use the `[data-theme]` object)
   - React → `ui-kits/react/` · Vue → `ui-kits/vue/`
4. **Style only via tokens.** Every component references `--ds-*` variables. To rebrand, you
   change tokens (or `design.json`), never the components.

---

## Brand selection

If a project might have more than one configured system, **ask first**:

> "Which design system should I use? (Check `systems/` for configured ones, or I can set up a
> new one from `systems/template/`.)"

Then load `tokens/tokens.css` + `systems/<chosen>/design.json`.

---

## Configuring it

Run **`/cc:setup:design`** — a guided, conversational setup that reads your brand
(`cc.config.json`), fills `design.json`, and applies your colors/font to the tokens. You never
have to edit files by hand. To change company name/products globally use `/cc:setup:configure`;
to change logo/colors use `/cc:setup:brand`. All are re-runnable and safe to repeat.

---

## Component coverage

Button (variants + sizes), badge, card, stat / KPI tile, data table (toolbar, count, sortable
header), modal, form controls (input, select, textarea, checkbox, toggle, label), tabs,
toast / alert, loading / spinner, link, sidebar nav, and empty state — in every adapter.
