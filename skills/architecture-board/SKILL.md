---
name: architecture-board
description: |
  Pre-deploy architecture board — UX, AI, and systems heads review the release together and return
  one GO/NO-GO (decision support, not a substitute for the team's call). Use on "architecture review", "deploy board", "are we ready to ship", or from
  /cc:release:deploy.
---

# Architecture Review Board

Three architectural heads review a release **together** and argue to a single
GO/NO-GO. The value is in the conflicts between them — that's where the real
decision lives. Relevance-gated: a head with no surface in the release abstains.

This is the dev-side instantiation of the shared **council pattern**
(`${CLAUDE_PLUGIN_ROOT}/references/life/council-pattern.md`): the heads are its hats and the
moderator synthesis is its conflict-resolution step. The steps below are the concrete roster
(UX / AI / systems) and the GO/NO-GO output for a release.

## Step 1 — What's shipping

Gather (don't re-ask what's known): the change-set/scope, target environment,
what's new vs. changed, known risks, and rollback path. Decide which heads are in
scope (user-facing surface? AI surface? cross-system seam?); abstaining heads say
so explicitly.

## Step 2 — The head round

Each in-scope head delivers: **analysis from its lens · readiness call
(GO / GO-with-fixes / NO-GO) · blind spot · 1–2 questions back**. A head may
delegate evidence-gathering to its subagent (via `/cc:verify:design`) but the
board drives the deliberation. No head ignores the others.

- 🎨 **UX head** — can users actually succeed with what's shipping? States, flows, accessibility, copy. Blind spot: ignores the system cost of the experience it wants.
- 🤖 **AI head** — is the AI safe, measurable, and affordable in production? Injection, eval, failure modes, cost/latency. Blind spot: over-engineers safety where deterministic logic would do.
- 🏗️ **Systems head** — will the integration hold under load and failure? Coupling, data consistency, migration ordering, contracts. Blind spot: blocks on theoretical scale the release won't hit yet.

## Step 3 — Moderator synthesis

1. **Consensus** — what all heads agree on.
2. **Conflicts** — where they disagree (e.g. UX wants a sync flow, Systems wants async), and which wins **in this release's context**, with reasoning.
3. **Verdict** — one GO / NO-GO, with the blocking items if NO-GO.
4. **Before deploy** — the concrete must-dos.

## Step 4 — Output

```
ARCHITECTURE BOARD — [release]
══════════════════════════════════════
Shipping: [1 line] · Target: [env] · Heads: 🎨 🤖 🏗️ (N/A: …)

HEADS
🎨 UX       — [call + one line]
🤖 AI       — [call + one line]
🏗️ Systems  — [call + one line]

CONFLICTS
• [Head A] vs [Head B]: [what] → [resolution]

VERDICT: 🟢 GO  /  🔴 NO-GO
BLOCKING (if NO-GO)
1. [item → owner/route]

BEFORE DEPLOY
- [must-do]
```

## Modi

- **Full board** (default) — all in-scope heads + synthesis.
- **Single head** — one lens on request.
- **Quick check** — one line per head + verdict, for a small release.

## Quality checklist

- [ ] Relevance decided per head; abstentions explicit
- [ ] Each head gives a readiness call AND its blind spot
- [ ] At least one real conflict named and resolved (not smoothed over)
- [ ] Exactly one GO/NO-GO; NO-GO lists blocking items with routes
- [ ] Verdict reflects this release's context, not generic best practice
