---
description: Build a discovery call prep sheet — research, hypotheses, question plan
argument-hint: [account] [persona] [product]
---

Build a discovery call prep sheet for:
- Account: $0
- Persona: $1
- Product(s) in scope: $2

If any of these are missing, ask before proceeding.

## Step 1 — Research the account
Run the account-brief command to pull firmographics, trade footprint, and signals for $0.
Confidence-tag every fact.

## Step 2 — Build hypotheses for this persona
Based on the research and the persona ($1), generate 3-5 hypotheses:
- What is this person most likely worried about?
- What metrics do they own?
- What's their relationship to global trade compliance / the product in scope ($2)?
Tag each hypothesis: 🟡 Inferred (mark any 🟢 Confirmed if prior call notes support it).

## Step 3 — Generate the question plan
Run the discovery skill with:
- Account: $0
- Persona: $1
- Product: $2
- Framework: SPIN (default)

## Step 4 — Output the one-page prep sheet

```
DISCOVERY PREP — [Account] | [Persona] | [Date]
Product(s): [list]

KEY RESEARCH FINDINGS (confidence-tagged)
[3-5 bullets]

HYPOTHESES (going into the call)
1. [hypothesis] 🟡 Inferred
2. [hypothesis] 🟡 Inferred

QUESTION PLAN (see discovery skill output)
[Attach or summarise]

${user_config.qualification_framework} CAPTURE TARGETS
What I'm trying to learn today: M / E / D / D / I / Champion

MY OPENING STATEMENT
"Today I want to understand [X]. I'll ask some questions about [Y and Z].
At the end I'll suggest a next step. Sound good?"
```
