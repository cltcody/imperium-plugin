---
name: docx-generator
description: |
  Generates on-brand Word documents (.docx) — proposals, executive summaries, solution designs,
  handover docs, ROI cases. Use on "generate a word doc", "docx", "create a proposal document", or
  "branded document".
---

# Word Document Generator

Generate professional, on-brand Word documents (.docx) using python-docx. Covers all common document types. Brand is configured in `brands/template/` (see BRAND_SETUP.md).

**All skill resources are in `${CLAUDE_PLUGIN_ROOT}/skills/docx-generator/`.** Glob from that path when you need brand files.

---

## PREREQUISITE: Brand + Document Type Selection

**ALWAYS ask both questions before generating anything.**

**Question 1 — Brand:**
> "Which brand should I use? (Check brands/ directory for configured brands, or set up a new one from brands/template/)"

**Question 2 — Document type:**
> "What type of document?
> - **Proposal** — formal commercial proposal (cover → solution → commercial terms → next steps)
> - **Executive Summary** — 1–2 page brief for C-suite / economic buyer
> - **Letter** — formal business letter on branded letterhead
> - **Discovery Questionnaire** — structured pre-call or post-call questions document
> - **Solution Design** — technical solution document
> - **Handover Document** — PreSales → Professional Services handover
> - **ROI Business Case** — 3-year value case with financial model table
> - **Meeting Notes** — structured call summary with ${user_config.qualification_framework} update
> - **Report / Analysis** — general research or findings document"

After both answers, load from the **central brand registry**:
```
Read: ${CLAUDE_PLUGIN_ROOT}/skills/brand/brands/{chosen-brand}/brand.json
Read: ${CLAUDE_PLUGIN_ROOT}/skills/docx-generator/brands/{chosen-brand}/tone-of-voice.md (optional — skip if the file does not exist)
```

Use `brand.json → formats.docx` for page dimensions, margins, and template path.

---

## Template Mode vs Scratch Mode

| Mode | When to use | How |
|------|-------------|-----|
| **Template mode** | Letters, correspondence, any doc needing exact letterhead | `Document(brand['docx_template'])` |
| **Scratch mode** | All other document types | `Document()` |

**Template path:** Set `docx_template` in `brands/{your-brand}/brand.json` (configure in `brands/template/` — see BRAND_SETUP.md). If `docx_template` is `null`, use scratch mode.

In template mode, after opening the template, **clear all existing body content** before inserting new text:
```python
from docx import Document
from docx.oxml.ns import qn

doc = Document(brand_config['docx_template'])
# Remove all body paragraphs (keeps header/footer/styles intact)
for para in list(doc.paragraphs):
    p = para._element
    p.getparent().remove(p)
```

---

## Document Structures

### Proposal
1. Cover page — logo, document title, "Prepared for: [Company]", "Prepared by: [Name]", date
2. Executive Summary — situation, proposed solution (3 bullets), key business value
3. Understanding Your Challenge — customer pain points (from discovery)
4. Proposed Solution — capability mapping to pains
5. Why ${user_config.company} — 3 differentiators with evidence
6. Commercial Terms — [placeholder: insert pricing summary]
7. Implementation Timeline — milestone table
8. Next Steps — 3 specific actions with owners and dates

### Executive Summary
1. Header with logo and date
2. Situation (3–5 sentences: context, challenge, urgency)
3. Proposed Solution (4–6 bullets)
4. Business Value — table: Value Driver | Metric | Outcome
5. Recommended Next Step — one specific action with a date

### Letter
1. Use Template Mode — opens the letterhead file as base
2. Recipient block (name, company, address)
3. Date (DD Month YYYY)
4. RE: subject line (bold)
5. Body paragraphs (2–4)
6. Closing + signature block (name, title, company, email, phone)

### Discovery Questionnaire
1. Cover — prospect company, contact name, prepared by, date, call objective
2. Purpose statement — one paragraph on what this document is
3. Sections per domain (use H2 per domain, numbered questions under each):
   - Current State & Environment
   - Pain Points & Business Impact
   - Requirements & Success Criteria
   - Technical Environment & Integrations
   - Decision Process & Timeline
4. Action Items / Next Steps — table: Action | Owner | Due Date

### Solution Design
1. Cover page
2. Table of Contents (manual — list sections with page references as placeholders)
3. Executive Overview (1 page)
4. Business Requirements
5. Solution Architecture (description + diagram reference)
6. Integration Design (table: System | Integration type | Data flow | Complexity)
7. Data Migration Plan
8. Assumptions & Dependencies
9. Risks & Mitigations (table: Risk | Likelihood | Impact | Mitigation)
10. Implementation Plan (table: Phase | Activity | Duration | Owner)

