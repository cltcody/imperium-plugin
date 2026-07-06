# Model Routing

Route each cc command and subagent to the **cheapest model (and effort level) that does the
job well**, to cut cost and tokens — *enforced by the harness*, not by a runtime router. (This
replaces the old standalone `model-router` skill + Python CLI, which only *printed* advice and
couldn't change the running model.)

## The real levers (how model selection is actually enforced)
1. **`model:` frontmatter** on a command/skill — the harness runs that command on the named
   model. This is the primary lever.
2. **`effort:` frontmatter** — an independent dimension from `model:`. Sets the reasoning-effort
   tier (`low` / `medium` / `high` / `xhigh` / `max`) the harness applies to that command's run,
   regardless of which model it lands on. See "The effort dimension" below.
3. **Subagent model** — Agent tool calls and workflow `agent()` take a `model` opt; run
   investigative/mechanical subagents on `haiku`, reserve `opus`/`fable` for synthesis/verify.
4. **`/model`** — the session default applies to everything left **untagged**.

Use **aliases**, never pinned IDs — aliases track the current release and never drift. The
current alias set: `haiku` / `sonnet` / `opus` / `fable` / `best` / `opusplan`, each with an
optional `[1m]` long-context variant (e.g. `sonnet[1m]`) for tasks that genuinely need the full
1M-token window (whole-repo scans, huge diffs) — most commands never need it. Current-gen
resolution as of this writing: `haiku` → Haiku 4.5, `sonnet` → Sonnet 5, `opus` → Opus 4.8,
`fable` → Claude Fable 5. `best` auto-picks the strongest available model for the task; `opusplan`
runs Opus during the planning/thinking phase and steps back down to the session default for
execution — useful for `plan:*`-shaped work when you want Opus-grade planning without paying
Opus rates for the mechanical follow-through.

## Tier policy
| Tier | Use for | Examples |
|------|---------|----------|
| `haiku` | mechanical, deterministic, extraction/formatting — little judgment | `github:list`, `github:worktree(-cleanup)`, `release:changelog` |
| `sonnet` | moderate reasoning; a sensible session default | most day-to-day commands when not on a stronger session model |
| *(untagged → inherit)* | deep reasoning / high-stakes — let it run on the session model (`opus`/`fable` when it matters) | `plan:*`, `implement:execute`, `verify:code/security/performance/rca`, `release:deploy` |

**Heavy/high-stakes commands are deliberately left untagged** so they inherit the session
model — never downgrade them to save pennies.

## The effort dimension
`effort:` is orthogonal to `model:` — it tells the harness how hard to think, independent of
which model is running underneath.

| Effort | Use for |
|--------|---------|
| `low` | mechanical, deterministic commands — the same set that gets `model: haiku`. Pair the two; a haiku-tier command with default effort is paying for reasoning it doesn't need. |
| *(untagged → inherit)* | everything else. This is the policy default — leave a command untagged unless you have a specific reason to override the session's effort. |
| `medium` / `high` / `xhigh` / `max` | reserved for rare, deliberately-flagged cases — a command that's reasoning-heavy *even relative to whatever model it's running on* (a one-shot irreversible action, a judgment call with no re-run). Don't reach for these by default; an untagged command already inherits the session's effort, which covers nearly everything. |

Policy: `effort: low` on genuinely mechanical haiku-tier commands; everything else stays
untagged; treat an explicit `medium`+ tag as an exception that earns its keep, not a default.

## Escalation — never downgrade these
If a task involves any high-stakes signal, prefer the session model (or `opus`/`fable`),
regardless of tier: `production`, `security`, `auth`, `migration`, `delete`, `payment`,
`billing`, `pii`, `gdpr`, `rollback`, `irreversible`.

## `allowed-tools` policy
`allowed-tools:` frontmatter restricts a command's own turn to a named tool list. It isn't a
model/cost lever, but it lives in the same "harness enforces it, not a prompt" family as
`model:`/`effort:`, so it's documented here. Apply it only to commands that are genuinely
**read/analyze/report-only**: every one of their own steps only reads, greps, or shells out for
information — never `Write`/`Edit`. Include `SlashCommand` and/or `Agent` in the list when the
command's own Chain/Handoff section performs those invocations as part of its normal
execution — that delegation is safe to keep because the invoked command or subagent carries its
own (separately scoped) tool permissions; it doesn't inherit the restricted parent's list.

Two payoffs:
1. **Least privilege** — a command that structurally cannot call `Write`/`Edit` can't be
   tricked into mutating files it was never meant to touch.
2. **Fewer permission prompts** — a tightly-scoped tool list is pre-approved territory, so
   routine runs (especially scheduled or haiku-tier ones) don't stop mid-flight to ask for a
   tool the command was never going to need.

Commands that write a report file — even conditionally ("if findings exist, save to
`[WORKSPACE_DIR]/reports/...`") — keep the default (untagged) tool access; don't restrict them.
When a command's read-only status is ambiguous, leave it untagged: a wrong restrictive list that
breaks a legitimate write is worse than no restriction at all.

## Applied tags
`model: haiku` + `effort: low` is set on: `github/list`, `github/worktree`,
`github/worktree-cleanup`, `release/changelog`. `allowed-tools` is set on the read-only
commands identified during the frontmatter enrichment pass (`github/list`, `verify/performance`,
`release/deploy`, `verify/coverage`) — see each command's frontmatter for its specific list.
Everything else inherits the session model, default effort, and full tool access.

## Memory & context isolation
Two more frontmatter levers sit next to `model:`/`effort:`/`allowed-tools`: `memory:` (on
subagents) and `context: fork` + `agent:` (on skills). Neither changes which model runs;
both change *what state the run has access to*.

- **`memory: project`** gives a subagent a persistent `MEMORY.md` under
  `.claude/agent-memory/<name>/` that survives across separate invocations, so it accumulates
  judgments about *this* repo instead of re-deriving them every run. This is distinct from
  Claude Code's native session-level auto memory (`~/.claude/projects/<project>/memory/`,
  synced by `memory-sync.sh` — see `context-engineering.md` → "Native memory & caching"):
  that one is main-session and machine-portable, this one is per-subagent and local to the
  repo's `.claude/` dir. Don't conflate the two when deciding where a piece of state belongs.
  Carried by
  `rulecheck-agent` (tracks rule-violation progress across runs), and now `code-reviewer`
  (learns recurring bug classes and house conventions specific to the project) and
  `validator` (remembers flaky tests / known-slow suites). Don't add it to agents whose
  output should be a fresh, unbiased pass each time (e.g. `security-auditor`,
  `gdpr-auditor`, `triage-agent`) — those want no priors baked in.
- **`context: fork` (+ `agent: <type>`)** runs a skill in an isolated subagent context
  instead of the main conversation, so its (often large) intermediate reading/grepping
  never pollutes the session. Carried by `triage` (issue-by-issue detail would flood the
  main thread), `security-audit`, and `gdpr-check` (both are full-codebase sweeps that
  read broadly and write a standalone report file — the main conversation only needs the
  final summary and report path, not every file read along the way).

**Rule of thumb:** fork when a skill is heavy, standalone, and produces its own report
file — the main conversation doesn't need the intermediate work, only the result. Reach
for `memory: project` when an agent makes the *same kind of judgment* repeatedly against
the *same repo* — accumulated context (past findings, known flaky tests, prior violations)
makes each subsequent run better. The two are independent: a skill can fork into an agent
that itself carries memory, or run unmemoried for a clean pass every time.

## Extending
Add `model: <alias>` and/or `effort: <tier>` to a command's frontmatter per the policies above.
Tag a command `haiku`/`low` only when it's genuinely mechanical; when in doubt, **leave it
untagged** (inherit). Add `allowed-tools` only after reading the command's full body and
confirming it never writes/edits directly. For subagents, pass the model at spawn time rather
than tagging.
