# Expert Phase Guide — Facilitating the Full TOC + BBiT Analysis

The facilitation layer for the `toc-bbit-expert` skill: the questions to ask the user at
each phase, the tables to fill, the presales-flavoured examples, and the final output
template. Theory for each tool lives in the framework references under
`${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/` — each phase below cites the
module to read before using that tool. Do not re-derive the theory; apply it.

---

## Phase 0 — System Framing

*A BBiT expert never starts analysis before answering these four questions. Skipping this
is the single most common source of bad analysis. Do not proceed until all four are answered.*

**Q1: What is the system?**
Define the boundary clearly. Is this a deal, a sales team process, a customer's supply chain, a conflict between two people, a product delivery flow, or something else? The system defines where the constraint can be.

**Q2: What is the system's goal?**
State the goal in one precise sentence. Everything is measured against this.
- Deal: "Close a qualified opportunity with a long-term customer who gets measurable value."
- Sales process: "Consistently progress qualified deals to close at a predictable rate."
- Customer operation: "Fulfil customer demand on time, in full, at minimum cost."
- Team: "Deliver [output] consistently within [constraints] without burning people out."

**Q3: What is the signal that the system is not achieving its goal?**
What observation makes you believe a constraint exists right now? Be specific — this becomes the seed for your first UDE.

**Q4: What type of constraint is this likely to be?**

| Type | Description | Examples |
|------|-------------|---------|
| **Physical** | Capacity, resource, machine, headcount — something tangible is insufficient | "We only have 2 SCs for 40 AEs" |
| **Policy** | A rule, process, or procedure limits throughput | "Demos require manager approval before booking" |
| **Paradigm** | A belief, assumption, or mental model prevents people from acting | "We believe customers always want the cheapest option" |

*Most real constraints that keep repeating are policy or paradigm. Physical constraints are usually identified and fixed quickly. Policy and paradigm constraints persist because no one questions the assumption holding them in place.*

### Subject selection (when the user is unsure what to analyse)

Theory — subject vs. goal, the four criteria (intuition, care, size, influence), and the
single-perspective rule — is in `BBiT/subject-selection-and-scrutiny.md`. Presales-flavoured
examples of the distinction:

| Goal (use PRT directly) | Subject (run the full analysis) |
|------|---------|
| Close this deal by Q3 | Our deal qualification process |
| Complete project X by year end | Managing projects in our business |
| Finish in the top 5% of my class | My approach to university |
| Reduce discovery call no-shows | Our discovery engagement quality |

Analysing the subject creates durable change. Analysing the goal helps once. If you find
yourself writing a long list of obstacles at the start, you probably have a goal — use the
PRT directly instead.

### Logic types (foundation — read `BBiT/critical-thinking-logic.md`)

Presales-flavoured examples of the two logic types:
- Cause-and-effect (vertical): "If demos start before discovery is complete, then the customer sees generic capability, not relevant solutions."
- Prerequisite (horizontal): "In order to co-sign the evaluation plan, I must first have a champion who is willing to sponsor the evaluation."

Challenge the assumption behind a prerequisite ("...because [assumption]") to find
injections — prerequisites are often false when the assumption is examined.

---

## Phase 1 — Collect Undesirable Effects (UDEs)

**Read first:** the UDE rules in `TOC_and_BBiT_Cheat_Sheet.md` (Step 1).

*A BBiT expert spends 40% of their time here. Imprecise UDEs are the most common source of bad analysis. Do not rush this.*

### The four UDE rules — enforce every one (presales examples)

| Rule | Test | Wrong example | Right example |
|------|------|---------------|---------------|
| **Describe only what you see** | Is this an observation, or an interpretation? | "We don't have a real champion" | "No internal contact has initiated unsolicited outreach on our behalf in 8 weeks" |
| **Make it standalone and specific** | Can a stranger understand this with no context? | "Communication is poor" | "Handover notes are missing for 60% of deals entering Stage 40" |
| **Describe the effect, not the cause** | Does this state an effect, not a mechanism? | "Deals stall because we skip discovery" | "40% of demos end without a defined next step" |
| **Keep it neutral** | Could this be read as blame? | "The AE rushes us into demos" | "Demo requests arrive before discovery is complete in the majority of opportunities" |

### UDE collection — questions to ask

Press for specifics. Do not accept vague answers. Keep asking "what does that look like concretely?"

