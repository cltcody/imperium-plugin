# Scheduling

How to actually run a cc command **on a recurring basis**, instead of typing it every time.
A slash command is not a shell command — `0 9 * * MON /cc:verify:system-health` in a crontab
does nothing; cron has no idea what `/cc:...` means. This file is the single source of truth
every "run weekly" pointer in this plugin routes to.

---

## Decision table

Four real mechanisms, in order of how much they need you around:

| Mechanism | Runs where | Needs a live session? | Survives you closing the laptop? | Best for |
|-----------|-----------|------------------------|-----------------------------------|----------|
| `/loop` | Inside the current Claude Code session | Yes | No — dies with the session | A short recurring check you're actively watching (e.g. poll a deploy for 20 minutes) |
| **Desktop Tasks** (Claude Code Desktop) | Locally, scheduled by the desktop app | No | Yes, as long as the machine is on and the app can wake | Local, machine-specific recurring jobs (weekly audit on your dev box) |
| **Routines** (Anthropic-cloud) | Headless, in the cloud | No | Yes — doesn't depend on your machine at all | Jobs that must run even if your laptop is off; team/shared schedules |
| **Headless one-shot** (`claude -p "/cc:..." --model haiku`) | Wherever you invoke it — cron, launchd, GitHub Actions, etc. | No | Yes — whatever's driving cron/CI owns the uptime | You already have a scheduler (cron, launchd, CI) and just want cc to run inside it |

**Picking one:**
- Need it to run *right now*, repeatedly, while you watch → `/loop`.
- Need it to run *unattended on your own machine* → Desktop Tasks.
- Need it to run *unattended with no machine dependency at all* → Routines.
- Already have cron/launchd/CI and just want the invocation → headless one-shot, wired into
  the scheduler you already have.

None of these require inventing a bash daemon (`while true; sleep 60; done`) — if you catch
yourself writing one to "monitor" or "poll" something, replace it with one of the four above.

---

## Recipe 1 — Weekly `/cc:verify:dependencies`

Catches new CVEs and drifted lockfiles before they age into an emergency.

**Desktop Tasks / Routines:** schedule the prompt `/cc:verify:dependencies` weekly (e.g. Monday
9am). It reads the project's `STACK.md`, so point the task at the right project directory (or
open the session there).

**Headless one-shot (cron/launchd), if you'd rather own the scheduler yourself:**

```bash
# crontab -e — every Monday at 9am, from the project directory
0 9 * * MON cd /path/to/project && claude -p "/cc:verify:dependencies" --model haiku
```

`--model haiku` keeps a scheduled, mechanical run cheap; this command is a good haiku
candidate per `${CLAUDE_PLUGIN_ROOT}/references/dev/model-routing.md`. Capture output if you
want a paper trail:

```bash
0 9 * * MON cd /path/to/project && claude -p "/cc:verify:dependencies" --model haiku >> ~/logs/dep-audit.log 2>&1
```

---

## Recipe 2 — Weekly repo gate (this plugin's own hygiene)

`bash global/scripts/cc-audit.sh` is the mechanical half of `/cc:maintain:audit` — reference
existence, placeholder sync, frontmatter, CRLF, stale-path denylist, INVENTORY drift. Two
equally valid ways to run it weekly, no `claude` invocation needed at all since it's a plain
shell script:

**Cron (local machine):**

```bash
# crontab -e — every Monday at 8am
0 8 * * MON cd /path/to/imperium && bash global/scripts/cc-audit.sh >> ~/logs/cc-audit.log 2>&1
```

**CI (preferred — runs regardless of whether your machine is on):** add it to the repo's
GitHub Actions workflow on a `schedule:` trigger:

```yaml
on:
  schedule:
    - cron: "0 8 * * MON"
  pull_request:
jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash global/scripts/cc-audit.sh
```

For the judgment-only checks `cc-audit.sh` doesn't cover (brand-leakage nuance, description
quality), pair it with an occasional `claude -p "/cc:maintain:audit"` headless run or Routine —
the script is the floor, not the whole audit.

---

## Recipe 3 — Post-deploy `/cc:verify:system-health --post-deploy` polling

Two distinct needs after a release — pick per situation:

**A. A short watch right after deploying** (minutes, while you're still around): use `/loop`
in the session that ran the deploy:

```
/loop 2m /cc:verify:system-health --post-deploy
```

Stop it once you're confident the deploy is stable (or let it self-pace — see the `/loop`
skill for interval guidance).

**B. Ongoing/unattended health polling** (hours or days, or you're not staying at the
keyboard): a Desktop Task or Routine on a fixed interval, or a headless one-shot from
cron/launchd if you already run one of those:

```bash
# crontab -e — every 5 minutes for the hour after a deploy, or standing or indefinitely
*/5 * * * * cd /path/to/project && claude -p "/cc:verify:system-health --post-deploy" --model haiku >> ~/logs/post-deploy-health.log 2>&1
```

Route failures the same way the command itself does: a fixable issue → investigate/`
/cc:verify:debug`; a critical, user-facing issue → `/cc:release:rollback` immediately, don't
keep polling while users are affected.

---

## Recipe 4 — Weekly `/cc:radar:scan` + monthly watchlist review

Catches regulatory changes on the sources in `references/domains/trade/regulatory-sources.md`
before they age into a surprise; the monthly watchlist review keeps `radar:brief`'s
account-matching accurate.

**Desktop Tasks / Routines:** schedule the prompt `/cc:radar:scan` weekly (e.g. Monday 9am),
pointed at the project directory whose `[WORKSPACE_DIR]/radar/` holds the run's state — same
directory-targeting caveat as Recipe 1.

**Headless one-shot (cron/launchd), if you'd rather own the scheduler yourself:**

```bash
# crontab -e — every Monday at 9am, from the project directory
0 9 * * MON cd /path/to/project && claude -p "/cc:radar:scan" --model sonnet >> ~/logs/radar-scan.log 2>&1
```

`--model sonnet` matches `radar:scan`'s own frontmatter tag — it's digest work (mid-tier per
`${CLAUDE_PLUGIN_ROOT}/references/dev/model-routing.md`), not a haiku-grade mechanical check,
since it has to judge change significance against the rubric, not just diff bytes.

State lives **per-project** in `[WORKSPACE_DIR]/radar/state.json` (created on first run,
diffed against on every run after). Running `radar:scan` from more than one project directory
gives each its own independent state and digest history — nothing is shared or global.

**Monthly reminder — account watchlist review:** `[WORKSPACE_DIR]/accounts/watchlist.md` is a
hand-edited file, not a command, so there's nothing to schedule the same way — but a stale
watchlist quietly degrades `radar:brief`'s affected-accounts shortlist. Put a monthly
calendar reminder (or a low-priority Desktop Task prompt like "remind me to review the
account watchlist") on the books to prune closed/lost accounts and add newly active ones.

---

## Notes

- Headless one-shots (`claude -p`) are non-interactive — they can't ask you a clarifying
  question mid-run. Prefer commands that either fully automate or fail loudly, not ones that
  expect a human answer partway through.
- Tag scheduled/mechanical invocations with `--model haiku` (or rely on the command's own
  `model:` frontmatter) to keep unattended runs cheap — see
  `${CLAUDE_PLUGIN_ROOT}/references/dev/model-routing.md`.
- All three cc-native mechanisms (`/loop`, Desktop Tasks, Routines) are documented in Claude
  Code's own docs, not this plugin — this file only maps *this plugin's* recurring commands
  onto them. If in doubt which is currently available in your Claude Code version, check
  `/help` or the Claude Code docs.
