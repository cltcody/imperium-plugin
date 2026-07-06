---
description: Create well-structured conventional commits — the single approval gate of the PIV chain
argument-hint: [optional scope or message hint]
---

# Commit

Create one or more atomic, conventional commits from the current working tree. This is **the gate**: the only point in the PIV chain where the user must approve before anything is written to history. It never commits without explicit confirmation and never pushes unless explicitly asked.

## Steps

1. **Survey the working tree.** Run `git status`, `git diff HEAD --stat`, and `git diff HEAD` to see every staged, unstaged, and untracked change. If there is nothing to commit, say so and stop.
2. **Interpret the target.** If an argument hint was given, use it to scope which files this commit run covers — interpret natural language intelligently against `git status` and conversation context (blank = all changes; e.g. "all typescript files" → `*.ts`; "files in src/handlers" → that folder; "everything except tests" → exclude `*test*`; "the API changes" → infer from the diff; "only the new files" → untracked only). Exclude anything the hint asks to leave out.
3. **Review context.** If `${user_config.workspace_dir}/execution-reports/` or `${user_config.workspace_dir}/plans/` contains a report/plan for this work, read it to inform the commit message. Run `git log --oneline -5` to match the repository's existing message style.
4. **Group changes logically.** Decide whether the in-scope changes form one atomic commit or several. Unrelated concerns (e.g. a feature plus an unrelated config fix) must be split into separate commits, each independently coherent. List the file set for each proposed commit.
5. **Safety screen before staging.** Check the diff and untracked files for:
   - Secrets: API keys, tokens, passwords, `.env` files, private keys, connection strings.
   - Large binaries or generated artifacts (build output, `node_modules`, caches) that belong in `.gitignore`.
   - Leftover debug statements or temporary files.
   Anything suspicious: exclude it, flag it to the user, and suggest a `.gitignore` entry.
6. **Draft conventional-commit message(s).** Format: `<type>(<scope>): <imperative summary>` with an imperative-mood summary and type one of `feat | fix | docs | refactor | test | chore | perf | ci`. Add a short body explaining the why when the summary alone is not enough. Reference issues (`Fixes #N`) where applicable.
7. **⛔ GATE — present and wait.** This is the PIV chain's one stop. In chain mode, lead with the work summary from the execution report (what was built, validation verdict, divergences resolved) so this single approval covers both the work and the commit. Then show, for each proposed commit: the message, the exact file list, and any safety flags. Ask for approval once. **Do not run `git commit` until the user confirms — even in chain mode.** Apply any requested edits and re-present.
8. **Commit.** After approval, stage each group with explicit paths (`git add <files>` — never blanket `git add -A` when splitting) and commit. Verify with `git log --oneline -n <count>` and `git status` (tree should be clean or contain only intentionally excluded files). If the project configures pre-commit hooks (e.g. linters, type checkers, secret scanners), they run on every commit — if a hook fails, fix the underlying issue rather than bypassing it.
9. **Do not push.** Only push if the user explicitly asks (then `git push -u origin <branch>`; never force-push from this command).

## Output

One or more commits on the current branch with conventional messages, a clean working tree, and a short confirmation summary (hashes + messages). No artifact file is written.

## Quality checklist

- [ ] Every commit is atomic — one logical change per commit
- [ ] Message follows `type(scope): summary` and matches repo conventions
- [ ] No secrets, `.env` files, or large binaries staged
- [ ] File list shown to and approved by the user before committing
- [ ] Working tree clean (or remaining files deliberately left out and explained)
- [ ] Nothing pushed unless explicitly requested

## Handoff

**Chain:** this command is the chain's approval gate — the wait in step 7 applies always. After the commit succeeds in a PIV chain, suggest `/cc:verify:system` for an optional post-commit process review; do not auto-invoke it.
**Solo:** suggest `/cc:release:changelog` if a release is near, or `/cc:github:pr` if the branch should become a pull request.
**Abort rules:** user rejects the proposal → revise and re-present, never commit the rejected version. Secrets found in already-staged content → unstage, warn, and stop. Pre-commit hook fails → fix the underlying issue (route to `/cc:verify:run` if needed); never bypass hooks with `--no-verify`.
