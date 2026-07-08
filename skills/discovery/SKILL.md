---
name: discovery
description: |
  Full-lifecycle discovery for ${user_config.company} solutions — research, the FTD opening
  framework, and a branded pre-discovery questionnaire or post-call summary. Use on "discovery
  prep", "FTD", "call prep", or "discovery summary".
---

# Discovery Skill

Full-lifecycle discovery for ${user_config.company} presales — from prospect research to
branded Word document delivery.

---

## ALWAYS READ THESE FILES FIRST

Before generating any output, load the following reference files:

```
Read: ${CLAUDE_PLUGIN_ROOT}/skills/discovery/references/shared/opening-framework.md
Read: ${CLAUDE_PLUGIN_ROOT}/skills/discovery/references/shared/standard-questions.md
Read: ${CLAUDE_PLUGIN_ROOT}/skills/discovery/references/shared/advanced-questions.md
Read: ${CLAUDE_PLUGIN_ROOT}/skills/discovery/references/shared/discovery-techniques.md
Read: ${CLAUDE_PLUGIN_ROOT}/skills/discovery/references/suites/{detected-suite}/questions.md
```

If the suite is not yet known, ask in Step 1 and then load the correct file.

**File roles:**
- `opening-framework.md` — how to open and run the session; the universal question flow
- `standard-questions.md` — baseline context (company profile, tech stack, volumes, project context)
- `advanced-questions.md` — strategic depth layer: decision risk, internal alignment, change capacity, data trust, and organisational dynamics. Select 6–8 of these based on deal complexity and stakeholder seniority.
- `discovery-techniques.md` — facilitation techniques: active listening, 5 Whys, empathy mapping, demo-in-discovery handling. Apply throughout.
- `suites/{suite}/questions.md` — product-specific functional and technical questions

---

## Step 1 — Intake

Collect (ask if not already provided):

| Field | Options |
|-------|---------|
| **Account name** | Required — used for research and document cover |
| **Suite** | GTM / TMS / Planning / Channel / Logistics / Supply Collaboration |
| **Brand** | ${user_config.company} (${user_config.company_product}) / ${user_config.company} |
| **Output type** | Pre-discovery questionnaire / Post-call summary / Call guide only (no doc) |
| **Meeting date** | For document headers |
| **SC name** | For document authorship |
| **Prospect contact** | Name + title for the questionnaire |
| **Key context** | Paste any prior emails, CRM notes, or opportunity description |

If the user already provided some of these in their request, do not ask again.

---

## Step 2 — Research Phase

Run this phase before generating any questions. Use every available tool.

### 2a — Salesforce MCP (if connected)

Run a full account crawl. Extract all six layers below. This is the most data-dense
research step — do not stop after finding the primary opportunity.

#### Account Profile
- Account name, industry, sub-industry, employee count, annual revenue
- Headquarters and operating regions
- Account type: Prospect / Customer / Partner
- If existing customer: Customer Since date, products currently live, CSM assigned
- Account owner (AE) and SC assigned
- Account health score or risk flag if captured

#### Existing Revenue & Contracts (existing customers only)
- Total ARR / TCV with ${user_config.company} or ${user_config.company} today
- Active contract lines: product, ARR, contract start/end, renewal date
- Any upcoming renewals or expansion triggers
- Products already live vs. contracted but not yet deployed

#### Open Opportunities
For EVERY open opportunity on this account (not just the primary one):

| Field | Extract |
|-------|---------|
| Opportunity name | |
| Stage | |
| Close date | |
| Deal value (ACV / TCV) | |
| Products in scope | |
| AE and SC assigned | |
| Created date / days in stage | |
| ${user_config.qualification_framework} fields captured | |
| Last activity date and type | |
| Key notes or next steps | |

Summarise the open pipeline as: *"[N] open opportunities totalling $[X], ranging from [earliest stage] to [latest stage]."*
Flag any opportunity that appears to overlap or compete with the current engagement.

#### Closed Won Opportunities (full history)
For each closed won opportunity:

| Field | Extract |
|-------|---------|
| Opportunity name | |
| Close date | |
| Deal value | |
| Products sold | |
| Implementation status | |

