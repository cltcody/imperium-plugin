---
description: Scan the curated trade-regulatory source map for MAJOR/ROUTINE changes since the last run and produce a triaged digest. Use when the ask is "what changed in trade regs this week" or "run the regulatory radar"
argument-hint: [--sources <filter>]
model: sonnet
---

# Radar: Scan

Check every source in the curated trade-regulatory watch list for changes since the last
scan, classify each by decision impact, and produce a MAJOR-first digest. Dual-use: dev
reads it for code/data impact, presales reads it for account impact — this command only
detects and classifies; `/cc:radar:impact` and `/cc:radar:brief` do the follow-through.

`$ARGUMENTS` — optional `--sources <filter>` to restrict the run to a subset (e.g.
`--sources OFAC,BIS` or `--sources EU`). Match against the source's name or jurisdiction in
the index below; no match → run all 12.

**Where state and digests live:** `radar/state.json` and `radar/digests/` resolve against
the deals workspace per the Command Integration Contract in
`${CLAUDE_PLUGIN_ROOT}/references/presales/deals-workspace.md` (config → env → default
`~/code/deals-workspace`; offers to create if absent; never falls back to cwd or this
repo). This is the one baseline, singular across every cwd and machine — never per-repo
state. In a `corporate`-classed repo (`${CLAUDE_PLUGIN_ROOT}/references/dev/repo-classification.md`),
print the one-line redirect notice before writing — the destination is the workspace
either way.

## Steps

1. **Load the source map.** Read
   `${CLAUDE_PLUGIN_ROOT}/references/domains/trade/regulatory-sources.md` in full — the
   source index (12 sources), each source's URL/Re-find/cadence/vectors, and the
   change-significance rubric at the bottom. This file is the only source of truth for what
   to check and how to score it; do not improvise sources or tiers.

2. **Load or initialize state.** Read `<deals-workspace>/radar/state.json` (resolved per the
   Command Integration Contract, above):
   ```json
   {
     "sources": {
       "<source-name>": {
         "last_checked": "<ISO-8601 timestamp>",
         "last_known_items": ["<short id/summary of each item seen, most recent scan>"]
       }
     }
   }
   ```
   If the file doesn't exist, this is the **first run**: say so explicitly in the output,
   create the directory/file after step 6, and treat every source as having no prior
   baseline (nothing to diff against — items observed this run are logged as the baseline,
   not reported as changes, since "change since last run" is undefined on run 1).

3. **Check each in-scope source.** Apply `--sources` filtering here. For each source:
   - **WebFetch** the source's URL.
   - If the fetch fails (network-blocked host, dead link, drifted URL, non-content
     response): follow the source's documented **Re-find** protocol — WebSearch the
     documented search phrase against the documented publishing organization. If the
     Re-find search recovers a working URL that differs from the one on file, note the
     drift (for the digest and for a follow-up edit to `regulatory-sources.md` — flag it,
     don't edit the reference file yourself from inside a scan).
     If Re-find also fails to produce a usable source, mark that source **UNREACHABLE** for
     this run and move on — never substitute a guess for its content.
   - Extract the current state of "what changes there" (per the source's description):
     recent notices, list entries, docket items, measure updates, etc.

4. **Diff against state.** Compare what was just fetched/found to `last_known_items` for
   that source. Every item present now but absent from the baseline is a **candidate
   change**. An unchanged source (fetched successfully, nothing new found) is reported as
   **"no change"** — never omitted and never reported as a change to pad the digest.

5. **Classify every candidate change** using the change-significance rubric in
   `regulatory-sources.md`: MAJOR / ROUTINE / NOISE, using the worked examples as calibration
   anchors. Apply the escalation modifiers:
   - **Watchlist proximity** — if `<deals-workspace>/accounts/watchlist.md` exists, check
     whether the change's HS chapters/origins/parties touch any watched account's
     annotations; if so, promote that change to MAJOR *for those accounts* and name them.
     No watchlist present → skip this modifier silently (not an error).
   - **Effective-date compression** — effective in <14 days → move up one tier.
   - **Stacking** — several ROUTINE changes converging on one lane this scan → surface
     together with a note, even though each is individually ROUTINE.
   When a change sits between two tiers, classify **up** and say why (per the rubric's own
   instruction).

6. **Update state** — but only *after* the digest in step 7 has been produced and shown.
   Write `<deals-workspace>/radar/state.json` with each checked source's new `last_checked`
   timestamp and `last_known_items` refreshed to what was just observed (UNREACHABLE sources
   keep their prior `last_known_items` and `last_checked` — don't overwrite a baseline you
   couldn't actually verify).

7. **Produce the digest** (see Output) — MAJOR items first, then ROUTINE, then a one-line
   NOISE/no-change/UNREACHABLE roll-up. Never fabricate a change: if a source's content is
   genuinely unclear (partial fetch, ambiguous diff), say so and classify conservatively
   rather than asserting a tier.

## Output

```
TRADE REGULATORY RADAR — <date>
Sources checked: <N>/12   Filter: <--sources value or "none">
State: <first run — baseline created / diffed against <prior last_checked>>

🔴 MAJOR
[source] <what changed> — effective <date, or "not yet effective">
  Scope: <HS chapters / origins / parties / lanes affected>
  Suggested next step: /cc:radar:impact (dev — codebase/reference-data impact)
                        /cc:radar:brief (accounts — customer-facing angle)

🟡 ROUTINE
[source] <what changed> — <one line>
  ...

⚪ NO CHANGE / LOGGED
<source>: no change
<source>: N NOISE items logged, not surfaced
<source>: UNREACHABLE — fetch failed, Re-find failed (<what was tried>)

Escalations applied: <watchlist promotions, date-compression bumps, stacking notes — or "none">
```

Digest goes to the conversation. When the digest contains any MAJOR item, also save a copy
to `<deals-workspace>/radar/digests/radar-scan-<date>.md` per the Command Integration
Contract — never to this repo's own reports directory.

## Quality checklist

- [ ] Every one of the 12 sources (or the `--sources`-filtered subset) is accounted for —
      MAJOR, ROUTINE, no-change, NOISE-logged, or UNREACHABLE — none silently skipped
- [ ] Every classified change points at the specific rubric tier and, when non-obvious, says
      why (mirroring the rubric's worked-example style)
- [ ] Escalation modifiers (watchlist proximity, date compression, stacking) checked and
      applied where they fire, not just defined
- [ ] No change reported without a real diff against `last_known_items` — first run never
      reports fabricated "changes"
- [ ] Unreachable sources went through the Re-find protocol before being marked UNREACHABLE
- [ ] `state.json` updated only after the digest was produced, and only for sources actually
      verified this run

## Handoff

**Chain:** none — this is a solo entry point (see `${CLAUDE_PLUGIN_ROOT}/references/dev/scheduling.md` for running it unattended on a schedule).
**Solo:** MAJOR item with clear codebase/reference-data surface (HS codes, rate tables, sanctioned-party lists in fixtures or config) → suggest `/cc:radar:impact` with that digest entry. MAJOR or watchlist-promoted item with account relevance → suggest `/cc:radar:brief` with that digest entry. Recurring UNREACHABLE source → suggest updating that source's URL in `${CLAUDE_PLUGIN_ROOT}/references/domains/trade/regulatory-sources.md` once Re-find has found the new location.
**Abort rules:** every in-scope source is UNREACHABLE (Re-find exhausted on all of them) → stop, report the outage plainly, do not write a digest of nothing, and do not update `state.json` for sources that were never actually checked.
