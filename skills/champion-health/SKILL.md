---
name: champion-health
description: |
  Diagnoses the real strength of your champion in a live deal -- separates friendly contacts
  from genuine internal advocates actively selling for you, and flags at-risk champions
  before they go quiet at the worst moment.
  Use when you ask "how strong is my champion", "is my champion real", "champion health
  check", or "do I have a real champion", or want a champion risk assessment.
---

# Champion Health Diagnostic

Diagnoses whether your champion is an active internal advocate or just a friendly contact.
Run this mid-deal when you're uncertain, before committing SC resources to a PoC, or when a deal that should be progressing has gone quiet.

---

## Connected Tools

| Tool | What it does for you |
|------|---------------------|
| **Salesforce** | Pulls champion contact record, activity log, and opportunity history automatically |
| **Confluence** | Saves the assessment to the deal folder for the full account team |

No connections? Fill in the context below manually.

---

## Step 1 — Champion context

Tell the skill:
1. **Champion's name, title, and department**
2. **How long have you known them?** — first contact date
3. **How did the relationship start?** — inbound, outbound, referral, event
4. **What have they done for us in this deal?** — be specific, not vague ("they're engaged")
5. **Do they have access to the economic buyer?** — same direct line, indirect, or no visibility
6. **Have they introduced you to other stakeholders?** — who and when
7. **What is their personal stake in this project succeeding?** — what do they gain if it works?
8. **What risk do they face if they back the wrong vendor?**

---

## Step 2 — Behaviour evidence scan

The most important signals are what your champion DOES, not what they say. Mark what you have observed.

| Behaviour | Observed? | When / evidence |
|-----------|-----------|-----------------|
| Introduced us to the economic buyer | Yes / No / Tried | |
| Proactively shared internal politics or roadblocks | Yes / No | |
| Gave us access to their internal presentation or business case | Yes / No | |
| Told us what the competition is doing inside the account | Yes / No | |
| Asked for materials to share internally — not just for themselves | Yes / No | |
| Pushed to accelerate the timeline on their own initiative | Yes / No | |
| Defended us when we weren't in the room (any evidence?) | Yes / No / Unknown | |
| Responded quickly when you needed something | Yes / Slow / No pattern | |
| Their engagement has INCREASED as the deal has progressed | Yes / Flat / Declining | |

---

## Step 3 — Champion strength score

Score each dimension 1–5.

| Dimension | Score (1–5) | Evidence |
|-----------|-------------|---------|
| **Access to power** — can they reach the EB without you? | | |
| **Internal credibility** — do others in their org listen to them on this topic? | | |
| **Motivated to act** — do they have personal stakes in this project? | | |
| **Actively selling** — are they advocating for us when we're not in the room? | | |
| **Informed** — do they understand our value prop well enough to represent it? | | |
| **TOTAL** | **/25** | |

**Thresholds:**
- **20–25**: Strong champion. Invest. Keep enabling.
- **13–19**: Developing champion. Needs coaching and better materials.
- **8–12**: Weak champion. Find a second champion or escalate the relationship.
- **< 8**: This is a contact, not a champion. Do not treat this as a championed deal.

---

## Step 4 — Red flag check

```
CHAMPION RED FLAGS

[ ] They've never introduced us to anyone else in the account
[ ] They always say "I'll pass this along" — never direct access to the EB
[ ] Engagement drops when budget or timeline conversations come up
[ ] They can't or won't tell us who makes the final decision
[ ] They've asked for pricing but no one above them has been engaged
[ ] Their enthusiasm is high but no visible internal progress has happened
[ ] They've missed or cancelled meetings in the last 4 weeks without explanation
[ ] The project has stalled and they haven't flagged why
[ ] Another vendor has been seen internally and they didn't tell us

Red flags found: [list]
```

---

## Step 5 — Champion development actions

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CHAMPION HEALTH DIAGNOSTIC — [Name] | [Account] | [Deal]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Champion: [Name, Title]
Score: [X]/25 — Strong / Developing / Weak / Contact-only
Key behaviour evidence: [2–3 specific things observed]
Critical gaps: [What a real champion would do that this person hasn't]

Assessment: [2–3 honest sentences on the champion's real strength]

RECOMMENDED ACTIONS:

If strong:
  [How to keep enabling — what materials they need, which meeting to get them into]

If developing:
  [Specific coaching to give them + what internal selling materials to provide]

If weak:
  [How to find a second champion + what to test in the next discovery call]

If contact-only:
  [Escalation path — how to reframe the relationship or go above]

Next action: [One specific thing — with a date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Run `/cc:deal:champion-enable` to build the internal selling kit for a confirmed champion.

---

## Quality checklist

- [ ] Score is based on OBSERVED BEHAVIOUR — not how much you like this person
- [ ] At least one red flag was checked if the score is below 15
- [ ] "Next action" is specific and has a date attached
- [ ] If score is below 13: AE is aware and a plan exists to find a second champion