Summarise as: *"[N] prior wins totalling $[X]. Most recent: [name], closed [date], selling [products]."*
This is critical context — it tells you what they already use, what they liked, and how the relationship was established.

#### Closed Lost Opportunities (full history)
For each closed lost opportunity:

| Field | Extract |
|-------|---------|
| Opportunity name | |
| Close date | |
| Deal value | |
| Loss reason | |
| Competitor that won | |

Summarise as: *"[N] prior losses. Most recent: [name], lost [date] to [competitor] — reason: [loss reason]."*
Loss history is competitive intelligence — it tells you what objections to pre-empt and whether trust has been damaged.

#### Contacts
For EVERY contact associated with the account (not just the primary contact):

| Field | Extract |
|-------|---------|
| Full name | |
| Title | |
| Department | |
| Email | |
| Phone | |
| Role in deals (Economic Buyer / Champion / Technical / User / Procurement) | |
| Last activity with us (date, type) | |
| Relationship strength / notes | |

Group contacts by role type:
- **Economic Buyers / Sponsors** — titles like VP, SVP, CPO, CFO, COO, CIO
- **Champions / Process Owners** — titles like Director, Manager, Head of
- **Technical Evaluators** — titles like IT Manager, Architect, Systems Lead
- **Procurement / Legal** — titles like Procurement Manager, Legal Counsel
- **Unknown / To Investigate** — any contact where role is unclear

Flag any contacts who appear across multiple opportunities — these are relationship anchors.

#### Activity History
- Last 3–5 interactions logged (date, type, summary)
- Any open tasks or follow-ups outstanding
- Notes from prior discovery or demo sessions

### 2b — Microsoft 365 / SharePoint MCP (if connected)
Search SharePoint for documents related to the account:
- Account briefs, prior discovery notes, past proposals
- Any internal knowledge on this customer

```
Search query: "[account name] discovery" OR "[account name] account brief"
```

### 2c — Web Research
Run targeted searches to ground the questions in the prospect's reality:

```
[account] annual report supply chain trade compliance 2024 2025
[account] import export volume global trade footprint
[account] ERP SAP Oracle systems technology
[account] logistics transport carrier network
[account] [industry] supply chain challenges disruptions tariffs
[account] press releases news M&A regulatory
```

### 2d — Build the Prospect Brief

Summarise all findings in this structure. Confidence-tag every item.
If Salesforce is connected, sections 1–3 should be largely populated before the call.

```
## Prospect Brief — [Account] | [Suite] | [Date]

─────────────────────────────────────────
### 1. Account Overview
─────────────────────────────────────────
Industry:             [X] 🟢/🟡/🔴
Revenue / Size:       [X] 🟢/🟡/🔴
Geography / Regions:  [X] 🟢/🟡/🔴
Account type:         [ ] New Logo  [ ] Existing Customer  [ ] Partner
Customer since:       [X — if existing customer] 🟢/🔴
AE / SC assigned:     [X] 🟢/🔴
Last engagement:      [date + type] 🟢/🔴

─────────────────────────────────────────
### 2. Existing Relationship & Revenue
─────────────────────────────────────────
Products live today:   [X — list modules/products] 🟢/🔴
Current ARR with us:   $[X] 🟢/🔴
Contract end / renewal:[date] 🟢/🔴
Expansion opportunity: [X — what is not yet purchased] 🟡/🔴

─────────────────────────────────────────
### 3. Open Opportunities
─────────────────────────────────────────
[List each open opportunity as one line]
• [Opp Name] | Stage: [X] | Value: $[X] | Close: [date] | Products: [X]
• [Opp Name] | Stage: [X] | Value: $[X] | Close: [date] | Products: [X]

Total open pipeline: $[X] across [N] opportunities 🟢/🔴

Note any overlap or conflict with the current engagement.

─────────────────────────────────────────
### 4. Historical Opportunities
─────────────────────────────────────────
Closed Won:
• [Opp Name] | Closed: [date] | Value: $[X] | Products: [X]

Closed Lost:
• [Opp Name] | Closed: [date] | Value: $[X] | Lost to: [competitor] | Reason: [X]

Pattern / implication: [one sentence on what the history tells you about this account]

─────────────────────────────────────────
### 5. Contacts
─────────────────────────────────────────
Economic Buyers / Sponsors:
• [Name] — [Title] | [email] | Last contact: [date] | 🟢/🟡/🔴

Champions / Process Owners:
• [Name] — [Title] | [email] | Last contact: [date] | 🟢/🟡/🔴

Technical Evaluators:
• [Name] — [Title] | [email] | Last contact: [date] | 🟢/🟡/🔴

Procurement / Legal:
• [Name] — [Title] | [email] | 🟢/🟡/🔴

Unknown / To Investigate:
• [Name] — [Title] | Role unclear — qualify during call

─────────────────────────────────────────
### 6. Context & Intelligence
─────────────────────────────────────────
Current systems (ERP, TMS, WMS, etc.): [X] 🟢/🟡/🔴
Known pains / challenges:               [X] 🟢/🟡/🔴
Compelling event / trigger:             [X] 🟢/🟡/🔴
Competitive landscape:                  [X] 🟢/🟡/🔴
Key news / events (web research):       [X] 🟡/🔴

─────────────────────────────────────────
### 7. Gaps — Must Confirm During Call 🔴
─────────────────────────────────────────
1. [Gap — what is unknown and why it matters]
2. [Gap]
3. [Gap]
```

