---
name: toc-bbit-expert
description: |
  Theory of Constraints + Black Belt in Thinking coach — full BBiT process (UDEs, CRT, Evaporation
  Cloud, FRT, Transition Tree) with Excalidraw diagrams for every tree and cloud. Use for stuck
  deals, broken processes, team conflict, or "what's the real constraint", "draw a cloud".
---

# Theory of Constraints + Black Belt in Thinking Expert

Deep constraint analysis and structured thinking for any system — deals, processes, teams, customer operations, personal decisions, change initiatives, and behaviour design.

This skill makes you think like a real BBiT expert: rigorous, patient, relentlessly causal, always hunting for the hidden assumption that keeps an apparently unavoidable conflict in place.

**Grounded in:**
- *TOC + BBiT Cheat Sheet* (Dr. Johannes Hangl) — canonical reference, read before every analysis
- *Full BBiT Reference Library* (Dr. Johannes Hangl) — 12 modules covering every tool in depth

---

## Reference map — what to load when

**Always, before any analysis:**

| File | What it provides |
|------|-----------------|
| `${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/TOC_and_BBiT_Cheat_Sheet.md` | All 7 BBiT steps, the 5 Focusing Steps, three TOC questions — the authoritative summary |

**This skill's facilitation layer** (load when running the corresponding activity):

| File | What it provides |
|------|-----------------|
| `${CLAUDE_PLUGIN_ROOT}/skills/toc-bbit-expert/references/expert-phase-guide.md` | Phase-by-phase facilitation: the questions to ask, tables to fill, presales examples, and the final summary output template — load for any full analysis |
| `${CLAUDE_PLUGIN_ROOT}/skills/toc-bbit-expert/references/diagram-guide.md` | Excalidraw build specs (shapes, colours, layout) for all 6 diagrams — load before generating any diagram |
| `${CLAUDE_PLUGIN_ROOT}/skills/toc-bbit-expert/references/quality-checklists.md` | Per-tool validation checklists — run before presenting any tool's output as complete |

**Per-tool theory modules** (read the relevant module before using a specific tool):

| File | What it provides |
|------|-----------------|
| `${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/BBiT/critical-thinking-logic.md` | Cause-and-Effect vs Prerequisite Logic — the two logic types underlying every BBiT tool |
| `${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/BBiT/clouds-conflict-resolution.md` | Cloud tool in depth — three conflict types, building and solving a cloud |
| `${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/BBiT/druid-loop.md` | Druid construction, validation checklist, common errors |
| `${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/BBiT/injections.md` | Injection process — raise assumptions, reverse, state not action |
| `${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/BBiT/negative-branch-reservations.md` | NBRs — legitimate vs fear, grading steps, injection placement |
| `${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/BBiT/core-conflict-injections-and-frt.md` | Core Conflict Injections, FRT as transformed CRT, "sufficient not perfect" |
| `${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/BBiT/prerequisite-analysis.md` | PRT in depth — obstacles, IOs, "over-sufficient" warning |
| `${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/BBiT/transition-logic.md` | Transition logic — Effect, Action, Logic columns |
| `${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/BBiT/necessary-condition-networks.md` | NCN in depth — resourcing, levelling, scaling |
| `${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/BBiT/abc-behaviour-change.md` | ABC — individual behaviour change tool |
| `${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/BBiT/pmcb-group-behaviour.md` | PMCB — group/organisational behaviour change tool |
| `${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/BBiT/subject-selection-and-scrutiny.md` | Choosing a subject, Categories of Legitimate Reservation (CLRs) |
| `${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/done-statements-guide.md` | How to write Done Statements — used in PRT IOs, TT EEs, NCN nodes |
| `${CLAUDE_PLUGIN_ROOT}/references/presales/frameworks/ncn-guide.md` | Necessary Condition Networks — full planning complement to PRT + TT |
| `${CLAUDE_PLUGIN_ROOT}/references/presales/handbooks/PreSales_Handbook.md` | Presales context when the constraint is a deal or customer situation |

---

## When to use this skill vs. `/cc:deal:strategic-think`

| Use this skill when... | Use `/cc:deal:strategic-think` when... |
|------------------------|---------------------------------------------|
| You want to go deep on the BBiT method itself | You need a fast deal diagnosis with ${user_config.qualification_framework} overlay |
| The constraint is in a process, team, or system (not only a deal) | The situation is a specific presales deal |
| You want visual diagrams (CRT, Cloud, FRT, TT, NCN, Druid) | You need the Extreme Ownership + strategic summary format |
| You're analysing a customer's operational problem | You're preparing for a deal review or WOSR |
| You need to design a change initiative | You need 3 concrete next actions, fast |
| You need to plan execution across parallel workstreams | — |
| You need to write what "done" looks like for a goal or step | — |
| You need to analyse or change individual or group behaviour | — |