- "What frustrates you most about this system right now?"
- "What keeps happening that shouldn't? How often?"
- "Where do you see rework, delays, or waste repeating?"
- "What data shows performance is below what it should be?"
- "Where do handovers or communication regularly break?"
- "What does the customer complain about that keeps coming back?"
- "What decisions are you making repeatedly that you shouldn't need to make?"
- "What takes longer than it should? How much longer?"
- "What do you dread seeing in your inbox or pipeline?"

### UDE table

Aim for 5–8 UDEs. Fewer than 4 usually means the analysis is shallow. More than 10 usually means some are causes rather than effects.

| # | UDE (observable, specific, neutral) | How often | Impact |
|---|-------------------------------------|-----------|--------|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |

### UDE screening (run on every entry)

Before accepting a UDE, check:
- [ ] Observable — could you point to evidence for this?
- [ ] Specific — would two people describe it the same way?
- [ ] Effect, not cause — does it describe a state, not a mechanism?
- [ ] Neutral — does it avoid assigning cause or blame?

If any check fails, rewrite before proceeding.

---

## Phase 2 — Build the Current Reality Tree (CRT)

**Goal: Find what to change. This is TOC Question 1.**
**Read first:** `TOC_and_BBiT_Cheat_Sheet.md` (Step 2) and `BBiT/critical-thinking-logic.md`.

A CRT connects UDEs backward through if-then causality until the chains converge on the single driver causing most of the UDEs. That driver is the root cause — or more precisely, the core conflict sustaining the system's underperformance.

*Use vertical arrows throughout. Every link is cause-and-effect logic: "If [lower], then [upper]."*

### How to build the CRT

1. Take each UDE. For each one, ask: *"What would have to be true for this to exist? What causes it?"* — this gives an intermediate cause.
2. For each intermediate cause, ask the same question again. Go deeper.
3. Continue until the chains converge. The convergence point is the core conflict or root cause.
4. Validate every single link with the three tests below before accepting it.

### Three validation tests — apply to every link

| Test | Question to ask | What to do if it fails |
|------|----------------|----------------------|
| **Causality test** | Does this cause reasonably and consistently produce that effect? Is this a causal relationship, not a coincidence? | Separate the link. It is not valid. Do not force it. |
| **Assumption test** | What hidden belief makes this link hold? State it explicitly. | Add the assumption label. If the assumption is clearly false, the link is invalid. |
| **Entity test** | Are both statements unambiguous? Could two people interpret either of them differently? | Rewrite until a stranger would understand both statements identically. |

### CRT structure pattern

```
UDE 1          UDE 2          UDE 3
    \              |              /
  Intermediate    |         Intermediate
     Effect       |              |
          \       |           /
           Intermediate Effect
                   |
        CORE CONFLICT / ROOT CAUSE
```

### Expert questions for building the CRT

- "What would have to be true for this cause to produce that effect?"
- "Is this always true, or only sometimes? What makes the difference?"
- "What hidden assumption is holding this link together?"
- "If we fixed this cause, would the effect disappear — or would something else produce it instead?"
- "Are there actually two separate causes here, or is this one mechanism?"
- "Is this an intermediate effect, or could it actually be closer to the root?"
- "Have you ever seen this cause exist without producing this effect? What was different?"

### Applying scrutiny (CLRs) as you build

Apply basic scrutiny to every link — entity clarity and connection clarity
(`BBiT/subject-selection-and-scrutiny.md`, Part 2). Flag issues with a token rather than
stopping to fix immediately. Review first, then edit.

### CRT output

**Root cause:** [single sentence — specific, observable, stated as a current condition at the policy or paradigm level]

**Key sustaining assumption:** [the belief that keeps the root cause in place and prevents people from challenging it]

After completing: offer a **CRT Excalidraw diagram** (see `diagram-guide.md`).

> **TOC Q1 answered: What to change?**

---

## Phase 3 — Map the Conflict (Evaporation Cloud)

**Goal: Surface and name the hidden conflict sustaining the root cause.**
**Read first:** `BBiT/clouds-conflict-resolution.md` — conflict types, right-to-left
construction, the three ways to solve a cloud, and the common-errors table all live there.

Every persistent problem is sustained by a conflict. Not a mistake, not a gap — a conflict. Two actions that both seem reasonable, serving two real needs, that cannot coexist. The Cloud makes this conflict explicit so it can be *dissolved*, not negotiated around.

*If a problem keeps coming back despite repeated fixes, a cloud is always present. The fixes are addressing symptoms, not the conflict.*