### Handover Document
1. Cover page
2. Deal Summary (product, contract value, go-live date)
3. Customer Profile & Stakeholders (table: Name | Role | Influence | Relationship)
4. Solution Sold — scope and modules
5. Agreed Success Criteria (numbered list)
6. Key Pains & Value Drivers
7. Technical Environment — systems, integrations, constraints
8. Open Items / Risks
9. Contacts (table: Name | Role | Company | Email | Phone)

### ROI Business Case
1. Cover page
2. Executive Summary
3. Current State Cost Analysis (table: Cost category | Annual cost | Basis)
4. Value Driver Analysis — one H2 section per driver with: description, assumption, annual value
5. Financial Model — table: Year 0 | Year 1 | Year 2 | Year 3 with investment, benefits, net, cumulative
6. Payback Period & IRR statement
7. Assumptions & Caveats (numbered list)

### Meeting Notes
1. Meeting Details — date, attendees table (Name | Company | Role), objective
2. Key Findings (bullets)
3. ${user_config.qualification_framework} Update — table: Element | Previous | Updated | Source
4. Action Items — table: Action | Owner | Due Date
5. Next Steps (3 bullets)

### Report / Analysis
1. Cover page
2. Executive Summary
3. Background
4. Findings — numbered H2 sections, each with body + supporting table or bullets
5. Recommendations (numbered)
6. Appendix (if needed)

---

## Generation Steps

### Step 1: Plan the Document

Before writing any code, output a document plan:
```
Document type:  [type]
Brand:          [brand]
Mode:           [scratch / template]
Account:        [company name]
Sections:       [list with ~word count per section]
Tables needed:  [list table names]
Tone notes:     [2–3 rules from tone-of-voice.md that apply here]
Output path:    output/{brand}/{doctype}-{account}-{YYYYMMDD}.docx
```

### Step 2: Generate in Sections (max 3 sections per batch)

**Max 3 document sections per code execution.** Stop and validate after each batch.

Run via uv:
```bash
uv run --with python-docx python << 'EOF'
# [Document generation code]
EOF
```

### Step 3: Apply Brand Styles

Always apply all values from brand.json. Core boilerplate:

```python
from docx import Document
from docx.shared import Pt, Cm, RGBColor, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from pathlib import Path
import json

# Load brand config from brands/{chosen-brand}/brand.json
with open('brands/{chosen-brand}/brand.json') as f:
    brand_config = json.load(f)

# Derive colors, fonts, sizes from brand_config
primary_color = brand_config.get('primary_color', '#000000')
accent_color = brand_config.get('accent_color', '#0066CC')
font_family = brand_config.get('font_family', 'Arial')

def hex_to_rgb(hex_str):
    h = hex_str.lstrip('#')
    return RGBColor(int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))

doc = Document()  # or Document(brand_config['docx_template']) for template mode

# Page setup (A4)
sec = doc.sections[0]
sec.page_width  = Cm(21.0)
sec.page_height = Cm(29.7)
sec.top_margin    = Cm(2.54)
sec.bottom_margin = Cm(2.54)
sec.left_margin   = Cm(2.54)
sec.right_margin  = Cm(2.54)
```

### Component Recipes

**Heading:**
```python
def add_heading(doc, text, level, accent_color, font_family):
    para = doc.add_heading(text, level=level)
    run = para.runs[0] if para.runs else para.add_run(text)
    run.font.color.rgb = hex_to_rgb(accent_color)
    run.font.name = font_family
    return para
```

**Body paragraph:**
```python
def add_body(doc, text, primary_color, font_family, size_pt=11):
    para = doc.add_paragraph()
    run = para.add_run(text)
    run.font.color.rgb = hex_to_rgb(primary_color)
    run.font.name = font_family
    run.font.size = Pt(size_pt)
    return para
```

**Bullet list:**
```python
def add_bullet(doc, text, primary_color, font_family, level=0):
    style = 'List Bullet' if level == 0 else 'List Bullet 2'
    para = doc.add_paragraph(style=style)
    run = para.add_run(text)
    run.font.color.rgb = hex_to_rgb(primary_color)
    run.font.name = font_family
    run.font.size = Pt(11)
    return para
```

