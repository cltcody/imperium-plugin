---
name: win-loss-analyzer
description: |
  Structured win/loss debrief on any closed deal — the real reason for the decision, what to
  repeat or change, competitive intel; works for wins, losses, no-decisions, with Salesforce
  history. Use on "debrief this win", "why did we lose", or "post-mortem on this deal".
---

# Win/Loss Analyzer

Structured debrief on any closed deal — win, loss, or no-decision.
Finds the real reason the customer decided the way they did, not just the official version.

---

## Connected Tools

| Tool | What it does for you |
|------|---------------------|
| **Salesforce** | Pulls full deal history, stage progression, activity log, and close data automatically |
| **Confluence** | Saves the debrief to your team's win/loss library so others can learn from it |

No connections? Fill in the deal context below.

---

## Step 1 — Give the skill the deal context

Tell the skill:
1. **Account name and approximate deal size**
2. **Products that were evaluated**
3. **Outcome**: Win / Loss / No decision / Still evaluating
4. **If a loss**: Who won? (Competitor name / build internally / no budget / no decision)
5. **How long was the deal?** — from first contact to close
6. **Key people from the customer side** — who participated in the evaluation
7. **What did the customer tell you about their decision?** (Their stated reason)
8. **What do you ACTUALLY think happened?** — your honest gut read

If Salesforce is connected: the skill will pull the full deal timeline and activity history automatically.

---

## Step 2 — The real decision moment

The deal was decided at a specific moment — rarely on the day they signed or declined.

```
THE DECISION MOMENT

When did it actually happen?
[Not the close date — the moment the customer's mind was made up.
 It could be after a specific demo module, a pricing conversation, a stakeholder meeting you weren't in.]

What was the context at that point?
[Deal stage, who was involved, what had just happened]

What did the customer do or say that signalled it?
[A reaction, a question that changed tone, a stakeholder who went quiet, a delay that started]

If you could go back and change one thing at that moment — what would it be?
[One specific thing — not a list]
```

---

## Step 3 — ${user_config.qualification_framework} debrief

How well did we execute against each element? Score 1–5 (1 = didn't happen, 5 = fully done).

| Element | What we actually did | Score | What we should have done differently |
|---------|---------------------|-------|--------------------------------------|
| **Metrics** — did we put a number on the value? | | 1–5 | |
| **Economic Buyer** — did we get to the person who signs? | | 1–5 | |
| **Decision Criteria** — did we know and shape what they were evaluating us on? | | 1–5 | |
| **Decision Process** — did we know the steps and who was involved? | | 1–5 | |
| **Paper Process** — were we ready for procurement and legal? | | 1–5 | |
| **Implicate Pain** — did they feel what staying the same would cost them? | | 1–5 | |
| **Champion** — did we have one? Did we enable them to sell internally? | | 1–5 | |
| **Competition** — did we know who was in the deal and manage it? | | 1–5 | |

**Total score: /40**
A well-qualified deal in Commit should be 28/40 or higher.

---

## Step 4 — What we did right

Even in a loss, something worked. Name it — it's how you repeat it.

```
WHAT WORKED

1. [Specific thing we did well — concrete, not vague like "good relationship"]
2. [Specific thing we did well]
3. [Specific thing we did well]
```

---

## Step 5 — What to change next time

Maximum 3 things. If you list 10, nothing will change.

```
WHAT TO DO DIFFERENTLY — TOP 3

1. [Specific, actionable change]
   When to apply it: [The type of deal or moment where this matters]

2. [Specific, actionable change]
   When to apply it: [...]

3. [Specific, actionable change]
   When to apply it: [...]
```

---

## Step 6 — Competitive intelligence (if a competitor was involved)

```
COMPETITIVE LEARNINGS — [Competitor name]

What they showed that we weren't aware of:
[Any new capabilities, demo moments, or claims we hadn't prepared for]

Their pricing approach (if the customer shared it):
[Pricing model, discount level, commercial structure]

Their weaknesses — what the customer mentioned:
[Anything they said the competitor struggled with or where they had doubts]

New discovery questions to add when we face them next:
[Questions that would have helped us in this deal]
```

---

## Output summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DEAL DEBRIEF — [Account] | [Win / Loss / No decision]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Decision moment: [When and what happened]
Real reason for the decision: [Your honest read — not the official story]
${user_config.qualification_framework} execution score: [X]/40
Top 3 changes for next time: [Listed]
Competitive learnings: [If a competitor was involved]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Quality checklist

- [ ] You've named the REAL reason — not the polite version the customer gave you
- [ ] ${user_config.qualification_framework} scores are honest — 2s where we didn't execute, not inflated to 4s
- [ ] "What to change" has a maximum of 3 items — specific, not vague
- [ ] Competitive learnings are documented for the whole team, not just for you
- [ ] If Salesforce is connected: update the close reason and competitor fields
- [ ] If Confluence is connected: save to the team win/loss library