Confidence tags: 🟢 Confirmed from CRM / prior call | 🟡 Inferred from research | 🔴 Unknown — must ask

---

## Question Selection — What Earns a Slot (applies to Steps 3–5)

A 45-minute call buys roughly **12–15 primary questions** once you allow for rapport,
follow-ups, and a close. Every question below the line is a question you chose over
another one. Apply this filter to everything generated in Steps 3–5:

**A question earns its slot only if it does at least one of these:**
1. Closes a 🔴 gap from the Prospect Brief (Step 2d) — cite which gap
2. Tests a specific research hypothesis — state the hypothesis in the question itself
3. Advances a ${user_config.qualification_framework} letter you cannot get any other way
4. Can only be answered by *this* stakeholder — role-specific insight, not general facts

**Kill tests — cut or demote the question if:**
- Research already answers it → demote to 🟡 Confirm (one line, not a slot)
- Anyone at the account could answer it → move to the pre-call questionnaire or email
- The answer would not change what you demo, propose, or how you qualify → cut it

**Sequence by trust cost.** Cheap questions (role, context, process) come early. Expensive
questions (budget reality, internal politics, personal stakes) only after you have given
something back — an insight from research or an accurate summary of their situation.

**Plan to 60% capacity.** A strong answer deserves a 10-minute detour with the 5 Whys.
The call plan must survive that detour — mark the 3–4 questions you will protect if time
collapses, and treat the rest as optional depth.

---

## Step 3 — Opening Framework

Load: `references/shared/opening-framework.md`
Load: `references/shared/discovery-techniques.md`

Apply the FTD opening methodology. Do NOT jump straight to product-specific questions.
The opening framework applies to every suite — it establishes trust, surfaces the
real business context, and earns the right to ask technical questions.

Generate 5–7 tailored opening questions using the account research from Step 2.
Personalise each question — reference what you found. Never ask generic questions.

**Facilitation note:** Apply the techniques in `discovery-techniques.md` throughout:
active listening signals, use of silence, the 5 Whys for root cause, and empathy
mapping for senior stakeholders. If the prospect requests an early demo, follow the
"Demo in Discovery" guidance — do not skip the discovery process.

---

## Step 4 — Standard Questions

Load: `references/shared/standard-questions.md`
Load: `references/shared/advanced-questions.md`

These questions apply to every suite. Generate adapted versions using account context.
Mark any that can be pre-answered from research as 🟡 Confirm (not Ask).

**Advanced questions:** After the standard baseline is set, select 6–8 questions from
`advanced-questions.md` appropriate to this deal. For a first discovery call, prioritise
sections 01 (Process Diagnostics) and 04 (Decision Risk). For a senior stakeholder or
executive session, prioritise sections 05 (Internal Alignment) and 07 (Strategic Frame).
Never ask all of them — choose what matters most for this specific account and persona.