**Table with branded header row:**
```python
def set_cell_bg(cell, color_hex):
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'), color_hex)
    tcPr.append(shd)

def add_branded_table(doc, headers, rows, accent_color, primary_color, font_family):
    table = doc.add_table(rows=1 + len(rows), cols=len(headers))
    table.style = 'Table Grid'
    header_bg = accent_color.lstrip('#')
    # Header row
    hdr = table.rows[0]
    for i, h in enumerate(headers):
        cell = hdr.cells[i]
        cell.text = ''
        set_cell_bg(cell, header_bg)
        run = cell.paragraphs[0].add_run(h.upper())
        run.font.bold = True
        run.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
        run.font.name = font_family
        run.font.size = Pt(10)
    # Data rows
    for r, row_data in enumerate(rows):
        for c, text in enumerate(row_data):
            cell = table.rows[r + 1].cells[c]
            cell.text = ''
            run = cell.paragraphs[0].add_run(text)
            run.font.color.rgb = hex_to_rgb(primary_color)
            run.font.name = font_family
            run.font.size = Pt(11)
    return table
```

**Callout / note box (single-cell table with coloured background):**
```python
def add_callout(doc, label, text, accent_color, font_family):
    table = doc.add_table(rows=1, cols=1)
    cell = table.rows[0].cells[0]
    set_cell_bg(cell, 'F5F5F5')
    para = cell.paragraphs[0]
    label_run = para.add_run(f'{label}: ')
    label_run.bold = True
    label_run.font.color.rgb = hex_to_rgb(accent_color)
    label_run.font.name = font_family
    label_run.font.size = Pt(10)
    body_run = para.add_run(text)
    body_run.font.name = font_family
    body_run.font.size = Pt(10)
    return table
```

**Logo in header (right-aligned):**
```python
def add_logo_to_header(doc, logo_path, width_cm=3.5):
    section = doc.sections[0]
    header = section.header
    para = header.paragraphs[0] if header.paragraphs else header.add_paragraph()
    para.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    run = para.add_run()
    run.add_picture(logo_path, width=Cm(width_cm))
```

**Page break:**
```python
from docx.enum.text import WD_BREAK
def add_page_break(doc):
    para = doc.add_paragraph()
    run = para.add_run()
    run.add_break(WD_BREAK.PAGE)
```

### Step 4: Validate Each Batch

- [ ] Heading colors match brand accent color (not default black/blue)
- [ ] Table header rows have branded background and white text
- [ ] Body font is correct per brand.json
- [ ] Page margins are A4 standard
- [ ] No lorem ipsum, "[PLACEHOLDER]", or unreplaced template text
- [ ] File opens cleanly in Word (no corruption warnings)
- [ ] Dates in DD Month YYYY format

### Step 5: Save

```python
from pathlib import Path

output_dir = Path('output/{brand-name}')
output_dir.mkdir(parents=True, exist_ok=True)
filename = '{doctype}-{account-slug}-{YYYYMMDD}.docx'
doc.save(output_dir / filename)
print(f'Saved: {output_dir / filename}')
```

---

## Logo Assets

Logo files live in `brands/{your-brand}/assets/` (configure in `brands/template/` — see BRAND_SETUP.md).

| Background | Logo key in brand.json |
|------------|------------------------|
| Light (on white) | `logo_dark` |
| Dark | `logo_light` |

Resolve the logo path relative to the brand directory:
```python
brand_dir = Path('brands/{chosen-brand}')
logo_path = brand_dir / brand_config['logo_dark']  # or logo_light
```

---

## Technical Reference

**Always use:** `python-docx>=1.2` via `uv run --with python-docx python`

**Key imports:**
```python
from docx import Document
from docx.shared import Pt, Cm, RGBColor, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from pathlib import Path
```

**Page size:** A4 for all brands — `Cm(21.0)` x `Cm(29.7)`

**Output directory:** `output/{brand-name}/`

**File naming:** `{doctype}-{account-slug}-{YYYYMMDD}.docx`
Example: `proposal-acme-logistics-20260609.docx`

---

## Text Formatting Rules

| Element | Rule |
|---------|------|
| H1 / H2 headings | Title Case |
| H3 and below | Sentence case |
| Body copy | Sentence case, no trailing period on bullets |
| Table headers | ALL CAPS or Title Case — never sentence case |
| Dates | DD Month YYYY — e.g., 09 June 2026 |
| Numbers | Numerals for all quantities — "3 weeks", "14 systems" |
| Company name | Use exact spelling from brand.json `company_name` |
