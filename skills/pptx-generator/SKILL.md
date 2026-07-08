---
name: pptx-generator
description: |
  Generates and edits presentation slides as PPTX files, compatible with PowerPoint, Google
  Slides, and Keynote -- including PDF carousels for LinkedIn. Use when you say "create slides",
  "make a deck", "generate presentation", "build a slide deck", or "create a carousel".
---

# PPTX Slide Generator

Generate professional, on-brand presentation slides using python-pptx. Supports:
- **Slide Generation** — Create presentations from deal notes, discovery outputs, ROI data
- **Carousel Generation** — LinkedIn carousels (square format, exports to PDF)
- **Slide Editing** — Modify existing PPTX files

**All skill resources are in `${CLAUDE_PLUGIN_ROOT}/skills/pptx-generator/`.** Glob starting from that path.

---

## CRITICAL: Batch Generation Rules

**NEVER generate more than 5 slides at once.**

| Rule | Details |
|------|---------|
| Max slides per batch | **5** |
| After each batch | **STOP and validate output** |
| After ALL batches | **COMBINE into single file and DELETE part files** |

---

## PREREQUISITE: Brand Selection

**ALWAYS ask this before generating any slides:**

> "Which brand should I use for this deck? (Check brands/ directory for configured brands, or set one up from brands/template/ — see BRAND_SETUP.md)"

Wait for the user's answer. Then load from the **central brand registry**:
```
Read: ${CLAUDE_PLUGIN_ROOT}/skills/brand/brands/{chosen-brand}/brand.json
Read: ${CLAUDE_PLUGIN_ROOT}/skills/pptx-generator/brands/{chosen-brand}/config.json (optional — skip if the file does not exist)
Read: ${CLAUDE_PLUGIN_ROOT}/skills/pptx-generator/brands/{chosen-brand}/tone-of-voice.md (optional — skip if the file does not exist)
```

Use `brand.json` values for slide background, accent, font, and logo.
Apply the brand's tone-of-voice rules to all generated copy, not just colors.

---

## Creating a New Brand

### Gather Information

| Required | Description |
|----------|-------------|
| **Brand name** | Folder name (lowercase, no spaces) — e.g., `acme`, `mycompany` |
| **Colors** | Background, text, accent colors (hex codes) |
| **Fonts** | Heading font, body font |

### Create Brand Files

1. Create the brand in the **central registry** — `${CLAUDE_PLUGIN_ROOT}/skills/brand/brands/{brand-name}/brand.json`, using the registry's schema (see `skills/brand/SKILL.md`; copy `skills/brand/brands/template/`):
```json
{
  "company_name": "Brand Name",
  "primary_color": "#000000",
  "accent_color": "#0066CC",
  "background_color": "#FFFFFF",
  "font_family": "Inter",
  "font_weights": [400, 600, 700],
  "logo_dark": "assets/logo-dark.svg",
  "logo_light": "assets/logo-light.svg",
  "docx_template": null,
  "pptx_template": null,
  "tone_rules": ["Active voice preferred"],
  "sign_off": "Your standard sign-off"
}
```
Place logo files in `skills/brand/brands/{brand-name}/assets/`.

2. Create `${CLAUDE_PLUGIN_ROOT}/skills/pptx-generator/brands/{brand-name}/config.json`:
```json
{
  "output": {
    "directory": "output/{brand}",
    "naming": "{name}-{date}",
    "keep_parts": false
  },
  "generation": {
    "slides_per_batch": 5,
    "auto_combine": true,
    "open_after_generate": false
  },
  "defaults": {
    "slide_width_inches": 13.333,
    "slide_height_inches": 7.5
  }
}
```

3. Create `brands/{brand-name}/tone-of-voice.md` — describe the brand voice and vocabulary.

---

## Generating Slides

### Step 1: Brand Loading

Brand was already selected in the prerequisite step. Load:
1. `${CLAUDE_PLUGIN_ROOT}/skills/brand/brands/{chosen-brand}/brand.json` — colors, fonts, logos (central registry)
2. `brands/{chosen-brand}/config.json` — output settings (this skill, optional)
3. `brands/{chosen-brand}/tone-of-voice.md` — copy rules and vocabulary (this skill, optional; `tone_rules` in brand.json otherwise)

Apply tone-of-voice guidance to every text element, not just slide titles.

### Step 2: Layout Discovery

**Read ALL layout frontmatters before selecting any layout.** Each `.py` file in `cookbook/` has a `# /// layout` frontmatter block with `purpose`, `best_for`, `avoid_when`, `max_*` limits, and `instructions`.

```
Glob: ${CLAUDE_PLUGIN_ROOT}/skills/pptx-generator/cookbook/*.py
```

