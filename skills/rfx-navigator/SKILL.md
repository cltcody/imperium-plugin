---
name: rfx-navigator
description: |
  Entry-point skill for any RFX document -- RFI, RFP, RFQ, ITT, or tender -- identifies the
  document type, does a rapid first-cut fit assessment, and routes to the right command. Run
  this first, before committing SC time.
  Use when you say "we got an RFP", "RFQ just came in", "an RFX arrived", "should we bid",
  or "bid or no bid".
---

# RFX Navigator

First stop for any incoming RFP, RFI, RFQ, ITT, or tender document.
Gets you oriented in 10 minutes before committing SC time to a full response.

Note: Detailed workflows live in the commands — this skill is the triage and routing layer.

---

## Step 1 — What type of document is this?

Paste the document or describe it. Identify the type — it determines the entire strategy.

```
DOCUMENT TYPE IDENTIFICATION

RFI — Request for Information
  What it is: Market information gathering. No commitment to buy yet.
  Workload: Low–Medium. Typically 1–5 pages of narrative responses.
  Strategy: Establish presence, demonstrate thought leadership, get on the shortlist.
             Do NOT over-engineer this. Save the heavy SC work for the RFP that follows.
  Watch out for: A very detailed RFI may be an RFP in disguise — check the timeline.

RFP — Request for Proposal
  What it is: Formal proposal request. Buying intent is real.
  Workload: High. Typically 2–8 weeks of SC effort depending on size and complexity.
  Strategy: Compliance first, then differentiation. Win on fit — not on volume of words.
  Watch out for: Language spec'd for an incumbent. Run /cc:rfp:analyze before starting.

RFQ — Request for Quotation
  What it is: Price-focused. Technical evaluation is largely done — they want commercial terms.
  Workload: Low on SC (technical work complete); High on AE and commercial team.
  Strategy: Anchor value before price lands. Do not let this become a race to the bottom.
  Watch out for: If you have no prior relationship with this account, someone else is the
                 technical incumbent. You are wiring the competition. Qualify out quickly.

ITT / Tender — Invitation to Tender
  What it is: Formal procurement, often public sector or regulated industry.
  Workload: Very High. Strict format requirements, mandatory compliance, formal evaluation.
  Strategy: Compliance above all. Every deviation is a disqualification risk.
  Watch out for: Non-negotiable deadlines. Late by one minute = automatic disqualification.
```

---

## Step 2 — Rapid fit scan (10 minutes)

```
RAPID FIT SCAN

Account: [___]
Document type: RFI / RFP / RFQ / ITT
Submission deadline: [date — how many days from today?]
Estimated size: [number of questions / pages / sections]

Products in scope:
  [ ] Trade compliance / classification (${user_config.product_a}, ${user_config.product_b})
  [ ] Customs filing / brokerage (${user_config.product_c}, ${user_config.product_d})
  [ ] Supply chain visibility
  [ ] Transport management
  [ ] Other: [___]

Mandatory requirements we clearly cannot meet: [List — if any. If yes, stop here.]
Obvious strengths — where this document plays directly to us: [List]

Wired for a competitor? Every senior SC knows these fingerprints — check each:
  [ ] Requirements use one vendor's proprietary feature names or module structure
  [ ] One unusual MANDATORY requirement only a single vendor can meet (a seeded spec)
  [ ] Question order mirrors a competitor's demo script or documentation structure
  [ ] Fully-formed, highly specific requirements from an account with zero prior
      discovery contact — someone helped write this
  [ ] No Q&A round, no workshops, no stakeholder access — they need nothing FROM you
  [ ] Timeline too short for a real evaluation, but fine for rubber-stamping a decision
  [ ] Scoring weights skewed to a known competitor's strength or your known weakness
  → 2+ checked: assume you are column fodder. Escalate to AE with the evidence; bid only if a named insider confirms the decision is genuinely open.

Our prior relationship with this account:
  [ ] Existing customer — we are embedded and responding to expand
  [ ] Active pipeline — we know this account and have prior discovery
  [ ] Prior deal — we bid before (won / lost / no decision — when? why?)
  [ ] Cold — no prior relationship (caution: cold RFX responses have low win rates)
```

### Evidence anchors for the bid / no-bid score

`/cc:rfp:analyze` scores five dimensions 1–5. A score is earned by evidence you can cite — no citable evidence means ≤ 2 by definition, not a comfortable 3.

