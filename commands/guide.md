---
description: Interactive router — find the right skill or command for your situation, or browse the full phase map
argument-hint: [optional: a phase name "discovery" / "demo" / "closing", or "list" for the full reference]
---

## Step 1 — Load the live inventory

Before doing anything else, read `INVENTORY.md` in the project root.
This is the authoritative, always-up-to-date list of every skill and command.
Never rely on memory — the inventory changes as skills are added.

Also read `CLAUDE.md` if you need to understand trigger phrases or command syntax.

---

## Step 2 — Decide the mode

**If $ARGUMENTS contains a phase name** (e.g. "discovery", "demo", "negotiation", "closing", "rfp"):
→ Skip to Step 4 — zoom directly into that phase.

**If $ARGUMENTS is "list"**:
→ Skip to Step 4 — print the full phase-by-phase reference.

**If $ARGUMENTS is empty** (most common):
→ Continue to Step 3 — run the interactive router.

---

## Step 3 — Interactive router

You are helping a ${user_config.company} / ${user_config.company} presales SC find the right tool for what they're working on right now.
Do not list every skill — route them to the best 1–3 options for their specific situation.

Ask ONE diagnostic question. Use this decision tree:

```
Ask: "What are you working on right now?"

Present these options (numbered — user picks one or describes freely):

  1. Preparing for an upcoming call or meeting
  2. In the middle of a deal — need to move it forward
  3. Writing something (email, proposal, exec summary, document)
  4. Handling an objection, pushback, or a stuck deal
  5. Responding to an RFP / RFI / tender
  6. Planning or running a demo
  7. Wrapping up a deal — handover to delivery
  8. Something else — I'll describe it
```

**Based on their answer, follow this routing logic:**

### Option 1 — Preparing for a call or meeting
Ask: "What kind of call?"
- First call with a new account → `/cc:account:brief` + `/cc:discovery:qualify`
- Discovery call → `/cc:discovery:prep` + `discovery` skill
- Technical deep-dive → `/cc:discovery:ftq` + `discovery` skill
- C-suite or exec meeting → `exec-briefing-prep` skill
- Demo session → `/cc:demo:storyboard` + `/cc:demo:pre-invite`
- Negotiation / commercial discussion → `negotiation-prep` skill + `/cc:deal:objection-drill`
- Post-call — need to capture and follow up → `/cc:discovery:golden-hours`

### Option 2 — Moving a deal forward
Ask: "Where is the deal stuck or what's the next milestone?"
- Need to qualify or re-qualify → `/cc:discovery:qualify` + `/cc:discovery:ftq`
- Champion is weak or unclear → `champion-health` skill
- Need to build the value case → `/cc:value:pain-to-value` + `/cc:value:roi-case`
- Deal is complex, stalled, or conflicted → `/cc:deal:strategic-think`
- CFO or finance pushing back on the numbers → `business-case-stress-tester` skill
- PoC is running — need a health check → `presales-coach` skill ("is the PoC on track")
- OSD or scoping phase → `osd-architect` skill + `/cc:handover:osd-draft`

### Option 3 — Writing something
Ask: "What are you writing?"
- Follow-up email or recap → `field-comms-writer` skill
- Proposal → `/cc:deal:proposal`
- Executive summary → `/cc:deal:exec-summary`
- Handover document → `/cc:handover:doc`
- Word document (any) → `docx-generator` skill
- Slide deck or PPTX → `pptx-generator` skill
- LinkedIn post → `linkedin-post` skill
- Then ask: "Before it goes to the customer — run `confidence-tagger` to tag every unverified claim."

### Option 4 — Objection, pushback, or stuck deal
- Specific objection in a conversation → `tactical-empathy-coach` skill
- Preparing for a tough negotiation → `negotiation-prep` skill + `/cc:deal:objection-drill`
- Deal fundamentally stalled → `/cc:deal:strategic-think`
- Champion not advocating internally → `champion-health` skill + `/cc:deal:champion-enable`

### Option 5 — RFP / RFI / tender
- Just received it, not sure whether to bid → `rfx-navigator` skill (say "we got an RFP")
- BID decision confirmed, need to respond → `/cc:rfp:analyze` → `/cc:rfp:respond`
- Need the presentation deck → `/cc:rfp:present`
- Before submission → `confidence-tagger` skill

### Option 6 — Demo
- Planning a new demo → `/cc:demo:storyboard`
- Need a full word-for-word script → `/cc:demo:script`
- Dry-run and coaching → `demo-dryrun-coach` skill
- Creating a recorded video → `video-demo-creator` skill
- Invite email for attendees → `/cc:demo:pre-invite`
- Follow-up after the demo → `/cc:demo:post-followup`

### Option 7 — Wrapping up / handover
- Handover to professional services → `/cc:handover:doc`
- Solution design (OSD) → `/cc:handover:osd-draft`
- Deal debrief (win or loss) → `win-loss-analyzer` skill
- Internal post-deal write-up → `field-comms-writer` skill

### Option 8 — Free text
Listen carefully to what they describe, then match to the best skill or command from INVENTORY.md.
Always explain WHY you're recommending it in one sentence.

---

**After routing, always:**
1. Name the specific command or skill trigger phrase
2. Say what they'll get from it in one sentence
3. If relevant, suggest what to run before or after

---

## Step 4 — Full phase reference (fallback / browse mode)

Use this when the user wants to browse, or when `/cc:guide [phase]` or `/cc:guide list` is called.
If a specific phase was requested, show only that phase in full detail with one worked example per command.
If "list" was requested, print the complete phase map below.

