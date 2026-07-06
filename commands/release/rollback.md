---
description: Incident rollback playbook — classify the failure, return to the last known-good state safely, verify health, capture the timeline
argument-hint: [what broke, if known]
---

# Release: Rollback

Get production back to a known-good state during an incident — fast, but never blind. Classify the failure first, because rolling back a **data** problem can make things worse; choose the least destructive mechanism; and capture the timeline while memory is fresh. It is **stack-agnostic**: the concrete migration and health commands come from the project's `STACK.md`, not from this file.

## Steps

0. **Resolve the stack.** Read the project's `STACK.md` and resolve commands per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. The schema-rollback step (3) uses each component's `migrate` step (run in its **downgrade** direction via the component's own migration tooling); post-rollback health (6) re-runs the verify steps and the `dev` step per component from that component's `working_dir`. Skip any step a component does not map (not an error). If there is no `STACK.md`, auto-detect once from project markers and recommend the user run `/cc:setup:stack` to persist a manifest. The git and container mechanisms below are tool-agnostic and apply regardless of stack.

1. **Identify the last known-good state.** Find what was running before the bad deploy: `git tag --sort=-creatordate`, `git log --oneline --decorate -20`, the platform's deployment history (GitHub Deployments, Railway/Vercel/Render dashboard), or the running service's `/health` version field. Name the exact tag/commit and confirm it with the user — rolling back to the wrong "good" state doubles the incident.

2. **Classify the failure — this decides everything:**
   - **Code** (bug shipped in the deploy) → rollback helps; proceed.
   - **Config/env** (bad variable, wrong endpoint, expired credential) → fix the config instead; rolling back code will not help and wastes incident time.
   - **Data** (bad migration, corrupted writes, data written under the new schema since deploy) → ⚠️ **rollback may be DANGEROUS**: reverting code or downgrading the schema can orphan or destroy data created since the deploy. Say so explicitly and go to the Abort rules unless a verified preservation plan exists.
   Also gauge blast radius: all users → roll back now; one edge case → a forward hot-fix via `/cc:github:fix` may be safer than rolling back.

3. **Choose the mechanism — least destructive that works:**
   - **Revert commit (preferred):** `git revert <bad-sha> --no-edit` — preserves history, no force-push, redeploys through the normal pipeline.
   - **Redeploy previous artifact:** repoint the platform at the previous image/build/release — often the fastest path, touches no git history.
   - **Reset + force-push (last resort):** only if the user explicitly wants history erased; `git reset --hard <good-sha>` then `git push --force-with-lease` — never bare `--force`.
   - **Migration downgrade:** only if the bad deploy included a migration AND its down-path was actually tested (see `/cc:implement:migrate`) AND no irreplaceable data has been written under the new schema. For each affected component that maps `migrate`, run its migration tooling (the `migrate` command identifies the tool) in the **downgrade** direction from the component's `working_dir`:
     ```
     # Per component (working_dir), via the project's migration tool:
     #   - show current applied revision
     #   - downgrade one step (or to the known-good revision)   # WARNING: may lose data written since deploy
     #   - confirm current revision is back at the known-good one
     ```
     Otherwise leave the schema and roll back code that tolerates it, or stop. Have a database backup before any downgrade.

4. **⛔ Confirm before the destructive step.** Present the plan — exact commands, what they change, what is at risk — and wait for explicit user confirmation before any push, redeploy trigger, or schema downgrade. In an incident, one wrong fast command beats no command at all for damage.

5. **Execute and redeploy.** Run the confirmed mechanism and trigger the deployment the project's normal way (push to the auto-deploying branch, platform redeploy, image push + restart).

6. **Verify health.** The rollback is not done until the system is observably healthy. If the project exposes HTTP health endpoints, hit them at the project's real host/port and paths; otherwise fall back to the per-component verify gate (`smoke` then the `dev` step from each component's `working_dir`) to confirm the known-good build loads:
   ```bash
   # Deployed service — use the project's real base URL and endpoint paths
   curl -s https://<host>/health
   curl -s https://<host>/health/db
   curl -s https://<host>/health/ready
   ```
   Confirm the running version reports the known-good identifier, run smoke checks on critical flows (login, create/read basic resources), and watch error rates settle.

7. **Capture the timeline while fresh.** Record: when deployed, when detected, how detected, when rolled back, when healthy — plus the suspect commit/migration. Create the incident issue:
   ```bash
   gh issue create --title "Production incident: <what went wrong>" \
     --body "Rolled back <sha>. Timeline: <...>. Root cause TBD." \
     --label "incident,critical"
   ```
   Notify the team with status: service health, database integrity, user impact, next steps.

## Post-rollback actions

Rollback restores service; the fix comes later, through the normal loop:

1. **Now:** incident issue created, team notified, timeline captured.
2. **Next hours:** run `/cc:verify:rca` on the suspect commit (`git show <bad-sha>`) — identify the specific bug and why review/tests missed it.
3. **Then:** create a real fix on a branch (never just re-apply the reverted commit), add a regression test for the exact failure, run `/cc:verify:run`, ship via PR.
4. **Retro:** improve detection (monitoring/alerts) and prevention.

## Prevention strategies

Avoid needing rollbacks: staging environment that mirrors production; canary deploys (10% → 100%); feature flags for risky features; blue-green deployment; automated post-deploy smoke tests; alerting on error rate/latency/database metrics; daily (minimum) database backups.

## Output

The system restored to the named known-good state, a health verification summary, an incident issue, and a fresh timeline in the conversation — ready to seed the root cause analysis.

## Quality checklist

- [ ] Known-good state identified by exact tag/commit and confirmed with the user
- [ ] Failure classified (code / config / data) before any action
- [ ] Data-risk called out explicitly when present — no silent schema downgrades
- [ ] Least destructive mechanism chosen; revert preferred over reset
- [ ] User confirmed before the destructive step
- [ ] Health verified after — version, health endpoints (or the per-component `smoke`/`dev` gate), error rate
- [ ] Timeline captured and incident issue created before context evaporates

## Handoff

**Chain:** after a completed, health-verified rollback, immediately invoke `/cc:verify:rca` with the SlashCommand tool, passing the timeline and suspect commit — the post-incident analysis happens while the evidence is fresh.
**Solo:** same — suggest `/cc:verify:rca` next, then a proper fix via the normal loop (never just re-apply the reverted commit).
**Abort rules:** migration downgrade required but the down-path is unverified, or data has been written under the new schema since deploy → **stop**; present the options (restore from backup, forward-fix with `/cc:github:fix`, manual data reconciliation, accept data loss with explicit sign-off) instead of rolling back blindly. Failure classified as config → fix the config, skip the rollback. Rollback itself fails → stop traffic if possible, restore from backup, redeploy the previous working version, and escalate to the user.
