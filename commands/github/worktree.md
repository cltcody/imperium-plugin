---
description: Create git worktrees for parallel branch development, each validated with the project's own toolchain
argument-hint: <branch-1> [branch-2] … [branch-5]
model: haiku
effort: low
disable-model-invocation: true
---

# GitHub: Worktree

Create isolated git worktrees for parallel development — separate directories, dedicated dev
ports, independent dependencies, each fully validated before it's reported ready.

This is **stack-agnostic**: resolve `install`, `typecheck`, `lint`, `test`, and `dev` from the
project's `STACK.md` per `${CLAUDE_PLUGIN_ROOT}/references/dev/stack-resolution.md`. Never
hardcode a package manager or script.

**Ports:** base from `cc.config.json` `worktree.port_base` (default `8124`); worktree *N* uses
`port_base + (N-1)`.

## Logic
Count the branch arguments. One branch → set it up sequentially. Two to five → spawn that many
agents **in a single message** (Agent tool) so they run in parallel; each agent does the steps
below for its branch + assigned port and reports a structured PASS/FAIL per step.

## Per-worktree steps
1. **Create:** `mkdir -p worktrees && git worktree add worktrees/<branch> -b <branch> 2>/dev/null || git worktree add worktrees/<branch> <branch>`
2. **Install:** run the resolved `install` step from `worktrees/<branch>` (its `working_dir`).
3. **Validate:** run the resolved `typecheck` → `lint` → `test` steps; **all must pass**.
4. **Server smoke (optional):** if the stack maps `dev` + a health endpoint, start `dev` on the
   assigned port, wait, hit the health URL, then stop it. Skip if no health endpoint is defined.
5. **Report:** path, branch, port, and PASS/FAIL for install/typecheck/lint/test/(health).

A worktree is "ready" only when every mapped step passes. Skip unmapped steps (not a failure).

## Report
```
## Worktrees ready
| # | Branch | Port | Status | install | typecheck | lint | test |
|---|--------|------|--------|---------|-----------|------|------|
| 1 | <b1>   | 8124 | ✅/❌  | ✅/❌   | ✅/❌     | ✅/❌| ✅/❌ |
To work in one:  cd worktrees/<branch>   (then the resolved `dev` step)
Switch Claude:   /add-dir worktrees/<branch>   or start a session there
```

## Notes
- Worktrees share the same repo/git state and (by default) the same DB/services env — give each
  its own DB/URL if it needs isolation.
- Each worktree has independent dependencies.
- Clean up with `/cc:github:worktree-cleanup` when done.
- Max 5 parallel worktrees.
