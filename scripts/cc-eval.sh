#!/usr/bin/env bash
# cc-eval.sh — Eval harness v1 for the cc plugin's prompts (Phase 3.7).
#
# Regression tests for slash-command prompts. Each case under evals/cases/<name>/ pairs a
# tiny synthetic fixture project with a `checks.sh` that makes deterministic assertions
# about the output — this is NOT an LLM-judged eval.
#
# Two modes:
#   --dry-run (default-safe, no `claude` needed): for each case, copies its authored
#     `fixture-expected/` golden directory into a sandbox and runs `checks.sh` against it.
#     This proves the *checks themselves* are correct, independent of whether `claude` is
#     installed here — this is what CI and contributors without `claude` on PATH run.
#   live (default, no flag): for each case, copies `fixture/` into a sandbox, runs
#     `claude -p "<command> <args>" --model haiku --permission-mode acceptEdits` from the
#     sandbox, captures the printed response to `.eval-transcript.txt`, then runs
#     `checks.sh` against the resulting sandbox + transcript.
#
# Live mode needs the `claude` binary AND the cc plugin available to it — either the
# plugin is already installed normally, or point `claude` at this checkout for the run
# with `--plugin-dir "$REPO_ROOT/global"` (pass `--plugin-dir <path>` to this script to
# forward it). Without `claude` on PATH, every case in live mode SKIPs with a notice
# instead of failing — this is expected in CI, which has no `claude` binary.
#
# A case may set "expected_new": true in its case.json to mark that the command it drives
# does not exist yet (e.g. added by a parallel workstream). In live mode, such a case
# reports PENDING instead of FAIL when the command errors or the checks don't pass yet.
# In --dry-run mode it is still checked against its authored `fixture-expected/` golden
# dir like any other case, and is expected to PASS today (proving the checks are ready).
#
# LLM-judged cases: a case may additionally set
#   "judge": { "rubric": "judges/<name>.md", "threshold": 6 }
# in its case.json (rubric path is relative to evals/, or absolute). In live mode, after
# the command runs AND the case's deterministic checks.sh passes (structure gate), the
# harness invokes `claude -p` once more as a judge: the prompt is the rubric file plus the
# captured transcript (the artifact under test), and the judge must emit per-dimension
# lines and a final `SCORE: <0-10>` line. The case PASSes only if score >= threshold.
# The full judge output is saved to <sandbox>/.eval-judge.txt (use --keep-sandbox to read
# it). In --dry-run mode the judge is NOT invoked: the rubric file's existence is
# validated and checks.sh runs against fixture-expected/ as usual. Judged cases SKIP in
# live mode when `claude` is absent, same as every other case.
#
# Test assets live at the REPO ROOT under evals/ (NOT under global/) so they never ship
# in the plugin payload.
#
# Bash 3.2-compatible (macOS default): no associative arrays, no mapfile, no `${x,,}`.
# JSON parsing is delegated to python3 (already a hard requirement elsewhere in this repo
# — see scripts/cc-apply.sh, scripts/cc-audit.sh).
#
# Usage:
#   bash global/scripts/cc-eval.sh [--dry-run] [--case NAME[,NAME...]] [--list]
#                                   [--plugin-dir PATH] [--keep-sandbox] [-h|--help]
#
# Exit code: non-zero if any case FAILs (or has a structural ERROR). SKIP and PENDING do
# not affect the exit code.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GLOBAL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"        # .../global
REPO_ROOT="$(cd "$GLOBAL_ROOT/.." && pwd)"         # repo root (parent of global/)
EVALS_DIR="$REPO_ROOT/evals"
CASES_DIR="$EVALS_DIR/cases"

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 is required" >&2
  exit 1
fi

# ── Options ────────────────────────────────────────────────────────────────────
DRY_RUN=0
LIST_ONLY=0
KEEP_SANDBOX=0
PLUGIN_DIR=""
SELECTED_CASES=""   # space-separated, empty = all