---

### New here? Start with these 5.

These cover 80% of daily presales work.

| Tool | When | How to trigger |
|------|------|----------------|
| **Account Brief** | Before any first call | `/cc:account:brief [company name]` |
| **Discovery Prep** | Night before a discovery call | `/cc:discovery:prep [account] [persona] [product]` |
| **Meeting Notes** | After every call | Say *"structure these notes"* then paste your notes |
| **Demo Storyboard** | Before every demo | `/cc:demo:storyboard [product]` + paste pains |
| **Confidence Tagger** | Before anything goes to the customer | Say *"tag this"* then paste the document |

---

### Phase map

| # | Phase | When you're here | Go-to tools |
|---|-------|-----------------|-------------|
| 1 | Prospecting | Researching before outreach | `account:brief` |
| 2 | Initial Contact | First call with a lead | `account:brief` · `account:champion` · `account:map` |
| 3 | Qualification | Is this a real opportunity? | `discovery:qualify` · `discovery:ftq` · `discovery:prep` |
| 4 | Technical Discovery | Deep-dive into needs and stack | `discovery:questions` · `discovery:summary` · `discovery:golden-hours` · `discovery` skill |
| 5 | Demo | Showing the product | `demo:storyboard` · `demo:script` · `demo:pre-invite` |
| 6 | Ballpark Pricing | First value and pricing signals | `value:roi-case` · `value:pain-to-value` · `confidence-tagger` |
| 7 | Service Discovery / OSD | Scoping delivery | `value:wosr` · `handover:osd-draft` · `deal:poc-plan` · `osd-architect` |
| 8 | Proposal | Formal value case | `value:roi-case` · `deal:exec-summary` · `business-case-stress-tester` |
| 8b | RFP / RFI | Responding to a tender | `rfp:analyze` · `rfp:respond` · `rfp:present` · `rfx-navigator` |
| 9 | Negotiation | Objections and pushback | `deal:objection-drill` · `deal:strategic-think` · `tactical-empathy-coach` |
| 10 | Closing | Final alignment and sign-off | `handover:doc` · `deal:exec-summary` · `confidence-tagger` |
| 11 | Onboarding | Handing over to delivery | `handover:doc` |
| ⚡ | Any phase | Stuck, conflicted, or complex | `deal:strategic-think` |

---

### Skills available at any phase

Skills activate by natural language — no `/` needed. Just say the trigger phrase.

| Skill | Trigger phrases |
|-------|----------------|
| `confidence-tagger` | "tag this", "add confidence tags", "quality check this" |
| `tactical-empathy-coach` | "hard conversation", "objection coaching", "they pushed back on…" |
| `champion-health` | "how strong is my champion", "champion health check", "is my champion real" |
| `business-case-stress-tester` | "stress test this business case", "CFO prep", "challenge the ROI" |
| `exec-briefing-prep` | "exec briefing prep", "C-suite meeting prep", "briefing the CFO" |
| `integration-complexity` | "assess the integration complexity", "tech stack assessment" |
| `presales-coach` | "I'm stuck on a deal", "what's my next move", "is the PoC on track", "coach me" |
| `rfx-navigator` | "we got an RFP", "should we bid", "bid or no bid" |
| `video-demo-creator` | "create a demo video", "demo video script", "help me record a demo" |
| `supply-chain-map` | "map the supply chain", "supply chain for [company]" |
| `win-loss-analyzer` | "debrief this win", "why did we lose", "deal debrief" |
| `negotiation-prep` | "negotiation prep", "they're pushing on price" |
| `field-comms-writer` | "write a follow-up email", "post-call email", "draft a recap" |
| `meeting-notes-structurer` | "structure these notes", "meeting summary", "action items from this call" |
| `competitive-battlecard` | "how do we beat [Competitor]", "battlecard for [Competitor]" |
| `critical-business-issue-finder` | "find the CBIs", "what's the real pain", "critical business issue" |
| `demo-dryrun-coach` | "dry run my demo", "demo rehearsal", "check my demo" |
| `demo-storyboard` | "demo prep", "storyboard", "build a demo flow", "Tell-Show-Tell" |
| `osd-architect` | "plan the OSD", "structure the OSD" |
| `pricing-positioning` | "pricing conversation", "value before price", "how to position our price" |
| `linkedin-post` | "write a LinkedIn post", "turn this into a post" |
| `diagram` | "diagram this", "visualise", "draw a flow" |
| `pptx-generator` | "generate a deck", "create slides" |
| `docx-generator` | "generate a word doc", "create a word document", "branded document" |

> **Note:** This skill list is generated from INVENTORY.md — it reflects the current inventory.
> When a new skill is added to INVENTORY.md, it automatically appears here next time `/cc:guide` runs.

---

### Always-available utilities

| Command | When | Purpose |
|---------|------|---------|
| `/cc:deal:strategic-think` | Any phase — stuck or complex | TOC + BBiT root-cause thinking |

---

### Quick tips

- **Tag before you send** — `confidence-tagger` on anything customer-facing.
- **Stuck on a deal?** `/cc:deal:strategic-think` — describe the situation plainly.
- **After discovery, act within 24h** — `/cc:discovery:golden-hours` before the momentum fades.
- **Zoom into a phase** — `/cc:guide demo` or `/cc:guide negotiation`.
- **See everything** — `/cc:guide list` prints the full reference.