---

## Step 5 — Suite Questions

Load: `references/suites/{suite}/questions.md`

Generate the full suite-specific question set. For each question:
- If research provides a hypothesis, include it: *"We understand you use SAP — is that still current?"*
- If unknown, ask openly
- Group by section (as defined in the suite file)
- Mark answers already known from research as 🟡 Confirm

### Suite routing

| Suite selected | File to load |
|---------------|-------------|
| GTM | `references/suites/gtm/questions.md` |
| TMS | `references/suites/tms/questions.md` |
| Planning | `references/suites/planning/questions.md` |
| Channel | `references/suites/channel/questions.md` |
| Logistics | `references/suites/logistics/questions.md` |
| Supply Collaboration | `references/suites/supply-collaboration/questions.md` |

If a suite is marked as a stub, tell the user and use only the opening + standard questions.

---

## Step 6 — Output

### Output A — Internal Call Guide (always produce this first)

Format a structured call plan:

```
## Discovery Call Plan — [Account] | [Suite] | [Date]

### 1. Opening (10 min)
[5–7 personalised opening questions from Step 3]

### 2. Company & Team Context (10 min)
[Adapted standard questions from Step 4]

### 3. [Suite Section 1] (15 min)
[Section 1 questions from suite file]

### 4. [Suite Section 2] (15 min)
[Section 2 questions from suite file]

... (continue for all suite sections)

### ${user_config.qualification_framework} Capture (throughout)
Evidence rule: capture what was SAID or OBSERVED, never what you concluded.
"They seemed bought in" is an impression; "she offered to set up the CFO meeting
unprompted" is evidence. 🟢 requires a quote or event with a named source.
M: [what to confirm — target: a number, its source, and who stated it]
E: [economic buyer — who to find; evidence = they engaged, not that they were named]
D: [decision criteria to surface — who wrote them: the customer, or a competitor?]
D: [decision process to map — steps, approvers, dates; "ask Maria" is not a process]
P: [paper process to understand — procurement, legal, security review, and lead times]
I: [implication — pain to quantify; a story about a specific bad day beats an adjective]
C: [champion — status; evidence = something they did for us that we didn't ask for]
C: [competition — who else is in the room, and what the prospect said about them verbatim]

### Close (5 min)
- What are your next steps from your side?
- What would need to be true to progress?
- Who else should we be including?
- Timeline — is there a date driving this?
```

---

### Output B — Pre-Discovery Questionnaire (branded Word document)

Produce when user requests: "pre-discovery questionnaire", "send to client", or "Word doc".

This is a professional document sent to the prospect before the call.
It includes pre-filled context from research and asks the prospect to confirm/complete.

**Generate the Word document using python-docx via UV:**

