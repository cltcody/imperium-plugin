# Findings Ledger

The shared memory for **recurring audit commands** (`/cc:verify:a11y`, and any future
recurring scan that opts in). An audit with no memory re-reports the same accepted
findings on every run; the report becomes wallpaper, the one new CRITICAL drowns in 30
old MEDIUMs, and the habit of running the audit dies. The ledger gives runs memory: new
findings surface loudly, known ones stay quiet, accepted ones carry their reason and
owner, and silent regressions get caught the run they reappear.

Consuming commands do **not** define their own ledger variants — they implement the
contract below exactly and reference this file. If a command's local text contradicts
this reference, this reference wins.

---

## The ledger file

**Location:** `${user_config.workspace_dir}/audits/ledger.jsonl` — one JSON record per
line, one record per finding identity (`fingerprint` is the unique key). All recurring
commands share the single file; records are namespaced by `command`.

| Field | Required | Meaning |
|-------|----------|---------|
| `fingerprint` | always | 16 hex chars — stable identity (see below) |
| `command` | always | Emitting command id, e.g. `"verify:a11y"` |
| `rule` | always | Stable rule id from the command's catalog, e.g. `"a11y.img-alt"` |
| `file` | always | Repo-relative path of the finding |
| `severity` | always | `CRITICAL` \| `HIGH` \| `MEDIUM` \| `LOW` — current rating, updated in place if the command recalibrates |
| `status` | always | `new` \| `known` \| `accepted` \| `fixed` \| `regressed` |
| `first_seen`, `last_seen` | always | ISO dates (`YYYY-MM-DD`) |
| `accepted_reason`, `accepted_by` | accepted only | Why, and who decided |
| `accepted_until` | optional (accepted) | ISO expiry date; once past, the acceptance lapses |

The ledger stores **no code snippets** — evidence is hashed into the fingerprint, never
recorded. Example records:

```jsonl
{"fingerprint":"cc588b12efb30c08","command":"verify:a11y","rule":"a11y.img-alt","file":"src/components/Hero.tsx","severity":"HIGH","status":"known","first_seen":"2026-06-02","last_seen":"2026-07-06"}
{"fingerprint":"9a1f0e2d4c6b8a35","command":"verify:a11y","rule":"a11y.contrast","file":"src/theme/tokens.css","severity":"MEDIUM","status":"accepted","first_seen":"2026-05-12","last_seen":"2026-07-06","accepted_reason":"brand gray pending Q3 redesign","accepted_by":"cody","accepted_until":"2026-09-30"}
```

---

## Fingerprint

`fingerprint` = **first 16 hex chars of `sha256("command|rule|file|normalized_evidence")`**.

`normalized_evidence` is the matched snippet with:
1. all whitespace runs collapsed to a single space, then trimmed;
2. volatile parts removed — line/column numbers, timestamps, dates, hashes/ids,
   counters — anything that changes while the finding itself does not.

Line numbers are deliberately **not** part of the identity, so the fingerprint survives
line drift (code added above the finding). Renaming the file or editing the offending
element changes the fingerprint — the old record goes `fixed`, the new one appears as
`new`; that is accepted behavior, not a bug.

**Worked example.** The a11y scan matches this line 42 snippet in `src/components/Hero.tsx`:

```
      <img src={hero}   className="hero-img" />   // line 42
```

Normalized evidence (whitespace collapsed, the volatile `// line 42` dropped):
`<img src={hero} className="hero-img" />`. Then:

```bash
# shasum -a 256 on macOS; sha256sum on Linux
printf '%s' 'verify:a11y|a11y.img-alt|src/components/Hero.tsx|<img src={hero} className="hero-img" />' | shasum -a 256 | cut -c1-16
# → cc588b12efb30c08
```

---

## Lifecycle per run

Reconcile only records matching **this command** whose `file` lies inside the scope
actually scanned (a diff-scoped run must never mark out-of-scope entries fixed; only a
full run may close entries repo-wide).

