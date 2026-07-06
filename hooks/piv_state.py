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


def _newest(directory: Path, ignore: set[str] | None = None) -> Path | None:
    try:
        ignore = ignore or set()
        files = [
            p
            for p in directory.glob("*.md")
            if p.is_file() and p.name not in ignore
        ]
        return max(files, key=lambda p: p.stat().st_mtime) if files else None
    except Exception:
        return None


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

        dirty = bool(_git(cwd, "status", "--porcelain").strip())

        plans_dir = workspace / "plans"
        plan = _newest(plans_dir)
        review = _newest(workspace / "code-reviews", ignore=REVIEW_IGNORE)
        report = _newest(workspace / "execution-reports")

        if plan is None:
            return ("plan", "—", "/cc:plan:feature")

        # Ambiguity guard: several plans newer than the newest report = more than
        # one effort in flight. Don't guess which — defer to the orchestrator.
        try:
            report_mt = _mtime(report)
            in_flight = [
                p for p in plans_dir.glob("*.md")
                if p.is_file() and _mtime(p) > report_mt
            ]
            if len(in_flight) > 1 and review is None:
                return ("plan", f"plans ({len(in_flight)} in flight)", NEXT_FALLBACK)
        except Exception:
            pass

        # Newest-artifact-wins across plan / review / report.
        candidates = [
            kp for kp in (("plan", plan), ("review", review), ("report", report))
            if kp[1] is not None
        ]
        kind, newest = max(candidates, key=lambda kp: _mtime(kp[1]))
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
