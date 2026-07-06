---
name: critical-business-issue-finder
description: |
  Analyses a discovery call summary, meeting notes, or account brief and surfaces the
  Critical Business Issues (CBIs) hiding in the text -- the 2-4 problems that, if unsolved,
  put the business at serious risk -- distinguishing CBIs from symptoms and feature requests.
  Use when you ask "find the CBIs", "what are the critical business issues", "what's the
  real pain here", or "what's driving this deal", or paste notes to find the underlying
  problem.
---

# Critical Business Issue Finder

Reads discovery notes, call summaries, or account briefs and finds the Critical Business Issues
hiding beneath the surface — the problems that, if unsolved, put the business at real risk.

A CBI is NOT a feature request. It is NOT an IT preference.
A CBI is a business-level problem with a measurable consequence if left unsolved.

---

## Connected Tools

| Tool | What it does for you |
|------|---------------------|
| **Salesforce** | Pulls prior call notes and activity history for this account automatically |
| **Confluence** | Reads the account's prior research brief or discovery documentation |

No connections? Paste the notes, call summary, or account brief below.

---

## What is a Critical Business Issue?

```
A CBI passes ALL four of these tests:

✅ It is a business outcome — not a product feature or IT requirement
   ✅ CBI: "We cannot scale our classification process as we enter 8 new markets this year"
   ❌ Not a CBI: "We need a system that integrates with SAP"

✅ It has a measurable consequence if left unsolved
   ✅ CBI: "Classification errors expose us to customs audits and potential duty clawback"
   ❌ Not a CBI: "Manual classification is slow"

✅ Someone senior in the company owns it and will be judged on it
   ✅ CBI: The CCO's bonus is tied to compliance incident rate
   ❌ Not a CBI: The compliance analyst dislikes the current tool

✅ There is a compelling event that makes solving it urgent NOW
   ✅ CBI + event: "CBAM goes live in 12 months and we have no carbon-content tracking process"
   ❌ CBI without urgency: "Someday we should fix our classification approach"
```

---

## Step 1 — Paste the source material

Paste any of:
- Raw discovery call notes
- Structured call summary (from meeting-notes-structurer)
- Account brief (from /cc:account:brief)
- Prior emails or Salesforce notes
- Any combination

The more context the better. Don't edit it first.

---

## Step 2 — CBI extraction

The skill reads the material and extracts 2–4 CBIs using this structure:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CRITICAL BUSINESS ISSUE #[N]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The issue (in business language, not product language):
[What is the problem at a business level — what will go wrong if this isn't solved?]

Evidence from the notes:
[The exact quotes or observations that point to this CBI]
Confidence: 🟢 Customer stated / 🟡 Inferred from context

Who owns this problem (or who should):
[Title / role — who in the organisation is accountable for this outcome]

The consequence of not solving it:
[What happens in 12–24 months if they do nothing — measurable if possible]

The compelling event that makes it urgent NOW:
[Regulatory deadline / business expansion / audit / leadership change / competitive pressure]
Confidence: 🟢 Confirmed / 🟡 Inferred / 🔴 Unknown

How ${user_config.company} addresses it:
[Which product and which specific capability connects directly to this CBI]
Value anchor: [Benchmark metric — tag 🟡 Inferred until confirmed with this customer]

Gap: what we still need to confirm:
[The question to ask in the next call to fully validate this CBI]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Step 3 — CBI prioritisation

After extracting the CBIs, rank them:

| CBI | Urgency (1–5) | Business impact (1–5) | Our ability to solve it (1–5) | Priority |
|-----|--------------|----------------------|-------------------------------|----------|
| [CBI 1] | | | | |
| [CBI 2] | | | | |
| [CBI 3] | | | | |

**Lead with the highest-priority CBI in every conversation.**
The CBI the customer ranks highest should anchor the demo, the business case, and the executive summary.

---

## Step 4 — Things that are NOT CBIs (but came up in the notes)

It is just as important to name what is NOT a CBI, so the team doesn't build a
discovery or demo narrative around symptoms, IT preferences, or feature requests.

```
NOT A CBI — These came up but are symptoms or preferences, not business issues:

• [Item] — This is a [symptom / feature request / IT preference] because: [reason]
  What to do with it: [Use it as evidence for CBI #X / Deprioritise / Ask what business problem it causes]

• [Item] — [Same structure]
```

---

## Step 5 — Discovery gaps to fill

For each CBI that is 🟡 Inferred or missing a compelling event, list the specific question
to ask in the next customer interaction:

```
DISCOVERY GAPS

CBI #[N]: [Short name]
Question to ask: "[Exact question — open-ended, not leading]"
Who to ask: [The right person in the customer's organisation]
When to ask: [Next call / EB meeting / technical session]
```

---

## Quality checklist

- [ ] Each CBI passes all four tests (business outcome / measurable consequence / senior owner / compelling event)
- [ ] CBIs are stated in the customer's business language — not our product names
- [ ] Symptoms and feature requests are explicitly separated from CBIs
- [ ] Each CBI has a confidence tag — no inflated 🟢 without real evidence
- [ ] Discovery gaps are named — specific questions to fill the unknowns
- [ ] CBIs are ranked so the team knows which one to lead with