usage() {
  cat <<'USAGE'
Usage: bash global/scripts/cc-eval.sh [options]

Options:
  --dry-run              Validate case structure and run each checks.sh against its
                          fixture-expected/ golden dir instead of invoking `claude`.
                          Does not require the `claude` binary.
  --case NAME[,NAME...]  Only run the named case(s). May be passed more than once.
  --list                 List discovered case names and exit.
  --plugin-dir PATH      Forwarded to `claude -p --plugin-dir PATH` in live mode, so the
                          cc plugin doesn't need to be installed to run the eval.
  --keep-sandbox         Do not delete per-case sandboxes; print their paths.
  -h, --help             Show this help.

Exit code is non-zero if any case FAILs. SKIP and PENDING never affect the exit code.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --case)
      [[ $# -ge 2 ]] || { echo "Error: --case requires an argument" >&2; exit 1; }
      SELECTED_CASES="$SELECTED_CASES ${2//,/ } "
      shift 2
      ;;
    --list)
      LIST_ONLY=1
      shift
      ;;
    --plugin-dir)
      [[ $# -ge 2 ]] || { echo "Error: --plugin-dir requires an argument" >&2; exit 1; }
      PLUGIN_DIR="$2"
      shift 2
      ;;
    --keep-sandbox)
      KEEP_SANDBOX=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown option '$1'" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! -d "$CASES_DIR" ]]; then
  echo "Error: no cases directory found at $CASES_DIR" >&2
  exit 1
fi

# ── Output helpers ────────────────────────────────────────────────────────────
rule() { printf '\n\033[1m%s\033[0m\n%s\n' "$1" "──────────────────────────────────────────────────────────────"; }
pass_line()    { printf '✅ PASS    %s — %s\n' "$1" "$2"; }
fail_line()    { printf '❌ FAIL    %s — %s\n' "$1" "$2"; }
skip_line()    { printf '⏭️  SKIP    %s — %s\n' "$1" "$2"; }
pending_line() { printf '⏳ PENDING %s — %s\n' "$1" "$2"; }
error_line()   { printf '🛑 ERROR   %s — %s\n' "$1" "$2"; }

case_selected() {
  # $1 = case name. Returns success if no --case filter was given, or the name is in it.
  [[ -z "$SELECTED_CASES" ]] && return 0
  [[ "$SELECTED_CASES" == *" $1 "* ]] && return 0
  return 1
}

# ── JSON case reader (delegated to python3; prints shell-safe KEY=VALUE lines) ─────────
read_case() {
  # $1 = path to case.json. Prints EVAL_* assignments to stdout, or a python traceback +
  # non-zero exit if case.json is missing a required field / isn't valid JSON.
  python3 - "$1" <<'PYEOF'
import json
import shlex
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)

required = ["name", "command", "fixture", "fixture_expected", "checks"]
missing = [k for k in required if not data.get(k)]
if missing:
    print("missing required case.json field(s): %s" % ", ".join(missing), file=sys.stderr)
    sys.exit(2)


def out(key, value):
    print("EVAL_%s=%s" % (key, shlex.quote(str(value))))


out("NAME", data.get("name", ""))
out("DESCRIPTION", data.get("description", ""))
out("COMMAND", data.get("command", ""))
out("ARGS", data.get("args", ""))
out("FIXTURE", data.get("fixture", "fixture"))
out("FIXTURE_EXPECTED", data.get("fixture_expected", "fixture-expected"))
out("CHECKS", data.get("checks", "checks.sh"))
out("TIMEOUT", data.get("timeout_seconds", 120))
out("MAX_TURNS", data.get("max_turns", 20))
out("EXPECTED_NEW", "true" if data.get("expected_new") else "false")

judge = data.get("judge") or {}
if judge:
    if not isinstance(judge, dict) or not judge.get("rubric"):
        print("judge block present but missing 'rubric'", file=sys.stderr)
        sys.exit(2)
    threshold = judge.get("threshold", 6)
    if not isinstance(threshold, int) or not (0 <= threshold <= 10):
        print("judge.threshold must be an integer 0-10", file=sys.stderr)
        sys.exit(2)
    out("JUDGE_RUBRIC", judge["rubric"])
    out("JUDGE_THRESHOLD", threshold)
else:
    out("JUDGE_RUBRIC", "")
    out("JUDGE_THRESHOLD", "")
PYEOF
}

# ── claude binary / feature detection (live mode only) ─────────────────────────
CLAUDE_BIN=""
CLAUDE_SUPPORTS_MAX_TURNS=0
TIMEOUT_BIN=""