```python
uv run --with python-docx==1.1.2 python << 'EOF'
from docx import Document
from docx.shared import Pt, Inches, RGBColor, Cm
from docx.enum.text import WD_ALIGN_PARAGRAPH
import os

# === BRAND CONFIGURATION ===
# These values are filled by /cc:setup:configure from cc.config.json (brand.*).
# Until configured they hold the template tokens; the .lstrip("#") keeps them valid
# whether the hex is written with or without a leading '#'.
BRAND = "template"  # set to your brand folder name under skills/brand/brands/

ACCENT_COLOR = RGBColor.from_string("${user_config.accent_color}".lstrip("#") or "0066CC")
TEXT_COLOR   = RGBColor.from_string("${user_config.primary_color}".lstrip("#") or "282828")
HEADING_FONT = "${user_config.font_family}" or "Inter"
BODY_FONT    = "${user_config.font_family}" or "Inter"
LOGO_PATH    = f"${CLAUDE_PLUGIN_ROOT}/skills/pptx-generator/brands/{BRAND}/assets/logo-dark.png"

doc = Document()

# === PAGE SETUP ===
section = doc.sections[0]
section.page_width  = Cm(21)
section.page_height = Cm(29.7)
section.left_margin   = Cm(2.5)
section.right_margin  = Cm(2.5)
section.top_margin    = Cm(2.0)
section.bottom_margin = Cm(2.0)

# === LOGO HEADER ===
header = doc.sections[0].header
hp = header.paragraphs[0]
hp.alignment = WD_ALIGN_PARAGRAPH.LEFT
run = hp.add_run()
if os.path.exists(LOGO_PATH):
    run.add_picture(LOGO_PATH, width=Inches(1.8))

# === TITLE ===
title_para = doc.add_paragraph()
title_para.alignment = WD_ALIGN_PARAGRAPH.LEFT
run = title_para.add_run("DISCOVERY QUESTIONNAIRE")
run.font.name  = HEADING_FONT
run.font.size  = Pt(22)
run.font.bold  = True
run.font.color.rgb = ACCENT_COLOR

# === SUBTITLE ===
sub = doc.add_paragraph()
run = sub.add_run("[ACCOUNT NAME] — [SUITE] Discovery")
run.font.name  = HEADING_FONT
run.font.size  = Pt(13)
run.font.color.rgb = TEXT_COLOR

doc.add_paragraph()

# === MEETING INFO TABLE ===
info_table = doc.add_table(rows=4, cols=2)
info_table.style = "Table Grid"
cells = [
    ("Prospect",     "[Account Name]"),
    ("Date",         "[Meeting Date]"),
    ("Prepared by",  "[SC Name] — ${user_config.company}"),
    ("Purpose",      "Pre-Discovery Questionnaire — [Suite] Solution"),
]
for i, (label, value) in enumerate(cells):
    info_table.rows[i].cells[0].text = label
    info_table.rows[i].cells[1].text = value
    for cell in info_table.rows[i].cells:
        for para in cell.paragraphs:
            for run in para.runs:
                run.font.name = BODY_FONT
                run.font.size = Pt(10)

doc.add_paragraph()

# === INSTRUCTIONS ===
instr = doc.add_paragraph()
run = instr.add_run("Instructions for the prospect")
run.font.name = HEADING_FONT
run.font.size = Pt(11)
run.font.bold = True
run.font.color.rgb = ACCENT_COLOR

doc.add_paragraph(
    "Please complete this questionnaire before our discovery session. "
    "Your answers help us understand your environment and tailor our discussion. "
    "Where we have already noted our understanding, please confirm or correct. "
    "Fields marked * are required."
)

doc.add_paragraph()

# === SECTIONS (replace with generated content) ===
# Each section follows this pattern:
def add_section_heading(doc, title):
    p = doc.add_paragraph()
    run = p.add_run(title.upper())
    run.font.name  = HEADING_FONT
    run.font.size  = Pt(12)
    run.font.bold  = True
    run.font.color.rgb = ACCENT_COLOR
    p.paragraph_format.space_before = Pt(12)
    p.paragraph_format.space_after  = Pt(4)

def add_question(doc, question, pre_filled=""):
    q = doc.add_paragraph()
    run = q.add_run(question)
    run.font.name = BODY_FONT
    run.font.size = Pt(10)
    run.font.bold = True
    if pre_filled:
        pf = doc.add_paragraph()
        run2 = pf.add_run(f"Our understanding: {pre_filled}")
        run2.font.name   = BODY_FONT
        run2.font.size   = Pt(9)
        run2.font.italic = True
        run2.font.color.rgb = RGBColor(0x5C, 0x5B, 0x57)
    ans = doc.add_paragraph()
    run3 = ans.add_run("Answer: ")
    run3.font.name = BODY_FONT
    run3.font.size = Pt(10)
    ans.paragraph_format.space_after = Pt(8)

# SECTION CONTENT GOES HERE — replace with skill-generated questions
add_section_heading(doc, "01 — Company & Team Overview")
add_question(doc, "What is your current ERP system and version?", pre_filled="[Pre-filled from research if known]")
add_question(doc, "How many locations / sites are in scope?")
add_question(doc, "Who are the key stakeholders involved in this project?")

# Add more sections here as generated by the skill

# === FOOTER ===
footer = doc.sections[0].footer
fp = footer.paragraphs[0]
fp.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = fp.add_run("Confidential — prepared by ${user_config.company} for [Account Name] | [Date]")
run.font.name = BODY_FONT
run.font.size = Pt(8)
run.font.color.rgb = RGBColor(0x9A, 0x9A, 0x9A)

# === SAVE ===
os.makedirs("output", exist_ok=True)
doc.save("output/discovery-questionnaire-[account]-[date].docx")
print("Saved: output/discovery-questionnaire-[account]-[date].docx")
EOF
```

