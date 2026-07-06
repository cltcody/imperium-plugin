# Design System — Reference

A neutral, brand-agnostic design system. This document describes **how** the system is built
so you can apply it (and customize it) consistently. It deliberately defines *form* — how a
color role or type step is defined — rather than any specific brand's palette. Customize it
for your company with `/cc:setup:design`.

> Drop-in goal: a team can adopt this as-is, set four brand values (primary, accent,
> background, font), and get a coherent UI without designing tokens from scratch.

---

## Content fundamentals (defaults)

- **Voice:** clear, plain, active. Say what a control does.
- **Casing:** Sentence case for UI labels, buttons, and headings; reserve Title Case for
  product/section names if your brand uses it.
- **Tone:** neutral and functional. No emoji in product chrome.
- **Numbers & dates:** one format per surface; default date format `YYYY-MM-DD`.

These are defaults — override them in your brand's `tone_rules` if needed.

---

## Visual foundations

### Color
Color is organized by **role**, not by hue, so the same component works across themes:

- **Brand:** `primary`, `primary-hover`, `primary-fg`, `accent` — the only values most teams
  change. Set via `cc.config.json` brand block / `/cc:setup:design`.
- **Neutral surfaces:** `bg` (canvas), `surface`, `surface-2` (layered panels), `border`.
- **Text:** `fg` (primary), `fg-muted` (secondary).
- **Semantic:** `success`, `warning`, `error`, `info`, plus `on-semantic` for text on a
  filled semantic surface.

Each role is a `--ds-color-*` variable in `tokens/tokens.css`. **Two professional themes**
ship as a switcher (set `data-theme` on a root element):

- **`modern`** (default) — *Graphite*: cool neutrals, near-black ink, restrained indigo
  accent. Clean and minimal.
- **`classic`** — *Warm Editorial*: warm stone neutrals, ink, refined amber accent. Premium.

Both re-declare the same role names, so components never special-case the theme — switching
is one attribute. The neutral ramp, type, spacing, radii, elevation and motion are shared.

### Typography
- **Families:** `--ds-font-sans` (UI) and `--ds-font-mono` (code/data). Default `Inter` +
  system stack; brandable.
- **Scale:** eight steps, `--ds-text-xs` → `--ds-text-4xl`.
- **Weights:** normal 400, medium 500, semibold 600, bold 700.
- **Leading:** tight (headings), normal (body), relaxed (long-form).

### Spacing
A single 4px-based scale, `--ds-space-1` (4px) → `--ds-space-8` (64px). Use it for padding,
gaps, and margins so rhythm stays consistent.

### Radii
`sm` 4px · `md` 8px · `lg` 12px · `pill` 9999px. Cards use `lg`, controls use `md`,
chips/badges use `pill`.

### Elevation
Two shadow tiers: `--ds-shadow-1` (resting cards, chips) and `--ds-shadow-2` (raised
surfaces, modals, popovers). Keep elevation meaningful — don't stack shadows arbitrarily.

### Motion
One easing curve (`--ds-ease`) and two durations (`--ds-duration-fast`, `--ds-duration`).
Use fast for hover/press feedback, base for entering/leaving content.

### Layout
- Content max-width ~1100–1280px for dense apps; use the spacing scale for gutters.
- A fixed left sidebar nav pattern is provided in the kits (logo, sections, items, active
  state, footer) for app shells.

### Iconography
No icon font is bundled (to stay license-clean). Use any open-source set (e.g. a SemVer'd
SVG icon library) sized on the spacing scale (16/20/24px). Reference icons by role, not by a
specific vendor's glyph names.

---

## Customizing

1. Run `/cc:setup:design` — it reads your brand from `cc.config.json`, fills
   `systems/template/design.json` (or a `systems/<company>/` copy), and applies your
   primary/accent/background/font to the tokens.
2. To change brand colors/logo later, run `/cc:setup:brand`; to change company name/products,
   run `/cc:setup:configure`. Re-running is safe.
3. Everything downstream (all four adapters, the preview cards) reads `--ds-*` — so a brand
   change propagates everywhere without editing components.

---

## Per-project override

This design system is a **default, not a mandate**. A project that already has its own brand
standards keeps them — the skill checks for project authority before applying anything (see
the Precedence section in `SKILL.md`). To make it explicit, drop a `<project>/[WORKSPACE_DIR]/design.json`:

```json
{ "authority": "project", "use": "skill:theme", "note": "This repo owns its design system." }
```

- `authority: "project"` → cc defers entirely (your skill/tokens win).
- `use: "tokens:<path>"` → cc still generates UI, but reads *your* tokens so output matches.
- `authority: "cc", "system": "<name>"` → opt back into a cc system for this repo.

Mirrors how `STACK.md` overrides dev tooling per project: global default, local override.

---

## Adapters at a glance

| Adapter | When | Entry point |
|---------|------|-------------|
| `ui-kits/vanilla/` | Plain HTML/CSS, server-rendered templates | `components.html` + `components.css` |
| `ui-kits/tailwind-daisyui/` | Tailwind + DaisyUI projects | `theme.js` (`[data-theme]` map) + `demo.html` |
| `ui-kits/react/` | React apps | `Components.jsx` |
| `ui-kits/vue/` | Vue apps | `Components.vue` |

All four consume the **same** `tokens/tokens.css` variables — pick the one that fits the
target codebase.
