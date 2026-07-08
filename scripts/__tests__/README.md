# `__tests__/` — behavioral test suite

Three independent suites live here. All are hermetic: temp dirs only, no
network, no writes outside their own fixtures.

## 1. `pr-digest.test.mjs` — Node

Tests the PR-digest script's pure classification helpers.

```bash
node --test global/scripts/__tests__/pr-digest.test.mjs
```

## 2. `test_hooks.py` — pytest, for the Python PIV hooks

Covers `global/hooks/piv_state.py`, `piv-status.py`, `commit-gate.py`,
`block-secrets.py`, `block-corporate-artifacts.py`, and
`pre-compact-snapshot.py`. Where a hook already ships an embedded
`--self-test`, this suite runs that self-test as a subprocess (so the two
never drift) and adds tests for what the self-test *doesn't* reach — mainly
the real stdin-JSON / argv / exit-code contract Claude Code actually invokes
each hook with.

```bash
python3 -m venv .venv && .venv/bin/pip install pytest   # one-time
.venv/bin/pytest global/scripts/__tests__/test_hooks.py -q
```

Or, with any environment that already has `pytest` on PATH:

```bash
pytest global/scripts/__tests__/test_hooks.py -q
```

Requires `git` on PATH (a few fixtures build a real temp git repo); those
fixtures skip cleanly with a `PASS ... skipped` line if git is unusable in
the environment, rather than failing.

## 3. `test_scripts.sh` — plain-bash asserter, for the install/distribution shell scripts

Covers `install.sh` (idempotency) and `cc-profile-filter.sh` (each profile in
`global/scripts/mirror-profiles/*.json` yields the expected catalog shape).
No `bats` dependency — just bash + the assert helpers defined in the file.

```bash
bash global/scripts/__tests__/test_scripts.sh
```

`install.sh`'s CC-publish path shells out to the real `claude` CLI against
the user's actual global install (marketplace registration, `--scope user`
plugin install) — a genuinely hermetic test cannot invoke that binary, since
doing so would mutate the tester's real `~/.claude`. Instead the script puts
a minimal stub `claude` executable first on `PATH` that only records state to
a scratch directory; this still exercises `install.sh`'s real control flow
(flag parsing, `cc-publish.sh`'s already-registered-marketplace detection,
the uninstall-then-reinstall dance) — only the terminal `claude` binary
itself is faked. `cc-profile-filter.sh` needs no such stub: it operates
directly on a `CLAUDE_CONFIG_DIR`-scoped fixture tree, which the script
points at a throwaway temp directory.

## Running everything

```bash
node --test global/scripts/__tests__/pr-digest.test.mjs
pytest global/scripts/__tests__/test_hooks.py -q
bash global/scripts/__tests__/test_scripts.sh
```

CI (`.github/workflows/audit.yml`) runs the pytest hook suite and the bash script
asserter on every push/PR. The Node `pr-digest.test.mjs` suite is run locally (not yet
CI-gated).
