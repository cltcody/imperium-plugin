---
description: Guided design-system setup — apply your brand to the generic design tokens through a conversation; no file editing required
argument-hint: "[optional: a name for your design system]"
---

# Setup: Design System

Apply your brand to the generic design system — colors, font, density, theme, and which
front-end adapters you use — entirely through conversation. **You do the talking; this
command does the file work.** Never ask the user to edit JSON, run scripts, or move files
themselves — offer each step, confirm, and verify it worked.

Tone: warm, concrete, one thing at a time. Assume the user just wants their app to look
on-brand and doesn't care where tokens live.

> **Precedence first.** If you're setting up design *for a specific project* that already has
> its own design system — a project theme/design skill, a `theme.*`/tokens file, or a
> Tailwind/DaisyUI theme — do **not** impose cc. Tell the user, then offer to write
> `<project>/[WORKSPACE_DIR]/design.json` with `authority: "project"` (and `use: "skill:<name>"` or
> `use: "tokens:<path>"`) so the `design-system` skill defers to their standards. Stop there.
> Only configure the cc design system below for projects that don't already have one.

## Steps

### 1 — Find the plugin source

The design system lives in the plugin **source** (the `global/` directory), not the installed
copy. Locate it: if the current directory is the plugin source, use it; otherwise run
`claude plugin marketplace list` and read the `imperium` marketplace's
`Source: Directory (...)` path. If you still can't find it, ask the user where they saved the
Command Center plugin folder. Set `<ROOT>` to that directory. The skill is at
`<ROOT>/skills/design-system/`.

### 2 — Read what's already set

Read the active config (`<ROOT>/cc.config.local.json` if it exists, else the `cc.config.json`
template) `brand.*` and `<ROOT>/skills/design-system/systems/<SYSTEM>/design.json` (default
`<SYSTEM>` = `template`).
Tell the user, in plain language, what's configured and what's missing — e.g.: "Your colors
are set (navy + blue), font is Inter, and the design system ships with light + dark themes.
Want to give it a name and pick which framework you build in?"

### 3 — Collect the few choices (conversational)

Ask, one at a time, accepting plain answers. Use `$ARGUMENTS` as the system name if provided.
- **Name** for this design system (e.g. "Acme UI"). Writes `system_name`.
- **Starting style** — show the two shipped presets and let them pick (this is the main
  aesthetic choice). Writes `theme`:
  - **Modern (Graphite)** — cool neutrals, near-black ink, restrained indigo accent. Clean,
    minimal, "Linear/Vercel/Stripe" professional. *(default)*
  - **Classic (Warm Editorial)** — warm stone neutrals, ink, refined amber accent. Premium,
    editorial.
  Offer to render `skills/design-system/preview/components.html` (or the switcher demo) so
  they can *see* both before choosing. Both ship regardless — this records the default; an
  app can switch at runtime via `data-theme`.
- **Density**: comfortable (default) or compact. Writes `density`.
- **Adapter(s)** the project uses: vanilla CSS, Tailwind/DaisyUI, React, Vue (multiple ok).
  Writes `adapters`. Tell them all four ship regardless — this just records the primary.
- **Colors & font**: read the current `brand.*` values and show them simply. If any are
  still defaults/unset, say so and offer to set them here or via `/cc:setup:brand`. Accept
  plain answers ("make the accent a brighter blue" → pick a hex, confirm).

### 4 — Write the config

- Write the collected values into `design.json` (preserve structure; drop the `_instructions`
  key once real values are in).
- If colors/font changed, write them to `<ROOT>/cc.config.local.json` `brand.*` too (the
  gitignored override — create it from `cc.config.json` if absent; never the tracked template),
  so every skill stays in sync.

### 5 — Optional: a named system

If the user wants a named system (vs. editing `template`), copy
`<ROOT>/skills/design-system/systems/template/` → `systems/<slug>/`, write `design.json`
there, and tell them the skill will offer it by name.

### 6 — Apply the brand to the tokens (do it for them)

- Run `bash <ROOT>/scripts/cc-apply.sh --apply` — pushes `brand.*` values into `design.json`
  (and any placeholder-bearing assets).
- Apply the brand colors/font to the **token layer** so the canonical CSS reflects the brand:
  in `<ROOT>/skills/design-system/tokens/tokens.css`, update the four "Brand layer" values
  (`--ds-color-primary`, `--ds-color-accent`, `--ds-color-bg`, `--ds-font-sans`) to the
  resolved hex/font. (For a named system, write a `systems/<slug>/tokens.css` that
  re-declares just those four instead of editing the shared file.) Keep the neutral ramp and
  scales untouched.
- Run `bash <ROOT>/scripts/cc-publish.sh --skip-config` to make it live, then
  `/reload-plugins` or restart picks it up.
Report all three in one friendly line — don't show raw script noise unless something failed.

### 7 — Verify and reassure

Confirm: `design.json` has a name + brand values, and `tokens.css`'s brand layer matches.
Optionally open `<ROOT>/skills/design-system/preview/colors.html` and
`ui-kits/tailwind-daisyui/demo.html` to show the result. Report a short checklist:

```
Design system ✓
  Name:     Acme UI
  Colors:   #1A2B5C primary · #2E6FE0 accent · #FFFFFF bg
  Font:     Inter
  Style:    Modern (default) · Classic available — switch via data-theme
  Adapters: vanilla · tailwind-daisyui · react · vue
Live now — reload Claude Code to see it. Run /cc:setup:design again anytime to change things.
```

If anything is still missing, say exactly what and offer to handle it now — never leave the
user with a manual to-do.

## Notes

- Fully re-runnable. To change brand colors/logo, run `/cc:setup:brand`; to change company
  name/products, run `/cc:setup:configure`. All re-apply safely.
- **When to use the skill vs. this command:** this command *configures* the design system;
  the `design-system` skill *uses* it to generate UI. After setup, just ask to build a
  component or style a page and the skill reads your tokens.
- Best run per project's UI work — see `/cc:setup:stack` and `/cc:plan:setup`, which point
  here when a project has a front end.
