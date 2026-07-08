---
name: field-comms-writer
description: |
  Writes standalone customer-facing emails and Slack messages — chasers, confirmations, executive
  outreach, follow-ups; pulls Salesforce context when connected. Use on "write a follow-up email"
  or "draft an email to [customer]"; to structure raw meeting notes use
  `meeting-notes-structurer`.
---

# Field Comms Writer

Writes professional, specific follow-up emails and field communications after any customer
interaction. No clichés, no waffle — every line earns its place.

---

## Connected Tools

These make the skill faster — but it works just as well without them.
Just paste the context and the skill does the rest.

| Tool | What it does for you |
|------|---------------------|
| **Salesforce** | Pulls the account name, key contacts, and deal stage automatically — no copy-pasting |
| **Confluence** | Saves a copy of the email to your team's deal folder |

---

## Step 1 — Pick the communication type

Choose one:
- **Post-call recap** — after a discovery call or qualification call
- **Post-demo follow-up** — after showing the product (use `/cc:demo:post-followup` for full version)
- **Next-step confirmation** — locking in agreed actions after any meeting
- **Chaser / nudge** — when a prospect has gone quiet (use sparingly — max 2 follow-ups)
- **Meeting confirmation** — confirming an upcoming session
- **Executive outreach** — first contact with a new senior stakeholder
- **Internal field note** — for your own team (AE, manager, CSM)

---

## Step 2 — Tell the skill what happened

You don't need to write a full brief. Just paste:
1. **Who is the email to?** — Name, title, company
2. **What just happened?** — A few sentences about the call/demo
3. **What were the 2–3 key things discussed?** — Their pains, reactions, questions
4. **What did everyone agree to do next?** — Actions, owners, dates
5. **What do you want them to do after reading?** — Reply to confirm a date / share internally / take an action
6. **Tone**: Formal (C-suite) / Standard (senior manager) / Direct (day-to-day contact)
7. **Length**: Short (5–7 lines) / Standard / Detailed (full recap with table)

If Salesforce is connected: the skill will pull account name, primary contact, and opportunity stage automatically.

---

## Step 3 — The email is drafted using this structure

### Post-call recap

```
Subject: [Account] × ${user_config.company} — [Date] call recap + next steps

Hi [Name],

Thanks for the time today — quick recap of what we covered and where we go next.

What we discussed:
• [Key point 1 — use their exact words where possible]
• [Key point 2]
• [Key point 3 if relevant]

What we agreed:
  [Action 1] — [Owner] — by [Date]
  [Action 2] — [Owner] — by [Date]

[One sentence on what comes next — the next meeting, the next decision, the next milestone.]

Let me know if I've missed anything or if you'd adjust anything above.

[Your name]
```

### Executive outreach (first contact with a new senior stakeholder)

```
Subject: [Specific to their world — not "${user_config.company} introduction"]

Hi [Name],

[One sentence on why you're reaching out — a specific trigger: new regulation,
audit risk, a peer company result, or a business event you noticed.]

[One sentence on what ${user_config.company} addresses in this specific area.]

[One sentence on why it's relevant to [Company] specifically — show you've done your homework.]

Worth a 20-minute conversation to see if there's a fit?

[Your name]
[Title] | ${user_config.company} Industry Solutions
```

### Chaser / nudge (use sparingly)

```
Subject: Re: [Account] × ${user_config.company} — [original topic]

Hi [Name],

Just circling back on the above — happy to adjust timing or scope if priorities have shifted.

Is [original next step] still on track, or would it help to reschedule?

[Your name]
```

---

## Quality checklist before sending

- [ ] Subject line is specific — includes account name and topic (not "Follow up" or "Checking in")
- [ ] First line is NOT "Hope you're well" or "I'm just following up on our call"
- [ ] Every bullet is specific to this customer — nothing generic
- [ ] Next steps name an action, an owner, and a date
- [ ] Length matches the relationship — shorter for senior leaders
- [ ] No internal jargon the customer wouldn't use
- [ ] Value claims are confidence-tagged if included (🟢 Confirmed / 🟡 Inferred)
- [ ] If Confluence is connected: copy saved to the deal folder