detect_claude() {
  if command -v claude >/dev/null 2>&1; then
    CLAUDE_BIN="claude"
    if claude --help 2>&1 | grep -q -- '--max-turns'; then
      CLAUDE_SUPPORTS_MAX_TURNS=1
    fi
  fi
  if command -v timeout >/dev/null 2>&1; then
    TIMEOUT_BIN="timeout"
  elif command -v gtimeout >/dev/null 2>&1; then
    TIMEOUT_BIN="gtimeout"
  fi
}

# ── Sandbox helpers ──────────────────────────────────────────────────────────
make_sandbox() {
  mktemp -d "${TMPDIR:-/tmp}/cc-eval.XXXXXXXX"
}

populate_sandbox() {
  # $1 = source dir (fixture or fixture-expected), $2 = sandbox dir
  cp -R "$1/." "$2/"
}

git_init_sandbox() {
  # $1 = sandbox dir. Many dev commands (prime, pause, plan:*) assume a git repo context
  # (git status/log/branch); give live-mode sandboxes a trivial baseline commit so those
  # steps behave sensibly instead of erroring on "not a git repository". Best-effort —
  # never fatal to the eval run.
  (
    cd "$1" || exit 0
    git init -q -b main >/dev/null 2>&1 || git init -q >/dev/null 2>&1
    git add -A >/dev/null 2>&1
    git -c user.email=cc-eval@example.com -c user.name=cc-eval commit -q -m "fixture baseline" >/dev/null 2>&1
  ) || true
}

