# The Council Pattern

The shared engine behind every "council" in this plugin — the `/cc:life:*` decision councils
and the dev-side `architecture-board`. A council convenes several expert **hats**, each reasons
from its own lens, and a **moderator resolves the conflicts between them** — because that is
where the real decision lives. Instantiating this pattern is how a new council is built cheaply:
supply a hat roster, domain anchors, and which professional to verify with; the contract below
stays the same.

## The contract

### 1 — Convene (gather the situation)
Ask only for what's needed to be concrete, and never re-ask what's already in the conversation:
the **decision** (specific), the **goal & timeframe**, the **hard numbers/constraints**, and the
**context** (risk tolerance, dependents, jurisdiction — default per the instantiating skill).
If something material is missing, **ask a targeted question** rather than guessing; mark any
assumption you make as 🟡 in the output.

Decide which hats are **in scope** for this decision; a hat with nothing to add **abstains
explicitly** (say so — don't pad).

### 2 — The hat round
Each in-scope hat delivers, from its lens:
- **Analysis** through its framework,
- a **clear call / recommendation**,
- its **blind spot** (what this lens systematically under-weights),
- **1–2 questions back** to the user.

Each hat is defined by a **mandate** (what it owns), a **framework** (how it reasons), and a
**named blind spot** (so the moderator knows who to check it against). No hat ignores the others.

### 3 — Moderator synthesis
The moderator does the part a single perspective can't:
1. **Consensus** — what all hats agree on.
2. **Conflicts** — where they disagree, and **which side wins _in this person's situation_**,
   with reasoning (not a hand-wave). This is the core value; do not smooth it over.
3. **Recommendation / verdict** — one clear, prioritized answer (a ranked set of next steps, or a
   single GO/NO-GO for a readiness board).
4. **Verify with a professional** — the 2–4 points a licensed professional (named by the skill:
   tax advisor, fee-only planner, physician, attorney…) must confirm before anything binding.

### 4 — Output
Use the instantiating skill's template. The house shape:

```
[COUNCIL NAME] — [the decision]
════════════════════════════════════════════
Situation: [1 line] · Goal/horizon: [...] · Assumptions: 🟡 [...]

THE HATS
[emoji] [Hat]  — [recommendation in 1–2 lines]
...  (abstaining hats: "N/A — <why>")

CONFLICTS
• [Hat A] vs [Hat B]: [what] → [how the moderator resolves it, for THIS situation]

RECOMMENDATION (prioritized)
1. [concrete step]
2. [...]

VERIFY WITH A PRO
- [the specific question a licensed professional must answer]
```

Always end with the liability frame below.

## Safety & liability frame (non-negotiable)

Councils are **decision preparation, not professional advice.** Health, financial, tax, legal,
and insurance outputs are orientation to help you have a better conversation with a licensed
professional — not a substitute for one. **Never fabricate** figures, deadlines, dosages, or
legal thresholds; anchors are illustrative and drift over time (confirm current values), and
anything binding routes to a real professional. State this frame in the output of any
health/finance/legal/insurance council.

## Modes

- **Full council** (default) — all in-scope hats + moderator synthesis.
- **Single hat** — one lens on request ("just the tax view").
- **Quick check** — one line per hat + one recommendation, for a small decision.

## Quality checklist (applies to every council)

- [ ] Enough specifics gathered to be concrete — else asked, not guessed (assumptions tagged 🟡)
- [ ] Each in-scope hat gives a recommendation **and** its blind spot; abstentions are explicit
- [ ] At least one real conflict named and **resolved for this situation** (not smoothed over)
- [ ] Exactly one clear recommendation/verdict, prioritized
- [ ] "Verify with a pro" list is specific (no generic "consult a professional" filler)
- [ ] Liability frame present in health/finance/legal/insurance output

## Instantiating a new council (build recipe)

A council skill is thin: it supplies these four things and defers everything else here.
1. **Hat roster** — 3–6 hats, each with mandate + framework + blind spot.
2. **Domain anchors** — the concrete reference points for the domain and jurisdiction (e.g. US
   tax-shelter accounts, mortgage math), clearly marked as orientation, not binding.
3. **Which professional to verify with** — named per hat/domain.
4. **Output label & any domain-specific rows** — otherwise use the house shape above.
