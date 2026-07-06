---
description: Post-commit system review — analyze plan adherence across the loop and improve the process itself
argument-hint: [plan path and/or execution report path — defaults to the newest pair]
---

# System Review

Meta-level review of how well the PIV loop itself performed on the just-committed work. This is **not** code review — you are hunting bugs in the *process*: unclear plans, missing context, gaps in commands, manual steps that should be automated. Run it after `/cc:release:commit`, especially when a chain felt bumpy or divergences repeat. (For an *operational* health check of the running system, use `/cc:verify:system-health` instead.)

**Philosophy:** a *good* divergence reveals a plan limitation → improve planning; a *bad* divergence reveals an unclear requirement → improve communication; a *repeated* issue reveals missing automation → create a command, hook, or gate.

## Steps

1. **Gather the four artifacts:**
   - The plan: `$1` or the newest file in `${user_config.workspace_dir}/plans/`
   - The execution report: `$2` or the matching file in `${user_config.workspace_dir}/execution-reports/`
   - The commands that guided them: `${CLAUDE_PLUGIN_ROOT}/commands/plan/feature.md` and `${CLAUDE_PLUGIN_ROOT}/commands/implement/execute.md`
   Also skim recent files in `${user_config.workspace_dir}/code-reviews/` and `${user_config.workspace_dir}/system-reviews/` to spot *recurring* patterns across iterations.
2. **Reconstruct intended vs actual.** From the plan: what was supposed to happen, with what constraints and validation. From the execution report: what actually happened, what diverged, what was skipped, where fix loops were spent.
3. **Re-examine each divergence at the process level.** The execution report classified them Good ✅ / Bad ❌ — now ask *why the process produced them*:
   - Good divergence → the plan was missing knowledge. What should `/cc:plan:feature` or `/cc:prime` have surfaced?
   - Bad divergence → the instruction failed. Was the constraint unclear, buried, or unenforced by any validation gate?
4. **Trace recurring patterns to root causes.** One-off issues are noise; a divergence, fix-loop trigger, or review finding appearing across 2+ iterations is a process bug. For each: unclear plan? missing context? missing validation gate? manual step repeated?
5. **Score overall alignment (1–10):** 10 = perfect adherence or fully justified divergences; 4–6 = mixed; 1–3 = major problematic divergences.
6. **Propose concrete improvements** — only where a pattern repeats, and always with the actual text to add or change:
   - **CLAUDE.md** — pattern/anti-pattern to document, constraint to state
   - **Command updates** — which command file (`${CLAUDE_PLUGIN_ROOT}/commands/*.md`), which instruction, the proposed wording
   - **New automation** — a command, hook, or validation check for any manual step repeated 3+ times
7. **Save** to `${user_config.workspace_dir}/system-reviews/<plan-name>.md`. With the user's agreement, apply the CLAUDE.md/command edits immediately — that is the point of the review.

## Output

`${user_config.workspace_dir}/system-reviews/<name>.md`:

```markdown
# System Review: <Feature>
**Plan:** <path> | **Execution report:** <path> | **Date:** YYYY-MM-DD

## Alignment Score: N/10

## Divergence Analysis
<!-- one block per divergence from the execution report -->
```yaml
divergence: <what changed>
planned: <what the plan specified>
actual: <what was implemented>
reason: <agent's stated reason from the report>
classification: good ✅ | bad ❌
root_cause: unclear plan | missing context | missing validation | repeated manual step
```

## Pattern Compliance
- [ ] Followed existing codebase architecture
- [ ] Used documented patterns (CLAUDE.md)
- [ ] Applied testing patterns correctly
- [ ] Met the plan's validation requirements

## Recurring Patterns      ← issues seen across 2+ iterations
## Improvement Actions     ← CLAUDE.md / command / automation changes, with proposed text
## Key Learnings           ← what worked, what to change next loop
```

## Quality checklist

- [ ] Reviewed the process, not the code — no code findings here
- [ ] Every problematic divergence traced to a specific process root cause
- [ ] Improvements proposed only for repeating patterns, not one-offs
- [ ] Every improvement names the exact file and the text to add or change
- [ ] Saved to `${user_config.workspace_dir}/system-reviews/<name>.md`

## Handoff

**Chain:** none — this is the optional final step after `/cc:release:commit`; the chain ends here.
**Solo:** offer to apply the proposed CLAUDE.md/command updates now; otherwise the actions list stands as the backlog for the next loop.
**Abort rules:** if no execution report exists for the work, stop and run `/cc:verify:execution-report` first — a system review without it is guesswork. If artifacts show no divergences and validation was first-pass green, write a brief "no action needed" review and stop.
