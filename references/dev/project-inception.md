# Project Inception — The Interview Guide for `/cc:plan:project`

> How to probe a human with a fuzzy idea until scope, intent, and requirements are
> captured implementation-ready. This is the judgment core of greenfield PIV: there is
> no codebase to analyze, so the *founder's head* is the codebase — and the interview
> is the intelligence-gathering pass. Output contract: the **project charter**
> (template below), written to `[WORKSPACE_DIR]/plans/project-charter-<name>.md`.

The charter must feed `/cc:plan:feature` at its ≥9/10 bar: slice 1 of the charter is,
as written, a plan:feature input. The existing `/cc:plan:prd` questioning happens *per
feature, inside a project that exists* — this interview precedes it and seeds it; do
not re-run the PRD question batches here. After the charter, `/cc:plan:setup` (or
`/cc:setup:project`) owns toolchain init — the interview picks the stack, setup makes
it real.

Serves personal apps and work POCs alike. Nothing here assumes a company, a team, or
a market — a project of one still has a problem, a user, and a first slice.

---

## The question ladder

Seven stages, in order. Each stage has a **goal**, **exemplar questions** (askable
verbatim — not categories to improvise from), a **sufficient-answer test**, and a
**vague-answer move**. Climb in order: each stage's answers are inputs to the next
(you can't cut an MVP before you know what success means). A stage is done when its
test passes — never because you asked some quota of questions.

Ask ONE question at a time. Every stage's rules in *Interview discipline* below apply
throughout.

### Stage 1 — The problem, and who has it

**Goal:** a concrete pain, owned by a nameable person, costed in today's workaround.
Not a solution restated as a problem ("I need a dashboard" is a solution wearing a
problem's clothes).

Exemplar questions:

- "Before we talk about what to build — what's the annoying thing that made you want
  this? Walk me through the last time it bit you."
- "What do you do about it today? How long does that take, and what does it get
  wrong?"
- "If you never build this, what's the cost — time, money, missed something, or just
  irritation?"

**Sufficient when:** you can state the problem in one sentence a stranger would
understand, name who suffers it, and describe the current workaround (including
"nothing — they just live with it"). You have at least one verbatim quote.

**Vague-answer move:** drop from the abstract to the episodic — "Tell me about the
*last specific time* this happened. What day was it, what were you trying to do?"
Humans generalize badly but narrate well; one real episode beats three adjectives.
If the answer keeps coming back as a solution ("the problem is I don't have an app"),
ask what the app would have *prevented* last week.

### Stage 2 — Users and the moment of use

**Goal:** who touches this thing, and the exact moment they reach for it — device in
hand, context, trigger. "Users" for a personal tool is still a real answer ("me, on my
phone, standing in the garage").

Exemplar questions:

- "Who actually opens this — just you, you plus family, a customer, a whole team?"
- "Picture the moment someone reaches for it: where are they, what device is in their
  hand, what just happened that made them open it?"
- "Is anyone using it who *didn't* choose it — a spouse, a coworker, a customer's
  end user? What do they need to be true?"

**Sufficient when:** you can write the primary scenario as one paragraph: *actor,
trigger, device/context, action, outcome*. Secondary users (if any) are named with
one-line needs. The device/context answer will constrain the stack in Stage 5 —
capture it precisely.

**Vague-answer move:** offer a forced choice, not an open re-ask — "If I had to pick
ONE: is this mostly you at a desk, you on your phone, or someone else entirely?"
A wrong guess the user corrects is faster than a fourth open question.

### Stage 3 — Success criteria (falsifiable)

**Goal:** a test the future can fail. "It works" and "I use it" are not criteria;
"I've logged every workout for 8 straight weeks without falling back to the
spreadsheet" is.

Exemplar questions:

- "It's three months from now and this was worth building. How do you *know*? What's
  observably different?"
- "What would make you quietly stop using it and go back to the old way?"
- "Is there a number here — times per week, minutes saved, deals tracked — or is
  success purely 'it removed the annoyance'?"

**Sufficient when:** 2-4 criteria, each falsifiable (a stranger could check
true/false at a named date), and at least one is a *usage* criterion (proof of
adoption), not just a *capability* criterion (proof it runs). Date every criterion —
"by <date>" or "after N weeks of use."

**Vague-answer move:** invert it. If "how will you know it worked?" gets a shrug,
ask the failure form: "Okay — how would you know it *flopped*?" People who can't
describe success can almost always describe disappointment; negate that. Still
vague → write the best available criterion, tag it 🟡, and move on — don't drill a
dry well.

### Stage 4 — Constraints

**Goal:** the walls of the room — time, budget, deployment reality, data sensitivity,
and anything this *must* integrate with. Constraints are facts to collect, not
positions to debate; this is the fastest stage.

Exemplar questions:

- "Any clock on this — a demo date, an event, a 'before the season starts'? And is
  there a budget, or is hosting-for-free a requirement?"
- "Where does this realistically run — your own machine, a cheap cloud box, a
  serverless free tier, inside a corporate network you don't control?"
- "Does it touch anything sensitive — customer data, credentials, health/finance,
  anything an employer or regulator would care about?"
- "What does it HAVE to talk to — an existing API, a spreadsheet, a device, a
  calendar, someone else's system?"

**Sufficient when:** each of the five (time, budget, deployment, data sensitivity,
integrations) has an explicit answer — including the explicit answer "none." An
unasked constraint is a Stage-5 landmine; an asked-and-empty one is fine.

**Vague-answer move:** constraints resolve fastest by assertion-with-escape — "I'll
assume no deadline, free-tier hosting, and nothing sensitive. Stop me where I'm
wrong." One correction round beats five questions.

### Stage 5 — Stack recommendation

**Goal:** a chosen stack with a one-line why and one rejected alternative. **This
stage is a recommendation you make, not an interrogation you run** — by now you know
the user's context; spend at most one confirmation question here.

First, match against the seed profiles in `references/dev/stack-profiles/`
(currently: `nextjs`, `fastapi`, `django`, `expo-rn`, `generic-node`,
`generic-python`). If the user already lives in one of these ecosystems, their
existing-stack gravity usually wins — a familiar stack ships slices; a novel one
ships tutorials.

When no profile obviously fits, walk this short tree *yourself* and present the
conclusion:

1. **Shape** — what is it, from Stage 2's moment of use?
   - Browser UI, humans clicking → **web app** (nextjs; django if it's forms +
     database + admin).
   - Terminal, scripts, automation → **CLI** (generic-python or generic-node —
     whichever the user already writes).
   - No UI, other software calls it → **service/API** (fastapi; generic-node if the
     callers are JS).
   - Phone-in-the-garage, offline, camera/sensors → **mobile** (expo-rn) — but ask
     once whether a mobile-friendly web app is enough; native is a size multiplier.
2. **Hosting reality** — filter by Stage 4: free tier only → static/serverless-
   friendly wins; corporate network → whatever the org already runs; "my own
   machine" → anything, prefer simplest.
3. **Existing-stack gravity** — tie-breaker, and it breaks ties hard: recommend the
   candidate nearest what the user maintains today.

Then recommend: "Given X and Y, I'd build this as <stack>. The alternative is
<other>, which I'd reject because <one line>. Sound right?"

**Sufficient when:** the user has accepted a named stack (profile name or explicit
"custom: <what>"), and you hold the why + one rejected alternative for the charter.

**Vague-answer move:** if the user counters with genuine uncertainty or a contested
preference ("I keep hearing I should learn Rust for this"), don't litigate inline —
offer the `grill-me` branch (see *Interview discipline*). If they simply don't care,
your recommendation stands: indifference is acceptance.

### Stage 6 — The MVP cut

**Goal:** the first shippable slice — the smallest version the primary user (Stage 2)
would actually use in the real moment of use, plus the 2-5 slices that follow.

Exemplar questions:

- "If I could hand you ONE working piece next week, what hurts most if it's missing?"
  *(the forcing question — ask it verbatim)*
- "Could you genuinely use the tool with just that piece, or is there a second thing
  that makes it usable at all?"
- "Of everything else we've discussed — what's clearly round two?"

**Sufficient when:** slice 1 is small enough to be one `plan:feature` (days, not
weeks), complete enough to be *used* not just demoed, and the user has confirmed
they'd use it in that state. Remaining slices (2-5 more) are named and ordered.
A slice 1 that is "the data model plus login plus settings" fails — those are
foundations, not a usable slice; fold the minimum foundation *into* the first
user-visible capability.

**Vague-answer move:** when the user wants everything first, make the cut yourself
and force a swap, not a list: "Slice 1 is <A>. If you disagree, tell me what you'd
*remove* from it to make room." Prioritization by subtraction converges;
prioritization by addition never does.

### Stage 7 — Explicit non-goals

**Goal:** what v1 deliberately won't do — **extracted from the user, not assumed by
you**. A non-goal the user never agreed to is a scope dispute deferred to the worst
possible time.

Exemplar questions:

- "Let me list what I think we're NOT building in v1: <3-5 items inferred from
  everything above>. Confirm or fight me."
- "Is there anything you're worried I'll gold-plate — auth, theming, multi-user,
  offline — that you want explicitly parked?"
- "Anything on this non-goal list that actually stings? That's a sign it belongs in
  a slice, not the parked list."

**Sufficient when:** 3-6 non-goals, each *confirmed* by the user (silence on a list
you read out counts only if you asked for objections), and none of them contradicts
a success criterion from Stage 3.

**Vague-answer move:** non-goals are the one stage where proposing IS the technique —
users can't enumerate what they're not building, but they can veto a list. If the
user rejects every proposed non-goal ("we might need all of that"), that's a scope
alarm: return to Stage 6 and re-cut, or route the tension to `grill-me`.

---

## Interview discipline

These rules hold across every stage. They are the difference between an interview
and a form.

- **ONE question at a time — never a form.** A batch of five questions gets five
  half-answers and teaches the user to skim. Ask, wait, listen, then decide what the
  *answer* makes worth asking next. (This deliberately differs from `plan:prd`'s
  batched questioning — a PRD refines a project that exists; inception is discovery,
  and discovery is serial.)
- **Reflect before you advance.** Before the next question, restate what you heard
  in YOUR words — "So the real pain is re-entering the same data twice, not the data
  entry itself?" A wrong reflection caught now costs one sentence; caught in slice 2
  it costs a rewrite. The reflection is also your sufficiency check running out loud.
- **Capture 2-3 verbatim quotes.** The user's own words outlive your paraphrase.
  "I just want to stop dreading Sunday planning" carries intent that "user wants
  improved planning UX" launders away. Quote them in the charter's Problem section,
  marked as quotes.
- **A stage is done when its test passes** — not when N questions are asked. One
  crisp answer can clear a stage; four rambles may not. Check the sufficient-answer
  test after every reply, and move the moment it passes.
- **Contested or wavering decisions → offer `grill-me`.** When the user flip-flops,
  argues both sides, or says "I keep going back and forth on this" — about the stack,
  the MVP cut, whether it's mobile — don't burn the question budget adjudicating.
  Offer: "Want me to grill you on just this decision?" and run the `grill-me` skill
  on that branch, then return to the ladder with the resolution.
- **Budget: ~10-15 questions total.** Seven stages, one to two questions each, is
  the natural shape. If you're past 15, you are interrogating, not interviewing —
  stop, write the charter with what you have, and tag every thin stage 🟡 in Open
  Questions. A charter with two honest 🟡s beats a user who never wants to be
  interviewed again.
- **Recommend at the ceiling of your knowledge.** Where the user's context fully
  determines an answer (stack, hosting, slice order), propose it and ask for
  objections instead of asking an open question. Open questions are for what only
  the user knows; recommendations are for what you already do.

---

## The charter template

The output contract. Every section is required; a section you couldn't fill gets its
content replaced by a 🟡 line naming the failed stage — never silently omitted,
never padded with plausible invention.

```markdown
# Project Charter: <Name>

> <One-line pitch — what it is, for whom, in one sentence.>

**Created:** <date> · **Interviewed:** <who> · **Charter confidence:** <n>/10

## Problem

<2-3 sentences: the pain, who has it, the current workaround and its cost.>

> "<verbatim user quote>"
> "<verbatim user quote>"

## Users & primary scenario

<Primary user + the moment of use as one paragraph: actor, trigger, device/context,
action, outcome. Secondary users as one-liners, or "none.">

## Success criteria

- [ ] <falsifiable, dated — e.g. "By <date>, used ≥3×/week for 4 consecutive weeks">
- [ ] <falsifiable, dated>

## Constraints

| Constraint | Answer |
|---|---|
| Time | <deadline or "none stated"> |
| Budget | <hosting/spend reality> |
| Deployment | <where it runs> |
| Data sensitivity | <what's sensitive, or "none"> |
| Must integrate with | <systems, or "nothing"> |

## Stack

**Chosen:** <profile name from `stack-profiles/`, or "custom: <what>"> — <one-line why>.
**Rejected:** <alternative> — <one-line why not>.

## Slices

<3-6 slices, ordered. Slice 1 is the MVP cut.>

### Slice 1: <name> ← first `plan:feature` candidate

<One paragraph of scope: what the user can DO when this slice ships — concrete
behavior, not architecture. Name the moving parts only where they define the scope
boundary.>

**Acceptance criteria:**
- <specific, testable — checkable by someone who didn't build it>
- <specific, testable>

**Size:** S | M | L

### Slice 2: <name>
<same shape: scope paragraph, acceptance bullets, size>

## Non-goals (v1)

- <confirmed non-goal — what and, where useful, why parked>
- <confirmed non-goal>

## Open questions

- 🟡 <anything carried from a thin stage — named honestly, not resolved by fiat>

## Charter confidence: <n>/10

<Justification with the same discipline as plan:feature's score: what makes this
solid, what the residual risk is, and which section it lives in. If the honest score
is below 7, the charter is a draft — name the failing stage and return to it before
handing off.>
```

**Slice format contract:** each slice must be consumable by `/cc:plan:feature` as
written — plan:feature's Phase 1 extracts *core problem, user value, feature type,
complexity* from its argument, so a slice needs enough scope prose to yield a user
story and enough acceptance criteria to seed the plan's acceptance section. Test:
could you paste the slice's name + scope paragraph + acceptance bullets in as the
plan:feature argument, alone, and expect a coherent plan? If a slice is big enough
to carry its own users/scope/risk decisions (rare in v1), note "run `/cc:plan:prd`
first" on that slice — the charter seeds that PRD; the PRD does not re-interview.

---

## The PIV mapping

Greenfield inception IS a PIV loop — the project-sized outer loop that contains
every feature-sized inner loop:

- **Plan** = this interview → the project charter (+ PRD seed where a slice
  warrants one).
- **Implement** = `/cc:setup:project` scaffolds (classify, git, `.specify/`,
  `setup:stack`) → slice 1 runs `plan:feature` → `piv:ship`.
- **Validate** = the first green resolved gate (`verify:run` against the new
  `STACK.md`) + a `maintain`-grade audit of what setup planted.

Then the outer loop closes: each subsequent slice is its own inner PIV loop, and
the charter's slice list is the outer plan they execute against.

---

## Sufficiency test for the whole charter

The **stranger test** — piv-methodology's no-prior-knowledge test, applied to
inception:

> Could a competent developer with ZERO context — never met the founder, never saw
> this conversation — read the charter alone and start slice 1's `plan:feature`
> without asking the founder anything?

Walk it concretely before handing off: the stranger needs to know *what problem*
(Stage 1), *for whom and when* (Stage 2), *what done means* (Stage 3), *what walls
exist* (Stage 4), *what to build with* (Stage 5), *what to build first and how to
check it* (Stage 6), and *what to refuse to build* (Stage 7). If the stranger would
have to ask a question, that question belongs to exactly one ladder stage — **name
the stage that fails and return to it** (or, past budget, tag it 🟡 in Open
Questions and say so in the confidence justification). A charter that passes the
stranger test with an honest confidence ≥7/10 is implementation-ready; hand off to
`/cc:setup:project`.