The three conflict types, in presales terms:
- **Personal** — "Prepare thoroughly" vs "respond quickly to the AE"
- **Interpersonal** — SC wants full FTD; AE wants to skip straight to demo
- **Policy** — Want to run a free PoC, but policy requires VP approval

### The five elements of the cloud (presales example)

| Element | Symbol | Question to identify it | Example |
|---------|--------|------------------------|---------|
| **Goal** | G | What do both sides ultimately want to achieve? | "Shorten the sales cycle without losing deal quality" |
| **Need A** | NA | What does Side A need in order to achieve the goal? | "Speed — get to proposal and close quickly" |
| **Need B** | NB | What does Side B need in order to achieve the goal? | "Completeness — full technical discovery before committing" |
| **Want A** | WA | What action does Side A take or push for? | "Skip or compress discovery calls" |
| **Want B** | WB | What opposing action does Side B take or push for? | "Run a full 2-hour FTD before any demo" |
| **Conflict** | ↔ | Why can WA and WB not coexist? | Both compete for the same time in the pre-demo week |

### Cloud diagram structure

```
                      [G — Goal]
                    /              \
              [NA — Need A]    [NB — Need B]
                   |                  |
            [WA — Want A] ←——→ [WB — Want B]
                         CONFLICT
```

**Every arrow carries an assumption.** State the assumption on each of the five arrows:

| Arrow | Assumption to state |
|-------|-------------------|
| G → NA | "To achieve [G], we need [NA] because..." |
| G → NB | "To achieve [G], we need [NB] because..." |
| NA → WA | "The only way to satisfy [NA] is [WA] because..." |
| NB → WB | "The only way to satisfy [NB] is [WB] because..." |
| WA ↔ WB | "[WA] and [WB] cannot coexist because..." |

### Challenging the assumptions

For each assumption, ask:

- **"Is this always true — or just usually true?"**
- **"Is this a fact or a belief?"**
- **"What would need to change for this to be false?"**
- **"Has it ever been false? Under what conditions?"**
- **"Who decided this was necessary? When? Is that context still valid?"**

*The assumption that, when broken, makes the conflict disappear is your injection target.*

### Druid loop — for oscillating conflicts

If the same conflict keeps returning after being "resolved," you are in a Druid loop.
**Read `BBiT/druid-loop.md`** for construction steps, the validation checklist, and the
five common errors (repetition, premature looping, failed solution, tangent, stopping short).

```
[Goal is violated — Side A]              [Goal is violated — Side B]
         ↓                                          ↓
[Intermediate effect A2]              [Intermediate effect B2]
         ↓                                          ↓
[Behaviour A] ←————————————————————————→ [Behaviour B]
       (Push back to B when A's            (Push back to A when B's
        goal violation hits)                goal violation hits)
```

Break the loop by finding which need is violated at the trigger point and targeting the
injection there. Addressing the reactive action directly just accelerates the loop.

After completing: offer a **Druid** and/or **Cloud (Assumption Graphic)** Excalidraw
diagram (see `diagram-guide.md`).

---

## Phase 4 — Break the Assumptions (Injections)

**Goal: Find what to change to. This is TOC Question 2.**
**Read first:** `BBiT/injections.md` (raise-then-reverse process, don't filter, state not
action, break your own side first) and `BBiT/core-conflict-injections-and-frt.md` Part 1
(10–30 assumptions on the key connection; chase impact, not ease).

An injection is not a compromise. A compromise means both sides get less than they need. An injection means the conflict becomes unnecessary — because the assumption holding it in place is no longer true.

**The golden rule: an injection is a state, never an action.**
Word it as an outcome that must exist ("the cat has access to food"), not a task ("ask the neighbour to feed the cat"). The state is your target; actions come later and can change.

### Injection rules (a BBiT expert enforces every one)

1. **An injection must break a named assumption** — not split the difference between WA and WB.
2. **Develop multiple injections** — never stop at the first one.
3. **Test for win-win** — both Need A and Need B must remain fully satisfied. If one side still loses something real, it is a compromise, not an injection.
4. **Test for new UDEs** — does the injection create new problems? If yes, add a preventative injection for each.
5. **Select the simplest effective injection** — the one requiring the fewest resources, the least time, and the most leverage per unit of effort.
6. **For clouds: break your own side first.** Breaking the other person's side makes people defensive. You still get the effect you want, and you avoid a fight.

### Injection development table

