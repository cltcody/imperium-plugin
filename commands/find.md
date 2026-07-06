---
description: >
  Find the right cc command or skill from a plain-language description of what you want to do.
  Use when the user asks "what should I use for…", "which command/skill does X", "how do I …
  with cc", "is there a tool for…", "what's the command to…", "help me find the right tool",
  or simply describes a goal without naming a command. Routes across dev, sales, life, and
  setup, and hands off to /cc:guide (sales depth) or /cc:next (dev cycle) when those fit better.
argument-hint: "[describe what you want to do, in plain words]"
---

# Find: What Should I Use?

A natural-language concierge for the toolkit. Take a plain-language description of what the
user is trying to do and route them to the best cc command(s) or skill(s) across the **whole**
toolkit — dev, sales, life, setup, and one-off skills. Be fast and decisive: at most one
clarifying question, then a clear recommendation.

## Steps

### 1 — Load the live catalogue

Read `INVENTORY.md` (the authoritative, current list of every command and skill) and
`CHEATSHEET.md` (the situational "doing X → use Y" map) from the plugin root. **Never route
from memory** — the catalogue changes as skills are added.

### 2 — Understand the request

Use `$ARGUMENTS` as the user's stated goal.
- If it's clear enough to route, do so directly — don't make them answer questions.
- If it's empty or too vague, ask **one** diagnostic question:
  *"What are you trying to do right now?"* with a few buckets to pick from or free-text:
  building/shipping code · a sales or deal task · a personal decision (money, home, health,
  family) · setting up or maintaining the toolkit.

Classify the intent into a domain: **Dev · Sales · Life · Setup/Maintenance · Skill (one-off
helper)**.

### 3 — Match

Pick the best **1–3** options, top pick first. Prefer a single confident recommendation;
offer alternatives only when the request is genuinely ambiguous. Use the `CHEATSHEET.md`
mappings as the primary guide and `INVENTORY.md` descriptions as the fallback.

Hand off rather than duplicate when a specialist router fits better:
- A nuanced **sales** situation routed by deal stage → point to **`/cc:guide`**.
- *"Where am I / what's next"* in a **dev cycle** → point to **`/cc:next`**.

### 4 — Present the recommendation

For each option, give three things, tightly:
- **How to trigger** — the exact `/cc:group:name`, or for a skill, the phrase to say.
- **What you'll get** — one sentence.
- **Before / after** — what to run first or next, if it's part of a chain.

Lead with the single best pick and a one-line *why*. Don't dump the whole catalogue.

### 5 — Offer to run it

Offer to launch the top recommendation now (invoke it via the SlashCommand tool, or run the
skill). If the user confirms, proceed straight into it.

## Intent → route (examples)

| The user says… | Route to |
|----------------|----------|
| "I need to add a feature" | `/cc:plan:feature` → `/cc:implement:execute` → `/cc:verify:run` |
| "a test is failing" / "this error" | `/cc:verify:debug` |
| "review my branch before I merge" | `/cc:verify:pr` |
| "fix this GitHub issue" | `/cc:github:fix` (or `/cc:github:issue` end-to-end) |
| "is it safe to deploy?" | `/cc:release:deploy` |
| "prep for a customer call" | `/cc:discovery:prep` (or `/cc:guide` for full sales routing) |
| "build a demo" | `/cc:demo:storyboard` |
| "handle this objection" | `tactical-empathy-coach` skill |
| "should I buy this / is it worth it" | `/cc:life:big-purchase-council` |
| "help me decide" / "I'm torn between" (money, home, health, family, or anything else) | `/cc:life:council` (or the dedicated `finance-council` / `home-council` / `health-council` / `family-council` if the domain is clear) |
| "audit my subscriptions" / "where can I cut costs" | `/cc:life:subscriptions-audit` |
| "set up my company branding" | `/cc:setup:configure` → `/cc:setup:brand` |
| "make cc work in my Django/Next.js project" | `/cc:setup:stack` |
| "I don't know where I am" | `/cc:next` (dev) or `/cc:guide` (sales) |

## Notes

This is the **universal front door**. Relationship to the other routers:
- `/cc:find` — describe anything in plain words; routes across the whole toolkit *(this command)*
- `/cc:guide` — the deep, interactive **sales** router (by deal stage)
- `/cc:next` — the **dev** cycle diagnostic (plan → implement → verify → release)
- `CHEATSHEET.md` — the static at-a-glance map