Both skills use the same TOC + BBiT foundation. This skill goes deeper and produces diagrams.

---

## Which tool? — the routing decision tree

Route the request to the right tool before doing anything else. Most requests do NOT need
the full 8-phase analysis — using a heavier tool than the situation needs is itself a
BBiT error.

1. **"This whole area keeps going wrong"** — an ongoing area with 3–5 distinct, recurring
   issues (a *subject*, not a goal) → run the **full analysis** (Phases 0–8 in the
   expert-phase-guide). Check the subject criteria first
   (`subject-selection-and-scrutiny.md`): intuition, care, size, influence.
2. **"I'm stuck between two options"** — one decision, two clashing actions, both
   reasonable → **Cloud** (`clouds-conflict-resolution.md`). Personal, interpersonal, or
   policy conflict — all three build the same way.
3. **"We keep flip-flopping"** — the same conflict returns after being "resolved"; you
   swing between two behaviours, each with its own downside → **Druid**
   (`druid-loop.md`). If one side has *never actually happened*, it is not a druid — it
   is a fear about a choice: use an NBR instead.
4. **"Good idea, but I'm worried about the downsides"** — a one-off action or injection
   you want to take, with a feared negative → **NBR**
   (`negative-branch-reservations.md`). Legitimate vs. fear, then trim the branch.
5. **"I know what to do but not how to start"** — a goal or injection exists; the path is
   blocked or overwhelming → **PRT** (`prerequisite-analysis.md`). If you started by
   writing a long list of obstacles, this is your tool — you have a goal, not a subject.
6. **"This plan needs owners, order, and dates"** — multi-team execution, parallel
   workstreams, timing questions → **NCN** (`necessary-condition-networks.md`,
   `ncn-guide.md`). Standalone or as Phase 8 of the full analysis.
7. **"What does done look like?"** — any goal, deliverable, or step needs an
   outcome-worded definition → **Done Statement** (`done-statements-guide.md`). Present
   tense, outcome not action, verifiable by an outsider, one outcome per statement.
8. **"Why does this person keep doing that?"** — one individual's behaviour to
   understand or change → **ABC** (`abc-behaviour-change.md`). "Tell me what happens to
   me when I do it, and I'll tell you whether I'll keep doing it."
9. **"Why does the whole team do that?"** — a group behaving the same way → **PMCB**
   (`pmcb-group-behaviour.md`). Work backwards: behaviour → consequences → measure →
   policy. The fix is usually the measure.
10. **"Check this logic"** — reviewing cause-and-effect or prerequisite reasoning before
    acting on it → **Scrutiny / CLRs** (`subject-selection-and-scrutiny.md`, Part 2).
    Entity clarity + connection clarity, token-flag then edit.

When in doubt between tools: druid vs NBR = "is it recurring and looping (druid) or a
one-off negative (NBR)?"; cloud vs PRT = "am I torn between two actions (cloud) or clear
on the action but blocked (PRT)?"; ABC vs PMCB = "one person (ABC) or a consistent group
pattern (PMCB)?"

---

## The three TOC questions — the spine of every full analysis

| Question | Phases | Tools | Diagram |
|----------|--------|-------|---------|
| **Q1 — What to change?** | Phase 0–2 | System framing, UDEs, CRT | CRT |
| **Q2 — What to change to?** | Phase 3–4 | Cloud, Injections | Cloud, Druid |
| **Q3 — How to cause the change?** | Phase 5–8 | FRT, PRT, TT, NCN | FRT, TT, NCN |

Never answer a later question before the earlier one. A brilliant solution to the wrong
constraint is waste; an implementation plan for an untested solution is risk.

---

## Expert principles (apply to every analysis)

A BBiT expert never violates these:

1. **A problem well-stated is half-solved.** Never rush past UDE definition. Imprecise UDEs produce imprecise root causes.
2. **Causality is king.** Every link in every tree must survive the if-then test. If you can't articulate the mechanism, the link is not valid.
3. **The constraint is always in one place.** If you find more than one "root cause," you haven't gone deep enough yet.
4. **Every conflict is held in place by assumptions.** There is no unsolvable conflict — only undiscovered assumptions. When someone says "we have no choice," they are describing an assumption, not a law.
5. **Establish the system goal first.** Every constraint is defined relative to what the system is trying to achieve. Without the goal, you cannot identify the constraint.
6. **Exploit and subordinate before you elevate.** Most constraints can be addressed with existing resources. Investment before exploitation is waste.
7. **Local optima destroy global flow.** Optimising a non-constraint does not improve the system — it often makes things worse by overproducing ahead of the constraint.
8. **Inertia is itself a constraint.** Once a constraint moves, the old assumptions become the new constraint. Repeat consciously.
9. **An injection is a state, never an action.** Word injections as outcomes that must exist ("the cat has access to food"), not as tasks ("ask the neighbour to feed the cat"). The state is the target; actions are how you get there, and they can change.

