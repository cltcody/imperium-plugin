---
name: brand
description: >
  Shared brand registry for any company or co-branded output.
  NOT invoked directly by users. Read by output skills (pptx-generator, docx-generator)
  before generating any branded artefact. Contains authoritative color
  tokens, font specs, logo asset paths, typography rules, and format-specific configs
  for PPTX, DOCX, HTML, and Excalidraw. Configure your brand in brands/template/brand.json.
user-invocable: false
---

# Brand Registry

Shared asset library for all output skills that generate branded content.

**Read this before generating any slide, document, diagram, or HTML artefact.**

---

## Which skills use this

| Skill | What it reads |
|-------|--------------|
| `pptx-generator` | `brand.json` → `formats.pptx` section |
| `docx-generator` | `brand.json` → `formats.docx` section |
| Future `html-report` | `brand.json` → `formats.html` section |

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

Do not store format-specific values (slide dimensions, page margins) in output skills — they belong in `brand.json` under `formats.{output-type}`.