Read the first 40 lines of every layout file to build a mental map before choosing.

### Step 3: Visual-First Layout Selection

**DEFAULT TO VISUAL LAYOUTS. Content-slide (title + bullets) is the LAST RESORT.**

**Decision tree — ask IN ORDER before using content-slide:**

```
Do I have 3-5 equal items?          → multi-card-slide
Do I have 2-4 big numbers/metrics?  → stats-slide
Am I comparing two things?          → two-column-slide
Do I have exactly 3 related items?  → floating-cards-slide
Do I have 1-3 words to emphasize?   → giant-focus-slide
Do I have a powerful quote?         → quote-slide
Is content-slide the ONLY option?   → NOW use content-slide
```

**Hard limits:**
- Content-slide should be **<25% of total slides**
- Visual layouts (cards, stats, columns, hero) should be **50%+**
- Never use the same layout **3+ times consecutively**

### Step 4: Slide Planning (ALWAYS DO THIS)

Create a slide plan table before generating a single line:

```markdown
| # | Layout | Title | Key Content | Notes |
|---|--------|-------|-------------|-------|
| 1 | title-slide | ... | ... | ... |
```

Checklist:
- [ ] No duplicate titles
- [ ] Logical flow
- [ ] Content-slide <25%
- [ ] Visual layouts 50%+
- [ ] No 3+ consecutive same-layout slides

### Step 5: Batch Generation

**Max 5 slides per batch.** Execute via UV:

```bash
uv run --with python-pptx==1.0.2 python << 'EOF'
# [Slide generation code with brand values]
EOF
```

**CRITICAL: Every slide MUST have its background explicitly set:**
```python
slide = prs.slides.add_slide(prs.slide_layouts[6])
slide.background.fill.solid()
slide.background.fill.fore_color.rgb = hex_to_rgb(BRAND_BG)
```

### Step 6: Validate Each Batch

After every batch, check:
- No white backgrounds (most common bug — means background wasn't set)
- No duplicate titles
- No text overflow
- Colors match brand
- No trailing punctuation on titles/bullets

Fix before continuing.

### Step 7: Combine Batches

After all batches pass validation:

```python
from pptx import Presentation
from pptx.dml.color import RGBColor
from pathlib import Path

def hex_to_rgb(hex_color):
    h = hex_color.lstrip("#")
    return RGBColor(int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))

BRAND_BG = "REPLACE_WITH_BRAND_BACKGROUND"  # e.g., from brand.json background_color

output_dir = Path("output/{brand-name}")
part_files = sorted(output_dir.glob("{name}-part*.pptx"))
combined = Presentation(part_files[0])

for part_file in part_files[1:]:
    part_prs = Presentation(part_file)
    for slide in part_prs.slides:
        blank_layout = combined.slide_layouts[6]
        new_slide = combined.slides.add_slide(blank_layout)
        # CRITICAL: set background before copying shapes
        new_slide.background.fill.solid()
        new_slide.background.fill.fore_color.rgb = hex_to_rgb(BRAND_BG)
        for shape in slide.shapes:
            new_slide.shapes._spTree.insert_element_before(shape.element, 'p:extLst')

combined.save(output_dir / "{name}-final.pptx")
for part_file in part_files:
    part_file.unlink()
```

---

## LinkedIn Carousels

Square 1:1 format. 5-10 slides. Structure: hook → body points → CTA.

**Dimensions:**
```python
prs.slide_width = Inches(7.5)
prs.slide_height = Inches(7.5)
```

**Export to PDF:**
```bash
libreoffice --headless --convert-to pdf --outdir output/{brand} output/{brand}/carousel.pptx
```

---

## Text Formatting Rules

| Element | Rule |
|---------|------|
| Titles | No trailing periods or commas |
| Bullet points | No trailing periods (unless full sentences) |
| Stats/Numbers | Clean format — "50%" not "50%." |
| Labels | Short, no punctuation |

---

## Technical Reference

**Slide dimensions (16:9):** Width 13.333", Height 7.5"

**Always use:** `prs.slide_layouts[6]` (blank layout), `python-pptx==1.0.2`

**Common imports:**
```python
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.util import Inches, Pt
```

**Brand color mapping (from the central registry's brand.json):**

| Layout Placeholder | brand.json Key |
|--------------------|-----------------|
| `BRAND_BG` | `background_color` |
| `BRAND_TEXT` | `primary_color` |
| `BRAND_ACCENT` | `accent_color` |
| `BRAND_HEADING_FONT` | `font_family` |
| `BRAND_BODY_FONT` | `font_family` |

Registry color values are hex **WITH** the `#` prefix — strip it before passing to python-pptx (`RGBColor.from_string` takes bare hex).