| # | Injection (state that must exist) | Assumption it breaks | NA still satisfied? | NB still satisfied? | New UDEs? |
|---|-----------------------------------|---------------------|---------------------|---------------------|-----------|
| 1 | | | ✅ / ❌ | ✅ / ❌ | |
| 2 | | | ✅ / ❌ | ✅ / ❌ | |
| 3 | | | ✅ / ❌ | ✅ / ❌ | |

### Expert questions for injection development

- "If this assumption weren't true, would the conflict disappear?"
- "What would need to change in the *system* — not just in one person's behaviour — for both needs to be met simultaneously?"
- "Is there a way to satisfy Need A through a completely different mechanism than Want A?"
- "What would make this conflict obsolete?"
- "What would a systems designer do here, rather than a negotiator?"
- "What do other systems do when they face this same conflict?"

### Selected injection

**Best injection:** [the simplest state-change that satisfies both needs and creates no new UDEs]

**Win-win confirmation:**
- [ ] Need A remains fully satisfied
- [ ] Need B remains fully satisfied
- [ ] The conflict is dissolved, not suppressed
- [ ] No new UDEs introduced (or each is covered by a preventative injection)

> **TOC Q2 answered: What to change to?**

---

## Phase 5 — Design the Future State (Future Reality Tree — FRT)

**Goal: Prove the injection works. Show how the goal is reached. Identify what could go wrong. This begins TOC Question 3.**
**Read first:** `BBiT/core-conflict-injections-and-frt.md` Part 2 (insert CCI → test impact
→ find gaps → add injections → compile solution set; sufficient, not perfect) and
`BBiT/negative-branch-reservations.md` (legitimate vs. fear, grading, injection placement).

The FRT is the CRT transformed by your solution set. It answers: "If we apply these injections, will we actually reach the goal? And what else might they cause?"

### FRT construction rules

1. **Start with the injection(s) at the bottom.** These are your inputs.
2. **Build upward with if-then logic.** For each injection: "If we apply this, then what desirable effect follows? And then what? And then what?"
3. **Validate every single link** with causality test + assumption test + sufficiency test.
4. **Actively hunt for Negative Branch Reservations (NBRs).** Ask: "What else might this injection cause that we haven't thought of?"
5. **Add a preventative injection** for each real NBR. This is not optional.
6. **Confirm the goal is actually reached** — trace all effects up to the final desired state.
7. **Find the gaps.** Move up each causal chain. Stop at any point where existing injections are not sufficient to change the outcome — these spots need additional injections.

### Sufficiency test (unique to the FRT)

For each link: "Is this cause *alone* sufficient to produce this effect — or do we need an additional condition or injection?"

If insufficient: add the missing injection before proceeding.

### FRT structure pattern

```
               [GOAL ACHIEVED — Desired Effect N]
                             |
                   [Desired Effect N-1]
                   /                    \
     [Desired Effect A]       [Desired Effect B]
              |                         |
       [Injection A]             [Injection B]

         ↙ NBR branch (handled by preventative injection)
  [Negative Effect]
       ↑
  [Preventative Injection]
```

### NBR identification prompts — never skip this

- "What else might happen when this injection is applied that we haven't thought of?"
- "Who might react negatively to this change, and what would they do as a result?"
- "What resource or capacity does this injection demand that is currently committed elsewhere?"
- "What existing policy or rule does this injection challenge — and how might that push back?"
- "What is the second-order effect of this change six months out?"

### NBR handling table

| Negative Branch | Legitimate or fear? | Preventative injection |
|----------------|--------------------|-----------------------|
| | | |
| | | |

### Win-win confirmation

- [ ] Injection(s) trace upward to the goal through valid causal steps
- [ ] Both conflicting needs remain satisfied throughout the FRT
- [ ] No new UDEs appear — or each is addressed by a preventative injection
- [ ] The goal is reached (sufficiently — not necessarily perfectly)

After completing: offer an **FRT Excalidraw diagram** (see `diagram-guide.md`).

> **TOC Q3 begun: How to cause the change safely?**

---

## Phase 6 — Remove Obstacles (Prerequisite Tree — PRT)

