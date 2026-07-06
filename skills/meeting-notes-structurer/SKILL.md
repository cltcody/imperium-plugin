---
name: meeting-notes-structurer
description: |
  Takes raw, messy notes from any customer meeting and structures them into a clean
  action-oriented summary -- ${user_config.qualification_framework} updates, agreed next steps, red
  flags, and a follow-up email ready to send. Pushes updates to Salesforce automatically
  when connected.
  Use when you say "structure these notes", "turn my notes into a summary", "what are the
  action items", or "clean up these notes", or paste raw call notes.
---

# Meeting Notes Structurer

Turns raw, messy call notes into a clean, action-ready summary with ${user_config.qualification_framework} updates
and a follow-up email. Just paste what you have — the messier the better.

---

## Connected Tools

| Tool | What it does for you |
|------|---------------------|
| **Salesforce** | Updates the opportunity record with key findings and ${user_config.qualification_framework} changes automatically |
| **Confluence** | Saves the structured summary to your team's deal folder |

No connections? Paste the notes and copy the output wherever you need it.

---

## Step 1 — Paste your raw notes

Just paste everything as-is. Bullet points, half-sentences, timestamps, shorthand.
Do NOT clean them up first — the skill works better with raw, unfiltered notes.

If you have a meeting transcript or recording summary, paste that too.

Tell the skill:
- What type of meeting was this? (Discovery / Demo / Technical review / Commercial / Other)
- Who was in the meeting? (Names + titles if you know them)
- What products or topics were discussed?

---

## Step 2 — Structured summary output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MEETING SUMMARY
Account:      [Name]
Date:         [Date]
Meeting type: [Discovery / Demo / Technical / Commercial / Other]
Attendees:    [Names + titles]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHAT WE LEARNED — Key findings from this call
• [Most important insight — in the customer's own words if possible]
• [Second most important]
• [Third]

CONFIRMED PAINS — What they told us hurts
• [Pain 1] — 🟢 Customer stated directly
• [Pain 2] — 🟢 Customer stated / 🟡 Inferred from context
• [Pain 3] — 🟡 Inferred

WHAT RESONATED AND WHAT DIDN'T
Resonated:       [What they reacted positively to]
Questions raised: [What they pushed back on or asked more about]
Flat:            [Anything that didn't land — be honest]

${user_config.qualification_framework} — What changed this call
(Only fill in what was new information — leave the rest blank)

  Metrics (did we get any numbers?):       [New info or "no change"]
  Economic Buyer (do we know who signs?):  [New info or "no change"]
  Decision Criteria (how are they deciding?): [New info or "no change"]
  Decision Process (what are the steps?):  [New info or "no change"]
  Paper Process (procurement/legal path?): [New info or "no change"]
  Implicate Pain (do they feel the cost of waiting?): [New info or "no change"]
  Champion (who will sell internally for us?): [New info or "no change"]
  Competition (who else are they evaluating?): [New info or "no change"]

AGREED NEXT STEPS
  [Action] — Owner: [Name] — By: [Date]
  [Action] — Owner: [Name] — By: [Date]
  [Action] — Owner: [Name] — By: [Date]

RED FLAGS — Things to watch
• [Anything that concerned you — a qualification gap, competitor mention, lukewarm reaction,
  a stakeholder who went quiet, a timeline that doesn't add up]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FOLLOW-UP EMAIL (ready to send)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Subject: [Account] × ${user_config.company} — [Date] recap + next steps

Hi [Name],

[3–5 sentence recap using the field-comms-writer structure]
[Agreed actions table]
[Next step sentence]

[Your name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Quality checklist

- [ ] Key findings are in the customer's words where possible — not interpreted or spun
- [ ] ${user_config.qualification_framework} gaps are explicitly named ("Unknown" is an honest and useful answer)
- [ ] Next steps have owners AND dates — not just "we'll follow up"
- [ ] Red flags are named — don't bury concerns in a positive-sounding summary
- [ ] Follow-up email is ready to send without rewriting
- [ ] If Salesforce is connected: push ${user_config.qualification_framework} updates to the opportunity record
- [ ] If Confluence is connected: save to the deal folder
