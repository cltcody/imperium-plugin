---
name: brand
description: |
  Shared brand registry read by output skills (pptx-generator, docx-generator) before any branded
  artefact — color tokens, fonts, logo paths, templates. Configure in brands/template/brand.json.
user-invocable: false
---

# Brand Registry

Shared asset library for all output skills that generate branded content.

**Read this before generating any slide, document, diagram, or HTML artefact.**

---

## Which skills use this

| Skill | What it reads |
|-------|--------------|
| `pptx-generator` | `brand.json` → colors, `font_family`, logos, `pptx_template` |
| `docx-generator` | `brand.json` → colors, `font_family`, logos, `docx_template` |
| Future `html-report` | `brand.json` → colors, `font_family`, logos |

**Skills that do NOT use this registry:**
- `diagram` — uses its own semantic color grammar defined in the skill. Brand colors would destroy semantic encoding.

---

## Brand setup

Copy `brands/template/` to `brands/{your-company}/`, fill in `brand.json`, and place logo SVGs in `assets/`.

---

## Brand selection

**Always ask the user which brand before loading any config:**

> "Which brand would you like to use? (Check brands/ directory for available configs, or set up a new one from brands/template/)"

Then load:
```
Read: ${CLAUDE_PLUGIN_ROOT}/skills/brand/brands/{chosen-brand}/brand.json
```

---

## Directory structure

```
${CLAUDE_PLUGIN_ROOT}/skills/brand/
├── SKILL.md                         ← this file
└── brands/
    ├── template/                    ← copy this to add a new brand
    │   ├── brand.json               ← fill in your brand values here
    │   └── assets/
    │       ├── logo-dark.svg        ← your dark-background logo
    │       └── logo-light.svg       ← your light-background logo
    └── cobranded/                   ← example: joint branding between two parties
        └── assets/                  ← place co-branded logo assets here
```

---

## brand.json schema

| Key | Purpose |
|-----|---------|
| `company_name` | Display name for headers/footers |
| `primary_color` | Main text/heading color |
| `accent_color` | Links, table headers, emphasis |
| `background_color` | Page/slide canvas |
| `font_family` | Primary typeface |
| `font_weights` | Weights to load (400=regular, 600=semibold, 700=bold) |
| `logo_dark` | Path to logo for dark backgrounds (relative to `assets/`) |
| `logo_light` | Path to logo for light backgrounds (relative to `assets/`) |
| `docx_template` | Path to `.docx` template file, or `null` |
| `pptx_template` | Path to `.pptx` template file, or `null` |
| `tone_rules` | Array of writing/style rules |
| `sign_off` | Standard document sign-off line |

---

## Updating the registry

If brand guidelines change:
1. Update `brands/{brand}/brand.json` — hex values only, never restructure keys
2. Add new logo SVGs to `brands/{brand}/assets/`

Format-specific output settings (slide dimensions, page margins) do NOT belong in `brand.json` — they live in each output skill's own per-brand `config.json` (e.g. `skills/pptx-generator/brands/{brand}/config.json`). `brand.json` holds brand identity only: colors, fonts, logos, templates, tone.