| Dimension | Scores 4–5 only if | Scores 1–2 if |
|-----------|-------------------|---------------|
| Product/capability fit | Mandatories mapped line-by-line; every one met by GA product today | Coverage asserted from memory; any mandatory on roadmap or unknown |
| Account relationship | Named contact who takes our calls; prior discovery notes in CRM | Nobody there answers us; "relationship" = we recognise the logo |
| Win probability | Wired-scan clean AND an insider confirms the decision is open | 2+ wired flags, or we first learned of the initiative from the RFX itself |
| Strategic fit | Matches ICP on industry and size; a win yields a reference we would use | The only argument for bidding is "revenue is revenue" |
| Resource feasibility | Named SC with confirmed capacity through the deadline | Effort exceeds available days, or no owner named |

---

## Step 3 — Strategy recommendation by document type

```
IF THIS IS AN RFI:
  Goal: Get on the shortlist, not write the full response.
  Time box: Allocate [N] hours maximum — this is not a full proposal.
  Key sections to prioritise: company overview, capability match, reference customers.
  Skip: Detailed implementation approach, full integration architecture, pricing.
  Next step: /cc:rfp:respond with a scoped response plan — or draft directly.

IF THIS IS AN RFP:
  Goal: Score the highest combined capability + compliance total across all evaluators.
  First step: Run /cc:rfp:analyze to get a BID / NO-BID recommendation before writing a word.
  If it's a BID: Run /cc:rfp:respond to build the requirement coverage matrix.
  If a presentation is required alongside: Run /cc:rfp:present.

IF THIS IS AN RFQ:
  Goal: Anchor value before price. Do not respond to an RFQ with only a price.
  First step: Brief the AE immediately — this is a commercial lead, not an SC lead.
  SC action: Run /cc:value:roi-case to prepare the value anchor.
  AE action: Confirm budget holder, decision timeline, and any competing quotes.
  Format: Consider /cc:deal:proposal for a value-anchored commercial response.

IF THIS IS AN ITT / TENDER:
  Goal: Full compliance. Non-compliance = disqualification.
  First step: Map every mandatory requirement before writing anything.
  Run: /cc:rfp:analyze (use the requirements fit scan) then /cc:rfp:respond.
  Legal review: Mandatory if the ITT includes contract terms or jurisdictional clauses.
```

---

## Step 4 — Routing decision

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RFX NAVIGATOR — [Account] | [Document type]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Document type: [RFI / RFP / RFQ / ITT]
Deadline: [date] — [N] days from today
Estimated SC effort: [Low / Medium / High / Very High]

First impression:
[2–3 sentences — what stands out, any red flags, initial read on fit and win probability]

RECOMMENDED NEXT STEP:

→ /cc:rfp:analyze [account name]
  Use when: Need a scored BID / NO-BID / CONDITIONAL recommendation (30 min)

→ /cc:rfp:respond [account name]
  Use when: Decision to bid is made — build the requirement coverage matrix and draft responses

→ /cc:rfp:present [account name]
  Use when: A shortlist presentation is required alongside the written response

→ /cc:value:roi-case [account name]
  Use when: RFQ — anchor value before the commercial response

→ /cc:deal:proposal [account name]
  Use when: RFQ or commercial response format needed

Emergency (< 5 days to deadline):
  Skip /cc:rfp:analyze. Go straight to /cc:rfp:respond.
  Flag to AE: this response will be constrained — scope it honestly and prioritise mandatory requirements.

NO-BID: decline gracefully (see below) — a silent no-bid burns the account.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## The NO-BID path — decline gracefully

A no-bid is an account touch, not a rejection — procurement re-invites vendors who respond
professionally. Send via the AE within 48h; adapt this skeleton (under 150 words, never blame the document):

> Thank you for including ${user_config.company} in this process. After reviewing the requirements, we've
> concluded we're not the right fit for this scope at this time — [one honest, non-defensive
> reason: timeline, scope focus, or capability boundary]. Rather than submit a response that
> wouldn't serve your evaluation, we'd prefer to be straightforward now. We'd welcome staying
> in touch on [adjacent area of genuine fit].

Log the primary reason in Salesforce per the `/cc:rfp:analyze` NO-BID output ("what would need to change to reconsider") — the next SC inherits the reasoning, not just the outcome.

---

## Quality checklist

- [ ] Document type confirmed — RFI vs. RFP vs. RFQ changes the entire approach and workload
- [ ] Deadline checked — is it achievable? If not, escalate to AE before starting
- [ ] Mandatory requirements scanned — no point starting if there are showstopper gaps
- [ ] Wired-for-competitor scan completed — 2+ flags escalated to AE with the specific evidence
- [ ] AE is aware this RFX has arrived and has agreed to pursue it
- [ ] Prior responses for this account checked (Salesforce / Confluence / references folder)
- [ ] If NO-BID: graceful decline sent via AE within 48h and reason logged in Salesforce
