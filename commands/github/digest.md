---
description: Sweep your open PRs (and stale local branches) into a needs-you-now / ready-to-merge / in-flight board
argument-hint: [repo path(s), default current directory]
model: haiku
effort: low
disable-model-invocation: true
---

# GitHub: PR Digest

Answer "which of my branches actually needs me right now" across one or more repos in one pass — the antidote to juggling five open sessions/branches and losing track of state. Complements `/cc:github:list` (broad issue+PR survey, LLM-judged priority) with a narrower, deterministic, script-driven board over just your own open PRs.

## Steps

1. **Resolve target repo(s).** No argument → the current working directory (must be inside a git repo). One or more paths → pass each as a `--repo <path>` flag. Reject cleanly if a given path isn't a git repo.
2. **Run the digest script:**
   ```bash
   node ${CLAUDE_PLUGIN_ROOT}/scripts/pr-digest.mjs --repo <path1> [--repo <path2> ...]
   ```
   Requires the GitHub CLI authenticated (`gh auth status`). If it errors on auth, tell the user to run `gh auth login` and stop.
3. **Present the digest as-is** — it's already rendered into five sections, most-actionable first:
   - 🔴 **Needs you now** — CI failing, changes requested, or a merge conflict. Always lead with this.
   - 🟢 **Ready to merge** — all checks green, nothing blocking. Second priority — these are free wins sitting idle.
   - 🟡 **In flight** — CI still running or awaiting someone else's review. No action needed, just visibility.
   - ⚪ **No PR yet** — a local branch with real commits and no PR opened. Ask whether to open one now.
   - 🧹 **Safe to delete** — local branches whose PR already merged/closed (their PR history proves it, not local git ancestry — this correctly handles squash-merged repos where the branch's commits never become ancestors of main).
4. **Offer concrete next actions** for anything in 🔴 or 🟢: for 🔴, name the specific blocker per PR (failing check → suggest `/cc:verify:debug`; changes requested → review the feedback; conflict → `/cc:github:sync`). For 🟢, offer to merge on the spot if the user confirms (`gh pr merge <n> --squash --delete-branch`) — never merge without an explicit go-ahead.

## Notes

- The script is stateless and deterministic (no LLM judgment in the classification) — every run of the same repo state produces the same buckets. Read `pr-digest.mjs`'s inline doc comment for the exact bucket-decision rules if asked to explain "why is this PR blocked."
- `--json` mode exists for programmatic use (e.g. a scheduled routine diffing state across runs) — prefer the default rendered output for interactive use.
- Deliberately scoped to PRs and local branches, not live session state — sessions are ephemeral and this tool doesn't try to read the harness's internal state. In a typical branch-per-session workflow this is close enough to be the practical answer to "which sessions need me."