**Goal: Identify and sequence what must happen before the injection can be fully applied.**
**Read first:** `BBiT/prerequisite-analysis.md` (obstacles → IOs → sequence; 5–10 obstacles;
sufficient not over-sufficient; keep the obstacle beside each IO; the "too many
I-don't-knows" error) and `done-statements-guide.md` for IO wording.

*Use horizontal arrows throughout — PRT uses prerequisite logic, not cause-and-effect.*

**State the goal first** — the future condition that exists when the injection is fully working. Not a task. A condition.

**State obstacles as current conditions**, not missing actions:
- Wrong: "We haven't built the new evaluation process."
- Right: "A standardised evaluation process does not exist."

**State Intermediate Objectives (IOs) as the obstacle being removed:**
"The obstacle no longer exists because [the IO is in place and working]." Word every IO as
a Done Statement — present tense, outcome not action, verifiable by someone outside the team.

Sufficient, not over-sufficient (presales example):
- Over-sufficient: "We are the best discovery team in the industry." Hard, slow, and not needed.
- Sufficient: "Every discovery call is completed with all 9 FTD fields documented."

### PRT structure

| Obstacle (current condition — what exists now that blocks the path) | Intermediate Objective (Done Statement — obstacle removed) | Must precede |
|----------------------------------------------------------------------|----------------------------------------------------------|-------------|
| | | |
| | | Goal state |

**Sequence the IOs** from most foundational to last. Question: "Does this IO need to exist before the next one is achievable?"

### Validation tests for each IO

- **Necessity test:** Does this IO need to exist before the next one can happen? If no, remove the dependency — it is artificially constraining the sequence.
- **Assumption test:** What makes this dependency true? State the assumption. Is it valid?

---

## Phase 7 — Execute (Transition Tree — TT)

**Goal: Turn the plan into executable, logic-anchored steps. This completes TOC Question 3.**
**Read first:** `BBiT/transition-logic.md` (Effect → Action → Logic thinking; forward
planning for unfamiliar territory; the two common errors — insufficient action, and effect
worded as a completed action).

The TT is not a project plan. It is a reasoning structure that guarantees every action is grounded in the current reality and has a clearly articulated mechanism for producing the intended effect. If you cannot explain the *why*, you do not understand the step well enough to execute it.

### Five elements of each TT step (presales example)

| Element | Question | Example |
|---------|----------|---------|
| **Current State (CS)** | What is observably true right now? | "No mutual evaluation plan exists for this opportunity." |
| **Action (A)** | What concrete step do we take next? Must be tied to an IO from the PRT. | "Co-create a mutual evaluation plan with the champion by end of week." |
| **Expected Effect (EE)** | What do we believe will happen as a result? Word this as a **Done Statement**. | "Customer commits to a structured timeline and explicit success criteria." |
| **Why (R — logical reason)** | Why does this action produce this effect? | "Co-creation creates joint ownership. Defined criteria give both parties a shared basis for decision — and signal to the EB that this is a real evaluation, not a fishing exercise." |
| **Actual Effect (AE)** | What actually happened? (Filled in after execution.) | "Evaluation plan signed. EB briefing scheduled for week 3." |

*Never omit the Why. Every step needs a logical explanation. If you skip the Why, you are creating a to-do list, not a Transition Tree.*

Watch for the "effect worded as a completed action" error: "Discovery is done" restates the
action. The real effect is "All 9 FTD questions have confirmed answers documented in the
OSD." Ask: what is different about the world?

### TT table

| CS | Action | EE (Done Statement) | Why (logical reason) | AE (after execution) |
|----|--------|---------------------|----------------------|---------------------|
| | | | | |
| | | | | |
| | | | | |

**After each step:** Use the Actual Effect as the Current State for the next step. This makes the TT a living document.

**When stuck mid-execution:** Return to the CRT or Cloud. Stuckness during execution almost always means the root cause was partially right — or the assumption behind an injection turned out to be stronger than anticipated.

After completing: offer a **TT Excalidraw diagram** (see `diagram-guide.md`).

> **TOC Q3 fully answered: How to cause the change?**

---

## Phase 8 — Necessary Condition Network (NCN)

*Use when PRT + TT need to become a full project plan — with parallel workstreams, resource ownership, and time estimation. Can also be invoked standalone without the full TOC analysis.*
**Read first:** `BBiT/necessary-condition-networks.md` and `ncn-guide.md` (build right to
left, check left to right, resource, level, scale with elapsed time; two hard rules —
prerequisite arrows only, every node a Done Statement).

### NCN vs PRT + TT

| | PRT + TT | NCN |
|--|----------|-----|
| Structure | Linear sequence | Network — parallel chains visible |
| Resources | Not included | Explicitly assigned per node |
| Timing | Not included | Elapsed time per node |
| Node wording | Conditions and actions | Always Done Statements |
| When to use | Single track, simple sequence | Multi-team, parallel workstreams, project planning |

### Node wording — presales examples

| Weak (action) | Stronger (action as done) | Best (true outcome) |
|---------------|--------------------------|---------------------|
| "Submit the mortgage application" | "I have submitted the application" | "The bank has confirmed receipt of my mortgage application" |
| "Run discovery with the customer" | "Discovery is complete" | "All 9 FTD questions have confirmed answers documented in the OSD" |
| "Write the evaluation plan" | "The evaluation plan is written" | "Customer and SC have co-signed a mutual evaluation plan with success criteria" |

### NCN output shape

```
[Start A] ─────→ [Intermediate 1] ─────→
                                          [GOAL]
[Start B] ─────→ [Intermediate 2] ─────→
                       ↑
            [Prerequisite from another chain]
```

Offer an **NCN Excalidraw diagram** (see `diagram-guide.md`). Save to `output/toc/ncn_[topic].excalidraw`.

---

## The 5 Focusing Steps — overlay on the full analysis

After completing the BBiT analysis, map all findings to the 5 Focusing Steps
(`TOC_and_BBiT_Cheat_Sheet.md`). This is the operational layer — it tells you what to do
in what order and why.

| Step | What it asks | Your answer from this analysis |
|------|-------------|-------------------------------|
| **1 — Identify** | What is the system's single constraint right now? | [From CRT root cause] |
| **2 — Exploit** | How do you squeeze more throughput from the constraint using what you already have? No investment yet. | [Quick wins: reduce waste at constraint, prioritise work for constraint, add quality checks before constraint] |
| **3 — Subordinate** | What else in the system needs to change to fully support the constraint? Everything else must feed — never starve or block — the constraint. | [What upstream and downstream changes support exploitation] |
| **4 — Elevate** | If the constraint remains after full exploitation and subordination, what investment or structural change eliminates it entirely? | [From FRT injections requiring new resources or capabilities] |
| **5 — Repeat** | Where is the constraint now? (It moved.) Start again. Do not let old assumptions become the new constraint through inertia. | [Name the next likely constraint after this one is elevated] |

### Exploitation check — before recommending any investment, ask all of these

- "Is the constraint being *starved* by something upstream — intermittent supply, poor handoffs, rework feeding back into it?"
- "Is the constraint being *blocked* downstream — finished work piling up because the next step can't absorb it?"
- "Is the constraint *wasting capacity* on things that don't contribute to system throughput?"
- "Is there good quality work being *lost before* the constraint that could be recovered?"
- "Is the constraint being asked to *process work it shouldn't be doing* at all?"

If any of these are yes, exploiting and subordinating will likely remove the constraint without investment.

---

## Summary output

After completing the analysis, produce this:

```
═══════════════════════════════════════════════════════════════
  TOC + BBiT ANALYSIS
═══════════════════════════════════════════════════════════════
System:         [system being analysed]
Goal:           [what the system is supposed to achieve]

CONSTRAINT
  Type:         Physical / Policy / Paradigm
  Statement:    [the root cause — one specific, observable sentence]
  Assumption:   [the belief sustaining it]

THE CONFLICT (CLOUD)
  Goal:         [what both sides want]
  Need A:       [first side's real need]
  Need B:       [second side's real need]
  The conflict: [why the wants can't coexist]
  Broken by:    [the assumption the injection targets]

THE INJECTION
  Selected:     [the simplest win-win state-change]
  Why it works: [mechanism — how it dissolves the conflict]

FUTURE STATE
  Chain:        [injection → effect → effect → goal, summarised]
  Watch for:    [top NBR + preventative injection]

5 FOCUSING STEPS
  Identify:     [the constraint]
  Exploit:      [quick wins using existing resources]
  Subordinate:  [what else must align to support the constraint]
  Elevate:      [structural change if constraint persists]
  Repeat:       [where the constraint will move next]

FIRST ACTION
  What:         [the single next step]
  Owner:        [who]
  By when:      [date]

DIAGRAMS
  [ ] Assumption Graphic (Cloud)     → output/toc/cloud_[topic].excalidraw
  [ ] Current Reality Tree (CRT)     → output/toc/crt_[topic].excalidraw
  [ ] Future Reality Tree (FRT)      → output/toc/frt_[topic].excalidraw
  [ ] Transition Tree (TT)           → output/toc/tt_[topic].excalidraw
  [ ] NCN (execution network)        → output/toc/ncn_[topic].excalidraw
  [ ] Druid (if recurring conflict)  → output/toc/druid_[topic].excalidraw
═══════════════════════════════════════════════════════════════
```