# ── Judge helpers (LLM-judged cases) ─────────────────────────────────────────
resolve_rubric_path() {
  # $1 = rubric path from case.json. Relative paths resolve against evals/.
  case "$1" in
    /*) printf '%s\n' "$1" ;;
    *)  printf '%s\n' "$EVALS_DIR/$1" ;;
  esac
}

run_judge() {
  # $1 = absolute rubric path, $2 = artifact file (the captured transcript),
  # $3 = sandbox dir. On success prints the judge's integer overall score to stdout and
  # returns 0. On any problem prints a human-readable reason and returns non-zero. The
  # judge's full output is saved to <sandbox>/.eval-judge.txt either way.
  local rubric="$1"
  local artifact="$2"
  local sandbox="$3"
  local judge_out="$sandbox/.eval-judge.txt"
  local prompt=""
  local score=""
  local jrc=0

  if [[ ! -s "$artifact" ]]; then
    echo "nothing to judge — transcript is missing or empty"
    return 1
  fi

  prompt="You are an exacting evaluation judge. Score the ARTIFACT UNDER TEST against the RUBRIC below.
Apply the rubric's anchored score descriptions and calibration examples literally — do not substitute
your own softer standard. For every dimension, output one line:
  DIMENSION <name>: <0-10> — <one-line justification quoting the artifact's own words as evidence>
Then output exactly one final line, with nothing after it:
  SCORE: <integer 0-10>
where the integer is the overall score computed per the rubric's scoring rules.

=== RUBRIC ===
$(cat "$rubric")

=== ARTIFACT UNDER TEST ===
$(cat "$artifact")"

  local jcmd=("$CLAUDE_BIN" -p "$prompt" --model haiku)
  if [[ -n "$TIMEOUT_BIN" ]]; then
    jcmd=("$TIMEOUT_BIN" "${EVAL_TIMEOUT}s" "${jcmd[@]}")
  fi

  "${jcmd[@]}" >"$judge_out" 2>>"$sandbox/.eval-stderr.txt"
  jrc=$?
  if [[ "$jrc" -ne 0 ]]; then
    echo "judge invocation exited $jrc"
    return 1
  fi

  score="$(grep -E 'SCORE:[[:space:]]*[0-9]+' "$judge_out" | tail -n 1 | grep -Eo '[0-9]+' | head -n 1)"
  if [[ -z "$score" ]]; then
    echo "judge output has no 'SCORE: <0-10>' line"
    return 1
  fi
  printf '%s\n' "$score"
  return 0
}

# ── Structural validation (both modes) ──────────────────────────────────────
validate_case_structure() {
  # $1 = case dir. Prints a reason to stdout and returns non-zero if invalid.
  local case_dir="$1"
  local case_json="$case_dir/case.json"

  if [[ ! -f "$case_json" ]]; then
    echo "no case.json found"
    return 1
  fi
  if [[ ! -d "$case_dir/${EVAL_FIXTURE:-fixture}" ]]; then
    echo "fixture dir '${EVAL_FIXTURE:-fixture}' not found"
    return 1
  fi
  if [[ ! -d "$case_dir/${EVAL_FIXTURE_EXPECTED:-fixture-expected}" ]]; then
    echo "fixture_expected dir '${EVAL_FIXTURE_EXPECTED:-fixture-expected}' not found"
    return 1
  fi
  if [[ ! -f "$case_dir/${EVAL_CHECKS:-checks.sh}" ]]; then
    echo "checks file '${EVAL_CHECKS:-checks.sh}' not found"
    return 1
  fi
  if [[ -n "${EVAL_JUDGE_RUBRIC:-}" ]]; then
    local rubric_abs
    rubric_abs="$(resolve_rubric_path "$EVAL_JUDGE_RUBRIC")"
    if [[ ! -f "$rubric_abs" ]]; then
      echo "judge rubric '$EVAL_JUDGE_RUBRIC' not found (resolved to $rubric_abs)"
      return 1
    fi
  fi
  return 0
}

# ── Main ─────────────────────────────────────────────────────────────────────
CASE_DIRS=""
for d in "$CASES_DIR"/*/; do
  [[ -d "$d" ]] || continue
  CASE_DIRS="$CASE_DIRS $d"
done

if [[ -z "${CASE_DIRS// /}" ]]; then
  echo "Error: no cases found under $CASES_DIR" >&2
  exit 1
fi

if [[ "$LIST_ONLY" -eq 1 ]]; then
  for case_dir in $CASE_DIRS; do
    basename "$case_dir"
  done
  exit 0
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
  detect_claude
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  rule "cc-eval — dry-run (checks.sh vs. fixture-expected/, no claude invoked)"
else
  rule "cc-eval — live ($(date '+%Y-%m-%d %H:%M:%S'))"
  if [[ -z "$CLAUDE_BIN" ]]; then
    echo "Notice: 'claude' binary not found on PATH — every case will SKIP."
  fi
fi

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
PENDING_COUNT=0
ERROR_COUNT=0

for case_dir in $CASE_DIRS; do
  case_name="$(basename "$case_dir")"
  case_selected "$case_name" || continue

  case_json="$case_dir/case.json"
  if [[ ! -f "$case_json" ]]; then
    error_line "$case_name" "no case.json found"
    ERROR_COUNT=$((ERROR_COUNT + 1))
    continue
  fi

  read_out="$(read_case "$case_json" 2>&1)"
  read_rc=$?
  if [[ "$read_rc" -ne 0 ]]; then
    error_line "$case_name" "invalid case.json — $read_out"
    ERROR_COUNT=$((ERROR_COUNT + 1))
    continue
  fi
  eval "$read_out"

  struct_err="$(validate_case_structure "$case_dir")"
  if [[ -n "$struct_err" ]]; then
    error_line "$case_name" "$struct_err"
    ERROR_COUNT=$((ERROR_COUNT + 1))
    continue
  fi

  sandbox="$(make_sandbox)"
  transcript="$sandbox/.eval-transcript.txt"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    populate_sandbox "$case_dir/$EVAL_FIXTURE_EXPECTED" "$sandbox"
    checks_out="$(bash "$case_dir/$EVAL_CHECKS" "$sandbox" "$transcript" 2>&1)"
    checks_rc=$?
    if [[ "$checks_rc" -eq 0 ]]; then
      pass_line "$case_name" "$EVAL_DESCRIPTION"
      PASS_COUNT=$((PASS_COUNT + 1))
    else
      fail_line "$case_name" "checks.sh failed against fixture-expected/ — $checks_out"
      FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
  else
    if [[ -z "$CLAUDE_BIN" ]]; then
      skip_line "$case_name" "claude binary not found on PATH"
      SKIP_COUNT=$((SKIP_COUNT + 1))
      [[ "$KEEP_SANDBOX" -eq 1 ]] || rm -rf "$sandbox"
      continue
    fi

    populate_sandbox "$case_dir/$EVAL_FIXTURE" "$sandbox"
    git_init_sandbox "$sandbox"

    prompt="$EVAL_COMMAND"
    [[ -n "$EVAL_ARGS" ]] && prompt="$prompt $EVAL_ARGS"

    cmd=("$CLAUDE_BIN" -p "$prompt" --model haiku --permission-mode acceptEdits)
    [[ "$CLAUDE_SUPPORTS_MAX_TURNS" -eq 1 ]] && cmd+=(--max-turns "$EVAL_MAX_TURNS")
    [[ -n "$PLUGIN_DIR" ]] && cmd+=(--plugin-dir "$PLUGIN_DIR")

    if [[ -n "$TIMEOUT_BIN" ]]; then
      cmd=("$TIMEOUT_BIN" "${EVAL_TIMEOUT}s" "${cmd[@]}")
    fi

    (cd "$sandbox" && "${cmd[@]}" >"$transcript" 2>"$sandbox/.eval-stderr.txt")
    run_rc=$?

    if [[ "$run_rc" -ne 0 && "$EVAL_EXPECTED_NEW" == "true" ]]; then
      pending_line "$case_name" "command exited $run_rc (expected_new — command likely not landed yet)"
      PENDING_COUNT=$((PENDING_COUNT + 1))
    else
      checks_out="$(bash "$case_dir/$EVAL_CHECKS" "$sandbox" "$transcript" 2>&1)"
      checks_rc=$?
      if [[ "$checks_rc" -eq 0 && -n "$EVAL_JUDGE_RUBRIC" ]]; then
        # Structure gate passed — now the LLM judge scores the transcript vs. the rubric.
        rubric_abs="$(resolve_rubric_path "$EVAL_JUDGE_RUBRIC")"
        judge_out="$(run_judge "$rubric_abs" "$transcript" "$sandbox")"
        judge_rc=$?
        if [[ "$judge_rc" -eq 0 && "$judge_out" -ge "$EVAL_JUDGE_THRESHOLD" ]]; then
          pass_line "$case_name" "$EVAL_DESCRIPTION (judge: $judge_out/10 >= $EVAL_JUDGE_THRESHOLD)"
          PASS_COUNT=$((PASS_COUNT + 1))
        elif [[ "$EVAL_EXPECTED_NEW" == "true" ]]; then
          pending_line "$case_name" "judge not satisfied yet — ${judge_out:-no score} (threshold $EVAL_JUDGE_THRESHOLD)"
          PENDING_COUNT=$((PENDING_COUNT + 1))
        elif [[ "$judge_rc" -ne 0 ]]; then
          fail_line "$case_name" "judge error — $judge_out"
          FAIL_COUNT=$((FAIL_COUNT + 1))
        else
          fail_line "$case_name" "judge scored $judge_out/10, below threshold $EVAL_JUDGE_THRESHOLD (see .eval-judge.txt with --keep-sandbox)"
          FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
      elif [[ "$checks_rc" -eq 0 ]]; then
        pass_line "$case_name" "$EVAL_DESCRIPTION"
        PASS_COUNT=$((PASS_COUNT + 1))
      elif [[ "$EVAL_EXPECTED_NEW" == "true" ]]; then
        pending_line "$case_name" "checks.sh not satisfied yet — $checks_out"
        PENDING_COUNT=$((PENDING_COUNT + 1))
      else
        fail_line "$case_name" "$checks_out"
        FAIL_COUNT=$((FAIL_COUNT + 1))
      fi
    fi
  fi

  if [[ "$KEEP_SANDBOX" -eq 1 ]]; then
    echo "     sandbox kept: $sandbox"
  else
    rm -rf "$sandbox"
  fi
done

rule "Summary"
printf '  Pass:    %d\n' "$PASS_COUNT"
printf '  Fail:    %d\n' "$FAIL_COUNT"
printf '  Skip:    %d\n' "$SKIP_COUNT"
printf '  Pending: %d\n' "$PENDING_COUNT"
printf '  Error:   %d\n' "$ERROR_COUNT"
echo ""

if [[ "$FAIL_COUNT" -gt 0 || "$ERROR_COUNT" -gt 0 ]]; then
  echo "❌ cc-eval FAILED — $FAIL_COUNT failure(s), $ERROR_COUNT error(s)."
  exit 1
else
  echo "✅ cc-eval PASSED — $PASS_COUNT passed, $SKIP_COUNT skipped, $PENDING_COUNT pending."
  exit 0
fi
