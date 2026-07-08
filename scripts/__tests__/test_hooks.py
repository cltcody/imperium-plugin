#!/usr/bin/env python3
"""Behavioral tests for imperium's PIV hooks (global/hooks/*.py).

Run: pytest global/scripts/__tests__/test_hooks.py -q  (or just `pytest` from
repo root once a venv with pytest is active — see __tests__/README.md).

Hermetic by construction: every fixture lives under pytest's `tmp_path`
(auto-cleaned temp dir) or `tempfile.TemporaryDirectory()`; nothing here
touches the real repo, ~/.claude, or the network.

Four of these hooks already ship an embedded `--self-test` with its own
fixtures (block-secrets.py, commit-gate.py, piv-status.py,
pre-compact-snapshot.py). Re-deriving those fixtures here would just drift
from the real ones over time, so this file:
  1. runs each embedded self-test as a subprocess and asserts it passes
     (`test_embedded_self_test_passes`) — this is what CI now gates on,
  2. adds tests for the parts those self-tests do NOT cover: the real
     stdin-JSON / argv / exit-code CONTRACT each hook is actually invoked
     with by Claude Code (the embedded self-tests call pure Python functions
     or `main()` in-process, never the subprocess/stdin path), and
  3. fully covers block-corporate-artifacts.py, which ships no self-test
     at all.
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

import pytest

HOOKS = Path(__file__).resolve().parents[2] / "hooks"
PY = sys.executable

# A git identity + isolated config so commits work in a fresh temp dir
# regardless of the host's global gitconfig (gpg signing, missing user.*,
# etc.) — same recipe the hooks' own embedded self-tests use.
GIT_ENV = {
    "GIT_CONFIG_GLOBAL": "/dev/null",
    "GIT_CONFIG_NOSYSTEM": "1",
    "GIT_AUTHOR_NAME": "t",
    "GIT_AUTHOR_EMAIL": "t@t",
    "GIT_COMMITTER_NAME": "t",
    "GIT_COMMITTER_EMAIL": "t@t",
}


def _git(cwd: Path, *args: str) -> None:
    subprocess.run(
        ["git", *args], cwd=cwd, env={**os.environ, **GIT_ENV},
        capture_output=True, text=True, timeout=10, check=True,
    )


def _git_ok(cwd: Path) -> bool:
    """True if a usable git is present (mirrors the hooks' own skip pattern)."""
    try:
        _git(cwd, "init", "-q")
        return True
    except Exception:
        return False


def run_hook(name: str, *args: str, stdin: str | None = None, cwd: Path | None = None,
             env: dict | None = None, timeout: int = 20) -> subprocess.CompletedProcess:
    full_env = {**os.environ, **(env or {})}
    return subprocess.run(
        [PY, str(HOOKS / name), *args],
        input=stdin, capture_output=True, text=True,
        cwd=str(cwd) if cwd else None, env=full_env, timeout=timeout,
    )


# ---------------------------------------------------------------------------
# 1. Embedded self-tests, run as CI would run them.
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("hook_name", [
    "block-secrets.py",
    "commit-gate.py",
    "piv-status.py",
    "pre-compact-snapshot.py",
])
def test_embedded_self_test_passes(hook_name):
    proc = run_hook(hook_name, "--self-test")
    assert proc.returncode == 0, proc.stdout + proc.stderr
    assert "FAIL" not in proc.stdout, proc.stdout


# ---------------------------------------------------------------------------
# 2. piv_state.py — the CLI contract (`--cwd`, tab-separated stdout).
# ---------------------------------------------------------------------------

def _piv_state(cwd: Path) -> tuple[str, str, str]:
    proc = run_hook("piv_state.py", "--cwd", str(cwd))
    assert proc.returncode == 0, proc.stderr
    phase, last, nxt = proc.stdout.rstrip("\n").split("\t")
    return phase, last, nxt


def test_piv_state_plan_phase_with_a_live_plan(tmp_path):
    plans = tmp_path / ".specify" / "plans"
    plans.mkdir(parents=True)
    phase, _last, nxt = _piv_state(tmp_path)
    assert phase == "plan"
    assert nxt == "/cc:plan:feature"


def test_piv_state_implement_phase_when_newest_artifact_is_a_live_plan(tmp_path):
    plans = tmp_path / ".specify" / "plans"
    plans.mkdir(parents=True)
    (plans / "feature.md").write_text("# Plan: feature\n")
    phase, last, nxt = _piv_state(tmp_path)
    assert phase == "implement"
    assert "feature" in last
    assert nxt == "/cc:implement:execute"


def test_piv_state_clean_phase_when_only_a_done_plan_exists(tmp_path):
    plans = tmp_path / ".specify" / "plans"
    plans.mkdir(parents=True)
    (plans / "done.md").write_text("# Plan: done\n\n**Status:** implemented\n")
    phase, last, nxt = _piv_state(tmp_path)
    assert phase == "clean"
    assert "done" in last
    assert nxt == "/cc:next"


def test_piv_state_no_workspace_is_not_a_piv_project(tmp_path):
    # No .specify/ dir at all, and no git repo either -> fully empty state.
    phase, last, nxt = _piv_state(tmp_path)
    assert phase == ""
    assert last == "—"


def test_piv_state_archived_done_plan_is_invisible_non_recursive_glob(tmp_path):
    """ADR-002 D3's `.specify/archive/<year>/plans/` convention: an archived,
    already-closed plan must never surface as "the newest plan" nor drive
    phase — plans/ globbing is non-recursive by design."""
    plans = tmp_path / ".specify" / "plans"
    archive_plans = tmp_path / ".specify" / "archive" / "2026" / "plans"
    plans.mkdir(parents=True)
    archive_plans.mkdir(parents=True)
    (archive_plans / "old-done.md").write_text(
        "# Plan: old done thing\n\n**Status:** implemented (2026-01-01)\n"
    )
    phase, last, nxt = _piv_state(tmp_path)
    assert phase == "plan"
    assert last == "—"
    assert nxt == "/cc:plan:feature"


# ---------------------------------------------------------------------------
# 3. commit-gate.py — the real PreToolUse stdin-JSON contract.
# ---------------------------------------------------------------------------

def _make_gate_repo(tmp_path: Path, validate_cmd: str) -> Path:
    if not _git_ok(tmp_path):
        pytest.skip("git unusable in this environment")
    claude_dir = tmp_path / ".claude"
    claude_dir.mkdir()
    (claude_dir / "piv-gate.json").write_text(json.dumps({"validate": validate_cmd}))
    _git(tmp_path, "add", "-A")
    _git(tmp_path, "commit", "-qm", "add gate")
    return tmp_path


def _commit_hook_input(command: str = "git commit -m 'x'") -> str:
    return json.dumps({"tool_name": "Bash", "tool_input": {"command": command}})


def test_commit_gate_passes_when_validate_command_succeeds(tmp_path):
    repo = _make_gate_repo(tmp_path, "true")
    proc = run_hook(
        "commit-gate.py", stdin=_commit_hook_input(), cwd=repo,
        env={"CLAUDE_PROJECT_DIR": str(repo)},
    )
    assert proc.returncode == 0, proc.stderr


def test_commit_gate_blocks_when_validate_command_fails(tmp_path):
    repo = _make_gate_repo(tmp_path, "false")
    proc = run_hook(
        "commit-gate.py", stdin=_commit_hook_input(), cwd=repo,
        env={"CLAUDE_PROJECT_DIR": str(repo)},
    )
    assert proc.returncode == 2
    assert "PIV COMMIT GATE" in proc.stderr
    assert "validation failed" in proc.stderr


def test_commit_gate_ignores_non_commit_commands(tmp_path):
    repo = _make_gate_repo(tmp_path, "false")  # gate would block a real commit
    proc = run_hook(
        "commit-gate.py", stdin=_commit_hook_input("git status"), cwd=repo,
        env={"CLAUDE_PROJECT_DIR": str(repo)},
    )
    assert proc.returncode == 0


def test_commit_gate_allows_when_no_gate_file_at_head(tmp_path):
    if not _git_ok(tmp_path):
        pytest.skip("git unusable in this environment")
    (tmp_path / "readme.md").write_text("hi\n")
    _git(tmp_path, "add", "-A")
    _git(tmp_path, "commit", "-qm", "init")
    proc = run_hook(
        "commit-gate.py", stdin=_commit_hook_input(), cwd=tmp_path,
        env={"CLAUDE_PROJECT_DIR": str(tmp_path)},
    )
    assert proc.returncode == 0


# ---------------------------------------------------------------------------
# 4. block-secrets.py — the real PreToolUse stdin-JSON contract.
# ---------------------------------------------------------------------------

def test_block_secrets_blocks_env_read_via_stdin():
    payload = json.dumps({"tool_name": "Read", "tool_input": {"file_path": "app/.env"}})
    proc = run_hook("block-secrets.py", stdin=payload)
    assert proc.returncode == 2
    assert "SECURITY" in proc.stderr


def test_block_secrets_allows_normal_read_via_stdin():
    payload = json.dumps({"tool_name": "Read", "tool_input": {"file_path": "src/index.ts"}})
    proc = run_hook("block-secrets.py", stdin=payload)
    assert proc.returncode == 0
    assert proc.stderr == ""


def test_block_secrets_fails_open_on_malformed_stdin():
    proc = run_hook("block-secrets.py", stdin="not json at all")
    assert proc.returncode == 0


# ---------------------------------------------------------------------------
# 5. block-corporate-artifacts.py — no embedded self-test; full coverage here.
# ---------------------------------------------------------------------------

def _write_stack_md(repo: Path, class_value: str) -> None:
    (repo / "STACK.md").write_text(f"---\nclass: {class_value}\n---\n# Stack\n")


def _write_hook_input(file_path: Path, tool_name: str = "Write") -> str:
    return json.dumps({"tool_name": tool_name, "tool_input": {"file_path": str(file_path)}})


def test_block_corporate_artifacts_blocks_write_under_accounts_in_corporate_repo(tmp_path):
    if not _git_ok(tmp_path):
        pytest.skip("git unusable in this environment")
    _write_stack_md(tmp_path, "corporate")
    target = tmp_path / "accounts" / "brief.md"
    target.parent.mkdir(parents=True, exist_ok=True)
    proc = run_hook("block-corporate-artifacts.py", stdin=_write_hook_input(target))
    assert proc.returncode == 2
    assert "corporate" in proc.stderr.lower()


def test_block_corporate_artifacts_allows_write_under_accounts_in_noncorporate_repo(tmp_path):
    if not _git_ok(tmp_path):
        pytest.skip("git unusable in this environment")
    _write_stack_md(tmp_path, "personal")
    target = tmp_path / "accounts" / "brief.md"
    target.parent.mkdir(parents=True, exist_ok=True)
    proc = run_hook("block-corporate-artifacts.py", stdin=_write_hook_input(target))
    assert proc.returncode == 0


def test_block_corporate_artifacts_allows_path_outside_guarded_segments(tmp_path):
    if not _git_ok(tmp_path):
        pytest.skip("git unusable in this environment")
    _write_stack_md(tmp_path, "corporate")
    target = tmp_path / "src" / "index.ts"
    target.parent.mkdir(parents=True, exist_ok=True)
    proc = run_hook("block-corporate-artifacts.py", stdin=_write_hook_input(target))
    assert proc.returncode == 0


def test_block_corporate_artifacts_allows_when_no_stack_md_present(tmp_path):
    if not _git_ok(tmp_path):
        pytest.skip("git unusable in this environment")
    target = tmp_path / "accounts" / "brief.md"
    target.parent.mkdir(parents=True, exist_ok=True)
    proc = run_hook("block-corporate-artifacts.py", stdin=_write_hook_input(target))
    assert proc.returncode == 0


def test_block_corporate_artifacts_fails_open_on_malformed_stdin():
    proc = run_hook("block-corporate-artifacts.py", stdin="not json at all")
    assert proc.returncode == 0


# ---------------------------------------------------------------------------
# 6. pre-compact-snapshot.py — the real subprocess/env-var contract (its
#    embedded self-test calls main() in-process; this exercises the actual
#    CLAUDE_PROJECT_DIR-driven subprocess path Claude Code invokes).
# ---------------------------------------------------------------------------

def test_pre_compact_snapshot_writes_session_md_via_subprocess(tmp_path):
    plans = tmp_path / ".specify" / "plans"
    plans.mkdir(parents=True)
    (plans / "feature.md").write_text("# plan\n")
    proc = run_hook(
        "pre-compact-snapshot.py", env={"CLAUDE_PROJECT_DIR": str(tmp_path)},
    )
    assert proc.returncode == 0
    snapshot = tmp_path / ".specify" / "session.md"
    assert snapshot.is_file()
    content = snapshot.read_text(encoding="utf-8")
    assert "Session Cursor" in content
    assert "auto-generated by PreCompact hook" in content


def test_pre_compact_snapshot_is_a_noop_outside_a_piv_project(tmp_path):
    proc = run_hook(
        "pre-compact-snapshot.py", env={"CLAUDE_PROJECT_DIR": str(tmp_path)},
    )
    assert proc.returncode == 0
    assert list(tmp_path.rglob("*")) == []