| This run finds | Ledger says | Write back | Report as |
|---|---|---|---|
| finding | no entry | append `new`, `first_seen`=`last_seen`=today | **[NEW]** |
| finding | `new` / `known` | `known`, update `last_seen` | [KNOWN] |
| finding | `accepted`, unexpired | update `last_seen` | [ACCEPTED] + reason |
| finding | `accepted`, `accepted_until` past | revert to `known`, update `last_seen` | [KNOWN] — note the lapsed acceptance |
| finding | `fixed` | `regressed`, update `last_seen` | **[REGRESSED]** — report prominently |
| finding | `regressed` | `known`, update `last_seen` | [KNOWN] (regression was reported once) |
| nothing | any non-`fixed` entry in scope | `fixed` (record kept — it powers regression detection) | one line in the summary |

**Acceptance is always user-driven.** After presenting findings, the command offers
"accept finding N with reason … [until YYYY-MM-DD]"; only an explicit user instruction
in that session sets `accepted` (+ `accepted_reason`, `accepted_by` from
`git config user.name` or asked, optional `accepted_until`). Never auto-accept.
Accepted findings drop out of verdict math — **except CRITICAL, which never drops out**
(per `${CLAUDE_PLUGIN_ROOT}/references/dev/severity-and-rubrics.md`, a CRITICAL stops
everything; acceptance changes its annotation, not the gate).

## Modes

- **Default (full report):** every reported finding annotated
  `[NEW]` / `[KNOWN]` / `[ACCEPTED]` / `[REGRESSED]`, plus a ledger footer with counts.
- **`--delta`:** detail only **NEW + REGRESSED**; compress the rest to one line, e.g.
  `Δ 2 new · 1 regressed | suppressed: 14 known · 3 accepted · 5 fixed this run`.
  The **verdict is still computed over all open findings** — delta changes reporting,
  never the gate.
- **No ledger present:** run ledger-less (no annotations), then offer to initialize
  `${user_config.workspace_dir}/audits/ledger.jsonl` seeded from this run's findings
  (all `new`). Create it only on an explicit yes.

---

## Findings ledger integration (recipe for consuming commands)

The read → scan → reconcile → write-back loop. Commands reference this section instead
of restating it.

1. **Read.** If `${user_config.workspace_dir}/audits/ledger.jsonl` is missing → ledger-less
   mode (above). Otherwise load this command's records:

   ```bash
   ledger="<workspace_dir>/audits/ledger.jsonl"
   jq -c 'select(.command == "<command-id>")' "$ledger"
   ```

2. **Scan.** Run the command's own checks as usual, producing candidate findings — each
   with `rule`, `file`, matched evidence snippet, and severity.

3. **Reconcile.** For each candidate: normalize the evidence, compute the fingerprint
   (worked example above), look it up, and apply the lifecycle table — collect the
   annotation for the report and the field updates for the record. Update `severity` in
   place when the rating changed. Then the reverse pass: every in-scope, non-`fixed`
   ledger record of this command that no candidate matched → `fixed`.

4. **Write back atomically.** Rewrite the file via temp + move; never touch other
   commands' records; keep records sorted by fingerprint for stable diffs:

   ```bash
   tmp="$(mktemp)"
   jq -c -s '<apply updates> | sort_by(.fingerprint) | .[]' "$ledger" > "$tmp" && mv "$tmp" "$ledger"
   ```

5. **Report.** Annotate per mode (default vs `--delta`), print the ledger footer
   (`N new · M known · K accepted · J fixed · R regressed`), compute the verdict over
   open (non-accepted, plus any CRITICAL) findings, then offer acceptance for findings
   the user wants to register.

## Commit the ledger

**Commit `audits/ledger.jsonl`.** It is a shared risk-acceptance register: acceptances
(who, why, until when) are team decisions that belong in history, ledger diffs make risk
acceptance reviewable in PRs, and fixed/regressed detection only works if the ledger
travels with the repo. It contains paths and hashes, never code.

*Alternative:* if `${user_config.workspace_dir}` is gitignored in a given project, the
ledger is per-machine memory — acceptances don't transfer and regression history resets
per clone. Acceptable for solo work; the command should then note "ledger is local-only"
in its report footer.
