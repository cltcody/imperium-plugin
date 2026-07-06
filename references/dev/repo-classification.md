# Repo Classification & Corporate Safeguards

How cc commands decide **what kind of repo they are standing in** — `personal`, `corporate`,
or `shared-oss` — and what each class permits: where artifacts write, what is refused, what
warns. Detection runs in `/cc:setup:project` / `/cc:setup:stack`; enforcement lives in the
commands themselves plus one backstop hook (specified below). The single source of truth for
a repo's class is the `class:` field in its root `STACK.md`.

> **This document encodes confidentiality policy.** Every rule here is a judgment call made
> on the owner's behalf, written fail-safe, and individually overridable. The
> [owner-review checklist](#owner-review-checklist) at the end lists each call as a
> one-liner to confirm or amend **before** Phase 2 enforces any of it.

---

## Why the distinction exists — the artifact-leak failure mode

Sales commands historically wrote their outputs into `[WORKSPACE_DIR]/` under whatever repo
you happened to be sitting in. Run an exposure brief while your cwd is a work project and
the result is a named customer, their risk posture, and your deal thinking sitting as a
plain markdown file inside your employer's tracked tree — one habitual `git add -A && git
push` away from the corporate remote, visible to every colleague with read access, and
effectively unrecallable once pushed. The same shape of accident applies to radar state,
session cursors, and memory-sync links. Classification exists so that the *machine* knows
which trees must never receive that content, instead of relying on the human remembering
which terminal tab they are in.

---

## The three classes

| Class | Definition | Posture |
|-------|------------|---------|
| `personal` | A repo you own outright: your own account on a public forge, or a private repo under your personal account. You control the remote and its audience. | Open — everything allowed. |
| `corporate` | A repo owned by your employer (or a client): corporate forge hosts, work org accounts, anything whose remote audience is the company. The tracked tree is *their* property and *their* visibility. | Strict — sales artifacts redirect, memory-sync refuses, no personal config planted. |
| `shared-oss` | A repo owned by someone else that you contribute to: another org's or user's project on a public forge. You don't control the tree, and your commits become public PRs. | Cautious — personal/sales content stays out; dev artifacts warn about riding into PRs. |

The axis is **who sees the tracked tree**, not whether the code is open source. A private
repo under your own account is `personal`; a public repo under your employer's org is still
`corporate` (their tree, their rules).

---

## Detection rules

### Remote-host table

Detection reads `git remote get-url origin` (falling back to the first remote if `origin`
is absent) and classifies by host + owner:

Owner identities are **config-driven** — the shipped plugin stays identity-neutral; your
actual handles live in the `classification` block of `cc.config.json` (real values in
gitignored `cc.config.local.json`, filled by `/cc:setup:configure`):

```json
"classification": {
  "personal_owners":     ["<your personal forge username(s)>"],
  "work_owners":         ["<your work forge username(s) / orgs>"],
  "work_owner_suffixes": ["<suffix marking work handles, e.g. an employer abbreviation>"]
}
```

The suffix rule exists because some employers issue forge accounts as
`<yourname><EMPLOYER-SUFFIX>` — any repo owner whose name ends with a listed suffix
classifies `corporate`, even on a public forge, even for colleagues' repos you didn't list
individually.

| Remote | Class | Notes |
|--------|-------|-------|
| Owner ∈ `personal_owners` (any forge) | `personal` | Exact match on the owner segment. |
| Owner ∈ `work_owners`, or owner ends with a `work_owner_suffixes` entry | `corporate` | Catches your work handle AND coworkers' suffix-matched handles; checked BEFORE the shared-oss row. |
| `dev.azure.com/…`, `*.visualstudio.com` | `corporate` | Corporate DevOps hosting; treat the whole host as corporate. |
| Company-domain git hosts (self-hosted enterprise forge instances, corporate GitLab/Bitbucket servers) | `corporate` | Seeded conservatively; extended per portfolio review (below). |
| Public forge, owner matches no list | `shared-oss` | You contribute; you don't own the tree. |
| **No remote, or unknown/unlisted host** | **ask, else `corporate`** | **Ask-when-ambiguous** — see below. |

**Ambiguity rule (owner-amended from silent fail-safe):** when detection cannot classify —
no remote, unknown host, or an owner matching no list where shared-oss feels wrong — an
**interactive session asks: "Is this a work repo? (y/n)"**, and a "no" answer follows up
with one more question ("Is it your own repo, or someone else's you're contributing to?")
to land on `personal` vs `shared-oss` — you cannot resolve that split from a single yes/no.
Either way the result is written to STACK.md `class:` (the override field, so it sticks). A
**non-interactive** session (headless, chain subagent) cannot ask: it treats the repo as
`corporate` for that invocation and flags the unresolved classification in its output. The asymmetry rationale
still stands for the non-interactive default: a wrongly cautious personal repo costs a
one-line override; a wrongly open corporate repo costs a leak that may be irreversible.

Detection is **remote-host rules only** — no content sniffing, no directory-name
heuristics. The false-positive cost of guessing from content is too high; the STACK.md
override is the correction mechanism (see the plan's NOT-doing list).

### Extension point — portfolio review

The host/org lists above are the conservative seed. The portfolio sweep (plan Task 0.1,
`.specify/reports/portfolio-review.md`) inventories every local repo with its remote host
and a class guess; its output extends two lists here:

- **personal allowlist** — your confirmed usernames/orgs on public forges;
- **corporate host list** — every work host/org observed in the portfolio.

Until that report exists, anything not matching the seed rows lands on the fail-safe
default. When extending, add hosts to the *corporate* list freely; add to the *personal*
allowlist only entries you own outright.

### The `class:` field and override semantics

Detection **writes its result into STACK.md frontmatter** as part of
`setup:project` / `setup:stack`:

```markdown
---
stack: python
class: corporate        # personal | corporate | shared-oss
components:
  …
---
```

Override semantics, unambiguous:

1. **If `class:` is present in STACK.md, it ALWAYS wins.** No command, drift check
   (`setup:stack --check`), or re-run of detection may change or second-guess an existing
   `class:` value. Re-detection compares and may *report* a mismatch ("remote says
   corporate, STACK.md says personal — confirm this is intentional") but never edits the
   field.
2. **To override:** edit the one line in STACK.md. That is the entire mechanism — correct
   it once, it sticks, and it syncs with the repo like any tracked file.
3. **To re-enable auto-detection:** delete the `class:` line and re-run
   `/cc:setup:stack`. Absence of the field is the only state in which detection writes it.
4. **If STACK.md is missing entirely**, commands that need a class run live detection for
   that invocation (same table, same corporate default) and recommend `/cc:setup:project`
   to persist the result.

`setup:project` confirms the detected class with the user before writing it — detection
proposes, the human disposes, the file remembers.

---

## The safeguard matrix

What each command family may do, per class. Cell vocabulary:

- **allowed** — normal behavior, no friction.
- **redirect → deals-workspace** — output is written to the deals workspace
  (`references/presales/deals-workspace.md`; default `~/code/deals-workspace`, configured
  via `paths.deals_workspace`), never into the repo. In corporate repos this prints a
  one-line notice; elsewhere it is silent standard resolution.
- **refused + notice** — the operation does not happen; a one-line notice says why and
  names the alternative.
- **allowed + warning** — proceeds, but prints a caution first.

| Command family | `personal` | `corporate` | `shared-oss` |
|----------------|------------|-------------|--------------|
| Sales / deal / account artifacts (`discovery:*`, `account:*`, `demo:*`, `value:*`, `deal:*`, `rfp:*`, `handover:*`) | redirect → deals-workspace | redirect → deals-workspace **+ notice, hook-backed** | redirect → deals-workspace |
| Exposure briefs specifically (`account:exposure`) | redirect → deals-workspace | redirect → deals-workspace **+ notice, hook-backed** | redirect → deals-workspace |
| Radar state + digests (`radar:*` → `radar/state.json`, digests) | redirect → deals-workspace | redirect → deals-workspace **+ notice, hook-backed** | redirect → deals-workspace |
| memory-sync `link` / `push` for this repo's memory | allowed | refused + notice | allowed |
| Per-repo plugin settings planting (`setup:project` writing `.claude/settings.json`) | allowed (gated on Probe P1) | refused + notice — never planted | refused + notice |
| `.specify/` dev artifacts (plans, reviews, reports, evals) | allowed | allowed | allowed + warning |
| Session cursors (`/cc:pause` → `[WORKSPACE_DIR]/session.md`) | allowed | allowed + warning | allowed + warning |

WHY, per non-obvious cell:

- **Sales artifacts redirect even in `personal` repos** — the deals workspace is the
  canonical cwd-independent home for ALL sales artifacts (plan design decision 3); the
  class only changes whether the redirect is silent (personal) or announced and hook-backed
  (corporate). One home ends the scattered-artifact problem regardless of class.
- **Exposure briefs get their own row** — same mechanics as other sales artifacts, called
  out because they are the worst-case leak: a named customer plus their quantified risk
  posture. If only one safeguard survives owner review, it should be this one.
- **Radar redirects everywhere** — radar state is deliberately singular (one `state.json`
  in the deals workspace); per-repo state was the fragmentation bug this kills.
- **memory-sync refused in `corporate`** — linking a corporate project's memory into the
  personal store syncs work-derived content to a personal remote. This was already policy
  by vigilance (the store denylist is defense-in-depth behind it); the class makes it
  enforced. Notice points at the denylist stance in `scripts/memory-sync.sh`.
- **memory-sync allowed in `shared-oss`** — project memory lives under `~/.claude`, never
  in the repo tree; the risk axis is work-confidentiality (corporate), not repo
  visibility, and your notes on an OSS project are your own.
- **Settings never planted in `corporate`** — personal marketplace/plugin config does not
  belong in an employer's tracked tree, even gitignored-adjacent; install at user scope on
  that machine instead.
- **Settings not planted in `shared-oss`** — you don't own the tree; planted config would
  ride into your next PR. Use user-scope install or a plugin-dir launch flag.
- **`.specify/` allowed in `corporate`** — plans, reviews, and reports about the corporate
  codebase are legitimate work product *of that codebase*; blocking them would break the
  dev workflow exactly where it is most useful. (They must still contain no cross-customer
  sales content — that content redirects per the rows above and never originates there.)
- **`.specify/` warns in `shared-oss`** — legitimate for your own work, but keep it out of
  upstream PRs; `setup:project` adds the gitignore entry and the warning reminds you when
  it is absent.
- **Pause cursors warn (not block) in `corporate`** — `session.md` is free-text thinking
  in a shared tree: usually harmless dev context, occasionally not. Blocking would break
  the pause/resume cadence for legitimate work, so it warns ("this cursor lands in a
  corporate tree — keep it code-focused") and proceeds. Owner may tighten this to a
  redirect.

No cell is empty; every family has a defined behavior in every class.

---

## Hook enforcement spec (for Phase 2.3 — implement, don't inline here)

The matrix above is enforced first in the commands (redirect at output-resolution time).
One **backstop hook** catches what prompts miss — same philosophy as
`hooks/block-secrets.py`: *a guardrail against accidental writes, not a security boundary*.
A determined bypass is possible; the goal is that no habitual or absent-minded action lands
sales artifacts in a corporate tree.

**Rule.** PreToolUse on `Write|Edit`: deny when the target path contains an `accounts/`,
`deals/`, or `radar/` path segment **and** the enclosing repo's STACK.md declares
`class: corporate`.

**Mechanics** (precise enough to implement against the block-secrets idiom):

1. **Registration** — add a second matcher block to `hooks/hooks.json` `PreToolUse`:
   matcher `Write|Edit`, command
   `python3 "${CLAUDE_PLUGIN_ROOT}/hooks/block-corporate-artifacts.py"`, timeout 5.
2. **Input** — the hook reads one JSON object from stdin:
   `{"tool_name": "Write"|"Edit", "tool_input": {"file_path": "...", …}}`. Both tools use
   `file_path`. Missing/malformed JSON or absent `file_path` → exit 0 (see fail-open).
3. **Path test** — normalize `file_path` to an absolute path (`os.path.abspath`; join
   against cwd if relative). Match the *segment* pattern
   `(^|/)(accounts|deals|radar)(/|$)` against the path — segment-anchored so
   `src/accounts_ui/` or `webpack/radar.config.js` do not match, but
   `<repo>/.specify/accounts/brief.md` and `<repo>/radar/state.json` do.
4. **Repo-root walk — ALL enclosing roots, not just the nearest.** From the target file's
   directory, walk parent directories looking for a `.git` entry (dir or file — worktrees
   use a file), all the way to the filesystem root, and collect **every** ancestor
   directory that has one (not just the first hit). No `.git` found anywhere → exit 0.
   This matters because a nested `.git` (a vendored dependency cloned with its history
   intact, a forgotten `git init` in a subfolder, an unregistered submodule) with no
   `STACK.md` of its own must not shadow an enclosing repo's own `class: corporate` — a
   write under that nested root still lands in the corporate tree by any reasonable
   reading, so the walk does not stop at the nearest `.git`.
5. **Class read — tolerant frontmatter, case/quote-insensitive value.** For each repo root
   collected in step 4 (nearest first), open `STACK.md` if present and scan for the first
   `---`-delimited block **anywhere in the file** — this is a deliberately tolerant read,
   NOT anchored to the file's literal first byte: a preamble line (a title, a comment)
   before the frontmatter block is tolerated. This is a corporate-artifact guardrail, so
   permissive *parsing* fails toward protection (finding a `class:` declaration that a
   stricter, anchored read would miss), even though the hook as a whole still fails open on
   any error. Within that block, extract `^class:\s*(\S+)`, then normalize the captured
   value — strip one layer of surrounding quotes, case-fold — before comparing: `corporate`,
   `Corporate`, `CORPORATE`, and `"corporate"` all match. Deny as soon as ANY collected repo
   root's normalized value is `corporate`. No STACK.md, no frontmatter, no `class:` field, or
   any other value at every collected root → exit 0.
6. **Deny** — exit 2, with the redirect message on stderr (exit 2's stderr is fed back to
   the model, per the block-secrets contract):
   `Blocked: this repo is classified 'corporate' (STACK.md class:). Sales/deal/radar artifacts never write into corporate trees — write to the deals workspace instead (paths.deals_workspace, default ~/code/deals-workspace). Wrong classification? Edit 'class:' in STACK.md.`
7. **Fail-open** — any unexpected error (unreadable file, permission error, exception)
   → exit 0. The hook is the *second* line of defense behind command-level redirects; a
   broken backstop must not brick every Write on the machine. Note the deliberate
   asymmetry: the **classifier** fails safe (unknown → corporate, at classification time),
   the **hook** fails open (no readable `class: corporate` at any enclosing root → allow, at
   write time). The hook only ever acts on an explicit corporate declaration — which is also
   what keeps it from blocking writes *into the deals workspace itself* (whose own tree has
   `accounts/`, `deals/`, `radar/` dirs but is never classified corporate, and whose
   enclosing ancestors, if any, are not corporate either).
8. **Harness** — a `hooks/test-block-corporate-artifacts.sh` sibling to
   `hooks/test-block-secrets.sh` (same `run_case NAME EXPECTED_EXIT JSON` pattern, using
   temp-dir fixture repos): corporate fixture + `accounts/` write → 2; personal fixture +
   `accounts/` write → 0; corporate fixture + `src/accounts_ui/` write → 0; no STACK.md →
   0; malformed stdin → 0; deals-workspace-shaped fixture (no class) + `deals/` write → 0;
   preamble-before-frontmatter corporate fixture + `accounts/` write → 2 (tolerant scan);
   nested classless `.git` inside a corporate repo + write under the nested root → 2 (outer
   class not shadowed); classless workspace-shaped repo nested under a non-corporate parent
   + `deals/` write → 0 (no false block); `class: Corporate` and `class: "corporate"`
   fixtures + `accounts/` write → 2 each (case/quote-insensitive). `memory-sync.sh`'s
   `get_repo_class()` mirrors the same tolerant/normalizing read (shell instead of Python)
   and its own harness carries the same preamble and case/quote cases against `link`.

---

## Owner-review checklist

> **Owner-reviewed 2026-07-02.** Items 2–7 confirmed as written. Item 1 amended:
> ask-when-ambiguous in interactive sessions (corporate default only when asking is
> impossible). Item 8 confirmed with the same amendment applied at classification time.
> Detection amended to config-driven owner lists + work-suffix rule (owner's forge-identity
> convention: personal handle vs suffix-marked work handles).

1. **Ambiguous classification asks "Is this a work repo?"** in interactive sessions and
   writes the answer to STACK.md; only non-interactive contexts fall back to the
   `corporate` default (fail-safe: a wrong `personal` guess can leak; a wrong `corporate`
   guess costs a one-line override).
2. **An explicit `class:` in STACK.md always beats re-detection** — drift checks report
   mismatches but never rewrite the field.
3. **Sales/deal/radar artifacts redirect to the deals workspace in ALL classes**, not just
   corporate — one canonical home; class only changes notice + hook backing.
4. **memory-sync `link`/`push` is refused for corporate-classed repos** (work-derived
   memory must not sync to a personal remote) but **allowed for shared-oss** (memory never
   lives in the repo tree).
5. **Per-repo plugin settings are never planted in corporate OR shared-oss repos** —
   planted only in personal repos: a recorded Probe P1 pass plants normally, a recorded P1
   fail skips (use the documented `--plugin-dir` fallback instead), and no recorded result
   (the common case today) plants anyway with a caveat note.
6. **`.specify/` dev artifacts are allowed in corporate repos** as legitimate work
   product; they warn (not block) in shared-oss.
7. **Pause cursors warn but are NOT blocked in corporate repos** — free-text thinking in a
   shared tree is flagged, not forbidden (tightening to redirect is a one-cell change).
8. **The enforcement hook fails open** on any error and acts only on an explicit
   `class: corporate` — accident guardrail, not a security boundary (block-secrets
   framing).