**When generating this script for a real document:**
1. Replace `[ACCOUNT NAME]`, `[SUITE]`, `[DATE]`, `[SC NAME]` with actual values
2. Replace the `add_question()` calls with all generated questions from Steps 3–5
3. Pre-fill research findings where available (use 🟡 prefix: *"Our understanding: ..."*)
4. Add all suite sections from the questions file

---

### Output C — Post-Call Summary (branded Word document)

Produce when user requests: "post-call summary", "discovery output", or "findings document".

This is produced after the discovery call using the notes or transcript pasted by the SC.

**Structure the output first as markdown, then generate the Word doc:**

```
## Discovery Summary — [Account] | [Suite] | [Date]

### Critical Business Issue
[One sentence — the top-level business problem with measurable consequence]
Confidence: 🟢/🟡

### Confirmed Pains
| # | Pain | Stated by | Impact metric | Confidence |
|---|------|-----------|---------------|------------|
| 1 | | | | |

### Metrics Captured
| Metric | Value | Source |
|--------|-------|--------|

### Stakeholders Identified
| Name | Title | Role in deal | Sentiment |
|------|-------|-------------|-----------|

### Current Systems
| System type | System name/version | Notes |
|-------------|--------------------|----|

### Decision Process
- Decision criteria: 
- Evaluation process:
- Timeline:
- Paper process / procurement:
- Budget status:

### Next Steps Agreed
| # | Action | Owner | Date |
|---|--------|-------|------|

### Open Questions (🔴 Unknown)
1.
2.
3.

### ${user_config.qualification_framework} Update
| Element | What we learned | Evidence (quote / observed event) | Confidence |
|---------|----------------|-----------------------------------|------------|
| Metrics | | | |
| Economic Buyer | | | |
| Decision Criteria | | | |
| Decision Process | | | |
| Paper Process | | | |
| Implicated Pain | | | |
| Champion | | | |
| Competition | | | |

Confidence discipline: 🟢 only with a verbatim quote or observed event in the Evidence
column (named source). 🟡 = inferred from research or secondhand. No evidence = 🔴, even
if you feel sure. An empty Evidence cell with a 🟢 tag is a checklist failure.
```

Then generate a branded Word document using the same python-docx pattern as Output B,
replacing the questionnaire structure with the summary structure above.

---

## Quality Checklist

- [ ] Research phase ran before questions were generated (no fabricated company facts)
- [ ] Every research finding is confidence-tagged (🟢/🟡/🔴)
- [ ] Every question in the call plan passes the earns-a-slot filter (closes a 🔴 gap, tests a hypothesis, advances qualification, or is role-specific)
- [ ] Every 🟢 ${user_config.qualification_framework} entry has a quote or observed event in the Evidence column
- [ ] Opening questions are personalised to this account and persona — not generic
- [ ] Suite questions are organised by section matching the suite's question file
- [ ] Pre-filled fields in the questionnaire reference actual research findings
- [ ] Word document uses correct brand (${user_config.company})
- [ ] Logo path is valid (use pptx-generator brand assets)
- [ ] Output file saved to `output/` directory
- [ ] All 🔴 Unknown gaps are listed explicitly — these drive the next call

---

## Adding a New Suite

To add a new suite (e.g., Supply Collaboration when the template arrives):
1. Create `${CLAUDE_PLUGIN_ROOT}/skills/discovery/references/suites/<suite-name>/questions.md`
2. Follow the structure of `gtm/questions.md` or `tms/questions.md`
3. Update the suite routing table in Step 5 above
4. Remove the "stub" notice from the questions file
