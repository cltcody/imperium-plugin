#!/usr/bin/env python3
"""PIV SessionStart status line.

Bundled with the cc plugin (hooks/hooks.json). On session start/resume, Claude
Code runs this and adds anything we print to stdout to the model's context, so
the assistant opens the session already knowing where the PIV loop stands.

The "where are we?" logic lives in `piv_state.py` (same dir) — the single source
of truth shared with an optional dev statusline, so the two can never drift.

Design rules (this runs for EVERY project of EVERY cc installer):
  * Gentle — print NOTHING unless the cwd is actually using PIV (a `.specify/`
    dir exists). Non-PIV projects see no noise at all.
  * Unbreakable — wrapped in try/except; ALWAYS exit 0. A status helper must
    never be able to fail a user's session.
  * Zero dependencies — standard library only, no network, fast.
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from piv_state import WORKSPACE_DIR, detect_state  # noqa: E402  (local module, path set above)


def _git(cwd: Path, *args: str) -> str:
    try:
        out = subprocess.run(
            ["git", *args], cwd=cwd, capture_output=True, text=True, timeout=3
        )
        return out.stdout.strip() if out.returncode == 0 else ""
    except Exception:
        return ""


def main() -> int:
    cwd = Path(os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd())
    workspace = cwd / WORKSPACE_DIR

    # Gentle gate: only speak up in projects that actually use PIV.
    if not workspace.is_dir():
        return 0

    branch = _git(cwd, "rev-parse", "--abbrev-ref", "HEAD") or "—"
    state = "dirty" if _git(cwd, "status", "--porcelain").strip() else "clean"

    phase, last, nxt = detect_state(cwd)
    # detect_state already falls back to /cc:next when unsure; this guards the
    # only-empty-on-non-PIV case (unreachable here, since we gated on .specify/).
    nxt = nxt or "/cc:next"

    print("PIV status —")
    print(f"  branch: {branch} ({state})   phase: {phase or '—'}")
    print(f"  last:   {last}")
    print(f"  next:   {nxt}")
    print("  (ask \"what should I do next?\" for a full diagnosis via piv-orchestrator)")
    return 0


def _self_test() -> int:
    """Embedded fixtures through the real entry points."""
    import contextlib
    import io
    import tempfile

    failures = 0

    # Fixture 1: non-PIV project (no .specify/) -> prints nothing, exit 0.
    with tempfile.TemporaryDirectory() as tmp:
        os.environ["CLAUDE_PROJECT_DIR"] = tmp
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            rc = main()
        ok = rc == 0 and buf.getvalue() == ""
        print(f"{'PASS' if ok else 'FAIL'}  non-PIV dir stays silent, exit 0")
        failures += 0 if ok else 1

    # Fixture 2: PIV project with a plan -> prints a status block, exit 0.
    with tempfile.TemporaryDirectory() as tmp:
        plans = Path(tmp) / WORKSPACE_DIR / "plans"
        plans.mkdir(parents=True)
        (plans / "some-feature.md").write_text("# plan\n")
        os.environ["CLAUDE_PROJECT_DIR"] = tmp
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            rc = main()
        out = buf.getvalue()
        ok = rc == 0 and "PIV status" in out and "next:" in out
        print(f"{'PASS' if ok else 'FAIL'}  PIV dir prints status block, exit 0")
        failures += 0 if ok else 1

    # Fixture 3: detect_state never raises on an empty dir.
    with tempfile.TemporaryDirectory() as tmp:
        try:
            phase, last, nxt = detect_state(Path(tmp))
            ok = True
        except Exception:
            ok = False
        print(f"{'PASS' if ok else 'FAIL'}  detect_state never raises on empty dir")
        failures += 0 if ok else 1

    os.environ.pop("CLAUDE_PROJECT_DIR", None)
    print(f"self-test: {3 - failures}/3 passed")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    if "--self-test" in sys.argv:
        sys.exit(_self_test())
    try:
        sys.exit(main())
    except Exception:
        # Never let a status helper break a session.
        sys.exit(0)
