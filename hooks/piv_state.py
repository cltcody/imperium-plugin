#!/usr/bin/env python3
"""PIV state detector — the single source of truth for "where is the PIV loop?"

Shared by two consumers so the logic can never drift between them:
  * the bundled SessionStart hook `piv-status.py` (imports `detect_state`)
  * an optional dev statusline that shells out to the `__main__` below for a
    tab-separated `phase<TAB>last<TAB>next` line

Model: **newest-artifact-wins.** The most recently touched `.specify/` artifact
decides the phase. This fixes the old "plan newer than report = implementing"
heuristic, which mis-read the entire verify phase (run → code → fix → security →
design) as "implement", because the execution report — its only "implementation
done" marker — is written last, right before the commit gate.

When the state is genuinely ambiguous we do NOT guess: `next` falls back to
`/cc:next`, the live orchestrator diagnosis.

Design rules (runs for EVERY PIV project, on every statusline render):
  * stdlib only, no network, fast.
  * never raises — every public path is guarded and returns sane defaults.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

# imperium's per-project workspace directory (cc.config.json paths.workspace_dir).
WORKSPACE_DIR = ".specify"

# When we can't confidently name the next step, defer to the orchestrator.
NEXT_FALLBACK = "/cc:next"

# Files in code-reviews/ that are NOT per-feature reviews and must be ignored
# when looking for "the newest review".
REVIEW_IGNORE = {"backlog.md"}


def _git(cwd: Path, *args: str) -> str:
    try:
        out = subprocess.run(
            ["git", *args], cwd=cwd, capture_output=True, text=True, timeout=3
        )
        return out.stdout.strip() if out.returncode == 0 else ""
    except Exception:
        return ""


def _mtime(p: Path | None) -> float:
    try:
        return p.stat().st_mtime if p else -1.0
    except Exception:
        return -1.0


# How many workspace-touching commits _artifact_times walks. Module-level so the
# self-test can shrink it to exercise the overflow clamp without 300 commits.
_LOG_LIMIT = 300

# git prints non-ASCII paths octal-escaped in quotes unless told not to; escaped
# keys would never match a real relpath, silently re-enabling the mtime fallback.
_GIT_PATHS_RAW = ("-c", "core.quotepath=false")


def _artifact_times(cwd: Path, status_lines: list[str] | None = None) -> dict[str, float]:
    """Last-touching git commit time per workspace artifact (repo-relative posix path).

    Filesystem mtimes are checkout times in a fresh worktree/clone, so ranking by
    them is arbitrary there. Commit times survive checkout. Batched git calls only
    (this runs on every statusline render — per-file `git log` would not fly):
      1. one bounded `git log --name-only` over the workspace — first appearance of
         a path is its most recent touching commit;
      2. one `git ls-files` — tracked artifacts older than the log window get a
         floor BELOW every seen commit time (a raw-mtime fallback in a fresh
         worktree would be checkout time ≈ now and always win — inverted ranking);
      3. `git status --porcelain` — modified/untracked artifacts are dropped so
         they fall back to fs mtime, which for uncommitted work IS the true time.
         The caller may pass full-repo porcelain lines it already has (dedupes a
         subprocess); otherwise a workspace-scoped call is made here.
    """
    times: dict[str, float] = {}
    try:
        log = _git(
            cwd, *_GIT_PATHS_RAW, "log", "-n", str(_LOG_LIMIT),
            "--format=%x01%ct", "--name-only", "--", WORKSPACE_DIR,
        )
        if not log:
            return {}
        current_ct = -1.0
        for line in log.splitlines():
            if line.startswith("\x01"):
                try:
                    current_ct = float(line[1:].strip())
                except ValueError:
                    current_ct = -1.0
            elif line.strip() and current_ct > 0:
                times.setdefault(line.strip(), current_ct)
        if times:
            floor = min(times.values()) - 1.0
            tracked = _git(cwd, *_GIT_PATHS_RAW, "ls-files", "--", WORKSPACE_DIR)
            for path in tracked.splitlines():
                if path.strip():
                    times.setdefault(path.strip(), floor)
        if status_lines is None:
            status_lines = _git(
                cwd, *_GIT_PATHS_RAW, "status", "--porcelain", "--", WORKSPACE_DIR
            ).splitlines()
        for line in status_lines:
            path = line[3:].strip()
            if " -> " in path:  # rename: "old -> new"
                path = path.split(" -> ", 1)[1]
            times.pop(path.strip('"'), None)
        return times
    except Exception:
        return {}


def _atime(p: Path | None, cwd: Path | None, times: dict[str, float] | None) -> float:
    """Artifact time: git commit time when known, else fs mtime."""
    if p is None:
        return -1.0
    if cwd is not None and times:
        try:
            rel = p.relative_to(cwd).as_posix()
            if rel in times:
                return times[rel]
        except Exception:
            pass
    return _mtime(p)


def _newest(
    directory: Path,
    ignore: set[str] | None = None,
    cwd: Path | None = None,
    times: dict[str, float] | None = None,
) -> Path | None:
    try:
        ignore = ignore or set()
        files = [
            p
            for p in directory.glob("*.md")
            if p.is_file() and p.name not in ignore
        ]
        return max(files, key=lambda p: _atime(p, cwd, times)) if files else None
    except Exception:
        return None


def _plan_done(path: Path) -> bool:
    """True when a plan's header declares it finished.

    First 5 lines only — the status marker convention sits on the title/status
    line, and plan DESCRIPTIONS a few lines down legitimately contain these very
    strings (a plan about fixing this detector quoted "**implemented**" at line 9).
    Conservative marker list, mirroring _review_state: unknown → False (live).
    """
    try:
        with path.open(encoding="utf-8", errors="replace") as f:
            head = "".join(f.readline() for _ in range(5)).lower()
    except Exception:
        return False
    bold_markers = (
        "**implemented**",
        "**superseded**",
        "**done**",
    )
    # Status-line form: matched with asterisks stripped so the natural markdown
    # authoring style `**Status:** implemented` counts too. (Bold markers above
    # are matched raw — stripping would reduce them to bare words, far too loose.)
    status_markers = (
        "status: implemented",
        "status: superseded",
        "status: done",
    )
    head_plain = head.replace("*", "")
    return any(m in head for m in bold_markers) or any(
        m in head_plain for m in status_markers
    )


def _review_state(path: Path) -> str:
    """'clean' | 'findings' | 'unknown' for the newest code-review file.

    Conservative on purpose: only return 'findings'/'clean' on a clear signal,
    otherwise 'unknown' so the caller falls back to /cc:next instead of guessing.
    """
    try:
        text = path.read_text(encoding="utf-8", errors="replace").lower()
    except Exception:
        return "unknown"
    clean_markers = (
        "no technical issues",
        "review passed",
        "all resolved",
        "verdict:** approve",
        "verdict: approve",
    )
    finding_markers = (
        "request changes",
        "block (critical)",
        "[critical]",
        "[high]",
    )
    has_clean = any(m in text for m in clean_markers)
    has_findings = any(m in text for m in finding_markers)
    # "ALL RESOLVED" can co-occur with the original [HIGH] headers — clean wins.
    if has_clean and "resolved" in text:
        return "clean"
    if has_findings:
        return "findings"
    if has_clean:
        return "clean"
    return "unknown"


def detect_state(cwd: Path) -> tuple[str, str, str]:
    """Return (phase, last, next_step). Never raises.

    phase: short label ("plan"/"implement"/"verify"/"release"/"clean"/"") for display.
    last:  the latest artifact/step observed ("review architecture-review-board"), or "—".
    next:  the recommended next command, or /cc:next when unsure, or "" when N/A.
    """
    try:
        workspace = cwd / WORKSPACE_DIR
        if not workspace.is_dir():
            # Not a PIV project. A plain git repo → prime is the entry point.
            if _git(cwd, "rev-parse", "--is-inside-work-tree") == "true":
                return ("", "—", "/cc:prime")
            return ("", "—", "")

        status_lines = _git(
            cwd, *_GIT_PATHS_RAW, "status", "--porcelain"
        ).splitlines()
        dirty = any(line.strip() for line in status_lines)
        times = _artifact_times(cwd, status_lines)

        plans_dir = workspace / "plans"
        try:
            all_plans = [p for p in plans_dir.glob("*.md") if p.is_file()]
        except Exception:
            all_plans = []
        # A plan whose header says implemented/superseded/done is not in flight —
        # it must never put the loop back into "implement".
        live_plans = [p for p in all_plans if not _plan_done(p)]
        plan = (
            max(live_plans, key=lambda p: _atime(p, cwd, times))
            if live_plans
            else None
        )
        review = _newest(
            workspace / "code-reviews", ignore=REVIEW_IGNORE, cwd=cwd, times=times
        )
        report = _newest(workspace / "execution-reports", cwd=cwd, times=times)

        if plan is None and review is None and report is None:
            if all_plans:  # only finished plans exist — nothing in flight
                newest_done = max(all_plans, key=lambda p: _atime(p, cwd, times))
                return ("clean", f"plan {newest_done.stem} (done)", NEXT_FALLBACK)
            return ("plan", "—", "/cc:plan:feature")

        # Ambiguity guard: several LIVE plans newer than everything verify/release
        # has produced = more than one effort in flight. Don't guess which — defer
        # to the orchestrator. (Reviews used to disable this guard entirely.)
        try:
            threshold = max(
                _atime(report, cwd, times), _atime(review, cwd, times)
            )
            in_flight = [
                p for p in live_plans if _atime(p, cwd, times) > threshold
            ]
            if len(in_flight) > 1:
                return ("plan", f"plans ({len(in_flight)} in flight)", NEXT_FALLBACK)
        except Exception:
            pass

        # Newest-artifact-wins across plan / review / report. Later pipeline
        # stages listed first: artifacts committed together tie on commit time,
        # and max() keeps the first — a tie must resolve to the later stage
        # (report > review > plan), not send "next" to an already-done step.
        candidates = [
            kp for kp in (("report", report), ("review", review), ("plan", plan))
            if kp[1] is not None
        ]
        kind, newest = max(candidates, key=lambda kp: _atime(kp[1], cwd, times))
        last = f"{kind} {newest.stem}"

        if kind == "report":
            if dirty:
                return ("release", last, "/cc:release:commit")  # the ⛔ gate
            return ("clean", last, NEXT_FALLBACK)

        if kind == "review":
            rs = _review_state(newest)
            if rs == "findings":
                return ("verify", last, "/cc:verify:code-review-fix")
            if rs == "clean":
                return ("verify", last, "/cc:verify:execution-report")
            return ("verify", last, NEXT_FALLBACK)  # unsure → orchestrator

        # kind == "plan" → the freshest artifact is a plan → implement it.
        return ("implement", last, "/cc:implement:execute")
    except Exception:
        # A state helper must never break a render or a session.
        return ("", "—", NEXT_FALLBACK)


def main() -> int:
    import argparse

    ap = argparse.ArgumentParser(add_help=False)
    ap.add_argument("--cwd", default=None)
    args, _ = ap.parse_known_args()
    cwd = Path(args.cwd) if args.cwd else Path.cwd()
    phase, last, nxt = detect_state(cwd)
    # Tab-separated single line for a bash statusline to parse.
    sys.stdout.write(f"{phase}\t{last}\t{nxt}\n")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        sys.exit(0)