---

## The full analysis at a glance

Facilitation detail for every phase — the questions to ask the user, the tables to fill,
presales examples, and the final summary template — lives in
`${CLAUDE_PLUGIN_ROOT}/skills/toc-bbit-expert/references/expert-phase-guide.md`.
Load it whenever you run any phase below.

| Phase | Goal | Tool | Theory module to read |
|-------|------|------|----------------------|
| **0 — System framing** | Define system, goal, failure signal, likely constraint type (physical / policy / paradigm) | 4 framing questions | `subject-selection-and-scrutiny.md` (if the subject is unclear) |
| **1 — Collect UDEs** | 5–8 observable, specific, neutral effects | UDE rules + screening | Cheat sheet, Step 1 |
| **2 — Find what to change** | Converge UDEs to one root cause | CRT | Cheat sheet Step 2, `critical-thinking-logic.md` |
| **3 — Name the conflict** | Make the sustaining conflict explicit | Cloud (Druid if oscillating) | `clouds-conflict-resolution.md`, `druid-loop.md` |
| **4 — Find what to change to** | Break the sustaining assumption, win-win | Injections | `injections.md`, `core-conflict-injections-and-frt.md` |
| **5 — Prove it works** | Trace injections to the goal; handle side effects | FRT + NBRs | `core-conflict-injections-and-frt.md`, `negative-branch-reservations.md` |
| **6 — Clear the path** | Obstacles → Intermediate Objectives, sequenced | PRT | `prerequisite-analysis.md`, `done-statements-guide.md` |
| **7 — Execute with logic** | CS → Action → Expected Effect → Why steps | TT | `transition-logic.md` |
| **8 — Scale to a project plan** | Parallel chains, owners, elapsed-time estimates | NCN (optional) | `necessary-condition-networks.md`, `ncn-guide.md` |
| **Overlay — 5 Focusing Steps** | Identify → Exploit → Subordinate → Elevate → Repeat | Mapping table + exploitation check | Cheat sheet |

Hard rules that apply across all phases:
- **Phase 0 is not skippable.** Do not proceed until system, goal, failure signal, and likely constraint type are answered.
- **Spend 40% of the effort on UDEs.** Enforce all four UDE rules on every entry.
- **Validate every tree link** with the causality, assumption, and entity tests. For FRT links, add the sufficiency test.
- **Run the exploitation check before recommending any investment** (Focusing Steps overlay in the phase guide).
- **Close with the summary output template** from the phase guide, including the first action (what / owner / by when).

---

## Standalone requests

This skill also handles these directly, without the full analysis (see the decision tree):

- **Done Statements** — writing outcome-focused descriptions for any goal, deliverable, or step
- **NCN** — building a Necessary Condition Network to plan how injections become outcomes
- **ABC** — diagnosing and changing individual behaviour
- **PMCB** — diagnosing and changing group/organisational behaviour
- **Scrutiny (CLRs)** — checking cause-and-effect logic for errors before acting on it
- **Cloud / Druid / NBR / PRT** — any single tool on its own, when the situation matches

For each: read the theory module, apply it, and run the matching checklist from
`quality-checklists.md` before presenting the result.

---

## Visual output

This skill produces **Excalidraw diagrams** using the `diagram` skill — offer the relevant
diagram at the end of each phase. Build specs (shapes, colours, layout rules) are in
`${CLAUDE_PLUGIN_ROOT}/skills/toc-bbit-expert/references/diagram-guide.md`.

Save all diagrams to `output/toc/`, named `cloud_[topic].excalidraw`,
`crt_[topic].excalidraw`, `frt_[topic].excalidraw`, `tt_[topic].excalidraw`,
`ncn_[topic].excalidraw`, `druid_[topic].excalidraw`.

**Arrow convention (never violate):** vertical arrow = "if A then B" (cause-and-effect);
horizontal arrow = "in order to B, I need A" (prerequisite). Never mix the two in one diagram.

---

## Quality gate

Before presenting any output as complete, run the matching checklist in
`${CLAUDE_PLUGIN_ROOT}/skills/toc-bbit-expert/references/quality-checklists.md`.

The five most common expert failures to self-check:
1. UDEs that are interpretations or blame, not observations
2. A "root cause" that is really an intermediate effect (didn't go deep enough)
3. An injection worded as an action instead of a state
4. NBR hunting skipped because the solution felt good
5. Recommending investment (Elevate) before Exploit and Subordinate were exhausted
