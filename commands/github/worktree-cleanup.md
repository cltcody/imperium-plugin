---
description: Clean up git worktrees after a PR merges — kill ports, remove the worktree, prune refs, optionally delete branches
argument-hint: <branch|all|merged> [--delete-branches]
model: haiku
effort: low
disable-model-invocation: true
---

# GitHub: Worktree Cleanup

Complete the worktree lifecycle: kill processes on the worktree's dev ports, remove the
worktree directory, prune stale git refs, and (optionally) delete local + remote branches.

**Ports:** base from `cc.config.json` `worktree.port_base` (default `8124`); the cleanup range
is `port_base … port_base + 4`.

## Modes
- `<branch>` — clean one worktree.
- `all` — clean every worktree under `worktrees/`.
- `merged` — clean only worktrees whose PRs are merged (the safe default).

## Safety first
Before removing anything: confirm you are **not** inside the target worktree (`pwd`); check for
**uncommitted changes** (`git -C <path> status --porcelain` — warn and stop unless `--force`);
check **PR status** via `gh pr list --head <branch> --state all --json number,state,mergedAt`
(MERGED → safe; OPEN/CLOSED-unmerged → warn and ask; no PR → ask). Don't error on
already-deleted branches.

## Steps (per target)
1. **Identify:** `git worktree list --porcelain` → resolve target path(s) and branch(es).
2. **Kill ports:** `for p in $(seq <port_base> $((<port_base>+4))); do lsof -ti:$p | xargs kill -9 2>/dev/null; done`
3. **Remove:** `git worktree remove worktrees/<branch>` (fall back to `--force` if dirty/locked), then `git worktree prune`.
4. **Branches (only with `--delete-branches`):** `git branch -d <branch>` (→ `-D` if unmerged); `git push origin --delete <branch> 2>/dev/null || true`.

## Report
```
## Worktrees cleaned up
| Branch | PR | Worktree | Local | Remote |
|--------|----|----------|-------|--------|
| <b>    | ✅ Merged #N | ✅ Removed | ✅/⏭️ | ✅/⏭️ |
Skipped: <n> (PR still open / unmerged)
```

## Edge cases
- Worktree gone but branch remains → skip removal, still delete branch if requested.
- Currently inside the worktree → error and exit; `cd` to the main repo first.
- No `gh` / can't verify PR → warn, proceed with cleanup.
