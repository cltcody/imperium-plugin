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

    # Fixtures 4 and 7 need a real git repo; build commits via this helper.
    # check=True + the git_ok flag: an unusable git environment (gpg-signing
    # system config, missing binary) SKIPS cleanly instead of blaming the
    # detector — same pattern as pre-compact-snapshot.py's fixture 4.
    git_env = {
        **os.environ,
        "GIT_CONFIG_GLOBAL": "/dev/null",
        "GIT_CONFIG_NOSYSTEM": "1",
        "GIT_AUTHOR_NAME": "t", "GIT_AUTHOR_EMAIL": "t@t",
        "GIT_COMMITTER_NAME": "t", "GIT_COMMITTER_EMAIL": "t@t",
    }

    def _g(root, *args, date=None):
        e = dict(git_env)
        if date:
            e["GIT_AUTHOR_DATE"] = e["GIT_COMMITTER_DATE"] = date
        subprocess.run(
            ["git", *args], cwd=root, env=e, capture_output=True,
            timeout=10, check=True,
        )

    # Fixture 4: worktree mtime scramble — git commit time must outrank fs mtime.
    # A plan committed AFTER a report must win even when checkout gave the report
    # the newer mtime (the fresh-worktree failure mode). The report's name is
    # non-ASCII on purpose: with core.quotepath unset git would octal-escape it,
    # its times-lookup would miss, and the mtime fallback would wrongly win.
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        plans = root / WORKSPACE_DIR / "plans"
        reports = root / WORKSPACE_DIR / "execution-reports"
        plans.mkdir(parents=True)
        reports.mkdir(parents=True)
        report_name = "alter-bericht-prüfung.md"
        try:
            (reports / report_name).write_text("# report\n")
            (plans / "new-feature.md").write_text("# plan\n")
            _g(root, "init", "-q")
            _g(root, "add", "-A")
            _g(root, "commit", "-qm", "report", date="2026-01-01T00:00:00 +0000")
            (plans / "new-feature.md").write_text("# plan v2\n")
            _g(root, "add", "-A")
            _g(root, "commit", "-qm", "plan", date="2026-01-02T00:00:00 +0000")
            git_ok = True
        except Exception:
            git_ok = False
        if git_ok:
            # Scramble mtimes the way a checkout would: BOTH newer than every
            # commit time (checkout stamps "now"), report newest. Epochs must
            # exceed the 2026 commit dates or a missed times-lookup would not
            # actually flip the outcome and this fixture would pass vacuously.
            os.utime(plans / "new-feature.md", (1_800_000_000, 1_800_000_000))
            os.utime(reports / report_name, (1_800_000_100, 1_800_000_100))
            phase, last, nxt = detect_state(root)
            ok = phase == "implement" and "new-feature" in last
            print(f"{'PASS' if ok else 'FAIL'}  git commit time beats scrambled "
                  f"worktree mtime (incl. non-ASCII paths)")
            failures += 0 if ok else 1
        else:
            print("PASS  git repo fixture skipped (git unusable here)")

    # Fixture 5: a plan whose header says **implemented** must not re-enter
    # "implement", even as the mtime-freshest artifact.
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        plans = root / WORKSPACE_DIR / "plans"
        reports = root / WORKSPACE_DIR / "execution-reports"
        plans.mkdir(parents=True)
        reports.mkdir(parents=True)
        (reports / "shipped.md").write_text("# report\n")
        (plans / "shipped.md").write_text(
            "# Plan: shipped thing\n\n_Branch: x · **implemented**._\n"
        )
        # Second done plan in the bold status-line style the plan template
        # prescribes — asterisks must not defeat the "status: implemented" match.
        (plans / "also-shipped.md").write_text(
            "# Plan: other shipped thing\n\n**Status:** implemented (2026-07-07)\n"
        )
        os.utime(reports / "shipped.md", (1_700_000_000, 1_700_000_000))
        os.utime(plans / "shipped.md", (1_700_000_100, 1_700_000_100))
        os.utime(plans / "also-shipped.md", (1_700_000_100, 1_700_000_100))
        phase, _last, _nxt = detect_state(root)
        ok = phase != "implement"
        print(f"{'PASS' if ok else 'FAIL'}  implemented-plan header skips the implement phase")
        failures += 0 if ok else 1

    # Fixture 6: the several-plans-in-flight guard must fire even when review
    # files exist (it used to be disabled by `review is None`).
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        plans = root / WORKSPACE_DIR / "plans"
        reviews = root / WORKSPACE_DIR / "code-reviews"
        reports = root / WORKSPACE_DIR / "execution-reports"
        for d in (plans, reviews, reports):
            d.mkdir(parents=True)
        (reports / "past.md").write_text("# report\n")
        (reviews / "past.md").write_text("# review\n")
        (plans / "effort-a.md").write_text("# plan a\n")
        (plans / "effort-b.md").write_text("# plan b\n")
        os.utime(reports / "past.md", (1_700_000_000, 1_700_000_000))
        os.utime(reviews / "past.md", (1_700_000_010, 1_700_000_010))
        os.utime(plans / "effort-a.md", (1_700_000_100, 1_700_000_100))
        os.utime(plans / "effort-b.md", (1_700_000_200, 1_700_000_200))
        _phase, last, nxt = detect_state(root)
        ok = nxt == "/cc:next" and "in flight" in last
        print(f"{'PASS' if ok else 'FAIL'}  in-flight guard fires despite existing reviews")
        failures += 0 if ok else 1

    # Fixture 7: log-window overflow clamp. An artifact whose last-touching
    # commit fell outside `git log -n <limit>` must rank BELOW the window (floor
    # clamp), not at its fresh-checkout mtime — raw mtime ≈ now would beat every
    # commit time and a stale artifact would deterministically win. Shrink
    # _LOG_LIMIT to 1 so a 2-commit repo overflows without 300 commits.
    import piv_state as _ps
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        plans = root / WORKSPACE_DIR / "plans"
        reports = root / WORKSPACE_DIR / "execution-reports"
        plans.mkdir(parents=True)
        reports.mkdir(parents=True)
        try:
            (reports / "ancient.md").write_text("# report\n")
            _g(root, "init", "-q")
            _g(root, "add", "-A")
            _g(root, "commit", "-qm", "report", date="2026-01-01T00:00:00 +0000")
            (plans / "current.md").write_text("# plan\n")
            _g(root, "add", "-A")
            _g(root, "commit", "-qm", "plan", date="2026-01-02T00:00:00 +0000")
            git_ok = True
        except Exception:
            git_ok = False
        if git_ok:
            os.utime(plans / "current.md", (1_800_000_000, 1_800_000_000))
            os.utime(reports / "ancient.md", (1_800_000_100, 1_800_000_100))
            orig_limit = _ps._LOG_LIMIT
            _ps._LOG_LIMIT = 1  # window now sees only the plan commit
            try:
                phase, last, _nxt = detect_state(root)
            finally:
                _ps._LOG_LIMIT = orig_limit
            ok = phase == "implement" and "current" in last
            print(f"{'PASS' if ok else 'FAIL'}  overflowed tracked artifact clamps "
                  f"below the log window, not to checkout mtime")
            failures += 0 if ok else 1
        else:
            print("PASS  git repo fixture skipped (git unusable here)")

    # Fixture 8: same-commit tie resolves to the later pipeline stage. A review
    # and a report committed together tie on commit time (and here on mtime) —
    # the report must win, or "next" points at an already-done step.
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        reviews = root / WORKSPACE_DIR / "code-reviews"
        reports = root / WORKSPACE_DIR / "execution-reports"
        reviews.mkdir(parents=True)
        reports.mkdir(parents=True)
        (reviews / "feat.md").write_text("# review\nall resolved\n")
        (reports / "feat.md").write_text("# report\n")
        os.utime(reviews / "feat.md", (1_800_000_000, 1_800_000_000))
        os.utime(reports / "feat.md", (1_800_000_000, 1_800_000_000))
        _phase, last, _nxt = detect_state(root)
        ok = last.startswith("report ")
        print(f"{'PASS' if ok else 'FAIL'}  review/report tie resolves to the "
              f"later stage (report)")
        failures += 0 if ok else 1

    # Fixture 9: a done plan sitting in archive/<year>/plans/ (ADR-002 D3's
    # .specify/archive/ convention) must be invisible to the detector — both
    # `_newest` and `detect_state`'s own `plans_dir.glob("*.md")` are
    # non-recursive, so an archived plan must not surface as "the newest plan"
    # nor affect phase at all. An empty live plans/ dir + only an archived,
    # closed plan present must read identically to a genuinely empty workspace.
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        plans = root / WORKSPACE_DIR / "plans"
        archive_plans = root / WORKSPACE_DIR / "archive" / "2026" / "plans"
        plans.mkdir(parents=True)
        archive_plans.mkdir(parents=True)
        (archive_plans / "old-done.md").write_text(
            "# Plan: old done thing\n\n**Status:** implemented (2026-01-01)\n"
        )
        os.utime(archive_plans / "old-done.md", (1_900_000_000, 1_900_000_000))
        phase, last, nxt = detect_state(root)
        ok = phase == "plan" and last == "—" and nxt == "/cc:plan:feature"
        print(f"{'PASS' if ok else 'FAIL'}  archived plan under archive/<year>/plans/ "
              f"is invisible to the detector (non-recursive glob)")
        failures += 0 if ok else 1

    os.environ.pop("CLAUDE_PROJECT_DIR", None)
    print(f"self-test: {9 - failures}/9 passed")
    return 0 if failures == 0 else 1


if __name__ == "__main__":
    if "--self-test" in sys.argv:
        sys.exit(_self_test())
    try:
        sys.exit(main())
    except Exception:
        # Never let a status helper break a session.
        sys.exit(0)
