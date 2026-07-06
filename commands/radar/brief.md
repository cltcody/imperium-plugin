---
description: Turn a trade-regulatory change into an account-facing shortlist with outreach angles. Use when the ask is "which accounts does this tariff/sanctions change matter to" or you're handed a /cc:radar:scan digest entry
argument-hint: [digest entry or pasted regulatory-change text]
disable-model-invocation: true
---

# Radar: Brief

Presales-facing follow-through on a regulatory-radar change: given one change (a
`/cc:radar:scan` digest entry, or text pasted directly) and the workspace's account
watchlist, produce a shortlist of accounts this actually matters to, with an evidence-based
why, an outreach angle, and a talk track per account. This is the account-relevance pass —
the deep-dive exposure analysis lives in `/cc:account:exposure`; this command decides *who*
gets one and *why now*.

## Change

$ARGUMENTS

If empty, ask for the change (digest entry or pasted text) before proceeding.

## The watchlist convention

**Where this reads from:** `accounts/` resolves against the deals workspace per the Command
Integration Contract in `${CLAUDE_PLUGIN_ROOT}/references/presales/deals-workspace.md`
(config → env → default `~/code/deals-workspace`) — never this repo's own tree. An absent
workspace means "no watchlist yet" (the graceful path in step 4 below), not a license to
search the current repo.

Read `<deals-workspace>/accounts/watchlist.md`. Convention (document any deviation you find,
but this is what to expect and what to write if creating the file for the first time):

```markdown
- Acme Corp — lanes: CN→US, MX→US; erp: SAP; notes: importer of record, apparel HS61-62
- Globex Ltd
- Initech — lanes: EU intra + UK; notes: CBAM-exposed steel importer
```

One account per bullet. The account name is the only required part. Annotations after an
em dash are optional, free-form, semicolon-separated `key: value` pairs — common keys are
`lanes` (trade lanes / origin→destination), `erp` (known systems), `notes` (anything else
useful: product categories, HS exposure, prior findings). Missing annotations just mean
less to match against — never invent lanes/ERP/notes that aren't written down.

**No watchlist file present:** this is a graceful, expected path, not an error. Skip to
producing the change's **general affected-profile** instead (see step 4) and say plainly
that no watchlist was found, so account-specific matching wasn't possible.

## Steps

1. **Parse the change.** Same extraction as `/cc:radar:impact` step 1: HS chapters/rates,
   country/party lists touched, regime/program, effective date, jurisdiction. If too vague
   to extract anything concrete, ask for the specific notice rather than guessing.

2. **Load context.** Read the watchlist (if present) and, for each watched account, check
   whether `<deals-workspace>/accounts/` holds a prior brief or exposure analysis for that
   account (e.g. `brief-<name>.md`, `exposure-<name>.md`) — prior exposure briefs are the
   richest evidence source and take priority over annotation-only matching.

3. **Assess relevance per watched account.** For each account on the watchlist, match the
   change's parsed scope against:
   - the account's `lanes`/`notes` annotations (origin/destination, product category, HS
     exposure keywords)
   - anything in a prior brief/exposure doc that names the same lane, HS chapter, party, or
     regime
   Score relevance as a plain judgment call (clearly relevant / possibly relevant / not
   relevant) — do not force every account onto the shortlist. An account with no annotation
   overlap and no prior-brief overlap is **not relevant**; say so rather than stretching a
   generic "trade compliance matters to everyone" connection.

4. **Graceful no-watchlist / thin-watchlist path.** If there's no watchlist, or the change
   doesn't clearly match anyone on it, produce the change's **general affected-profile**
   instead: the kind of company this hits (e.g. "importers of record for HS 84.71 goods on
   the CN→US lane" or "EU importers of covered CBAM goods without an authorized declarant
   status yet") — useful for prospecting even with zero account-specific evidence. Label
   this section clearly as a profile, not an account shortlist.

5. **Shortlist with per-account WHY.** For each account that clears relevance, write the WHY
   as an evidence chain (cite the annotation or prior-brief line it came from), and apply the
   confidence-tagging convention mandatorily to every claim per
   `${CLAUDE_PLUGIN_ROOT}/skills/confidence-tagger/references/confidence-tagging.md`:
   🟢 Confirmed (from a prior brief/exposure doc or explicit watchlist annotation) / 🟡
   Inferred (reasoned from partial annotation match or industry norms) / 🔴 Unknown (real
   gap — name it, don't fill it). Never invent a fact about an account that isn't in the
   watchlist annotation, a prior brief, or the change itself.

6. **Outreach angle + talk track.** Per shortlisted account, one outreach angle (why reach
   out now — the compelling event this change creates) and a 3-line talk track. Keep the
   talk track at **capability level** — describe what the account now needs to be able to do
   (re-screen counterparties, re-classify a lane, re-price landed cost), never a product
   name. If a specific offering identity is genuinely needed in the flow, use a brand token
   like `${user_config.company}` rather than naming a real product.

## Output

```
RADAR BRIEF — <one-line change summary>
Change: <regime/program, what moved, effective date>
Watchlist: <found, N accounts / not found>

SHORTLIST (accounts where this matters)

### <Account name>
WHY: <evidence chain — cites annotation or prior-brief line> 🟢/🟡/🔴
Outreach angle: <the compelling event this change creates for them, now>
Talk track (3 lines, capability-level, no product names):
  1. <line>
  2. <line>
  3. <line>

[repeat per shortlisted account]

NOT SHORTLISTED (watched, checked, no clear relevance)
<account>: <one line why not>

GENERAL AFFECTED-PROFILE (if no watchlist, or as a supplement)
<profile description — who this generally hits, and why>

Gaps: <what's unconfirmed and would sharpen this — same spirit as the exposure-brief "what we could not establish" section>
```

## Quality checklist

- [ ] Watchlist convention followed as documented above — no invented accounts, no invented
      annotations
- [ ] Every shortlisted account's WHY traces to a real annotation, a real prior-brief line,
      or the change text itself — never a generic "trade compliance always matters" filler
- [ ] Every claim carries a 🟢/🟡/🔴 confidence tag per the confidence-tagger convention
- [ ] Talk tracks are capability-level — no product names; `${user_config.company}`-style tokens used
      where identity is genuinely needed
- [ ] Accounts checked and found not-relevant are listed, not silently dropped — shows the
      shortlist was a real filter, not a copy of the watchlist
- [ ] No-watchlist and thin-match cases produce the general affected-profile instead of a
      forced or empty shortlist
- [ ] No fabricated account facts anywhere — missing data stated as missing

## Handoff

**Chain:** none — solo entry point, typically invoked from a `/cc:radar:scan` digest MAJOR item or a watchlist-proximity escalation.
**Solo:** shortlisted account needs a deeper look → suggest `/cc:account:exposure` for that account. Ready to reach out → suggest the `field-comms-writer` skill to draft the outreach email/recap using the talk track as input.
**Abort rules:** change text too vague to extract any concrete scope (no HS/rate/party/regime signal at all) → stop and ask for the specific notice or a more complete digest entry rather than guessing at relevance.
