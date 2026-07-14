#!/usr/bin/env python3
"""Session-load meter — a gentle "the LLM is getting tired" signal.

Bundled with the cc plugin (hooks/hooks.json) as a PostToolUse hook. The honest
version of "an LLM gets tired" is *accumulated-context error risk*: across a very
long session with many rapid tool iterations (especially multi-minute build / e2e
/ device loops), the odds of a slip climb — a hasty grep, a wrong revert, a
mis-read result. This hook makes that risk observable.

It silently tallies, per session: total tool calls, heavy device/build/e2e runs
(weighted — those are the grind), and elapsed wall-clock. From those it computes a
load score and, when the score crosses ELEVATED / HIGH (rate-limited so it never
spams), injects a one-line nudge into the model's context. The nudge tells the
assistant to surface it to the user AND biases it toward landing in-flight work +
handing complex NEW work to a fresh session instead of grinding.

It is advisory only — never blocks, never fails a turn.

Design rules (this runs after EVERY tool call, for EVERY project):
  * Gentle — emits NOTHING until a threshold is newly crossed; silent otherwise.
  * Unbreakable — everything is wrapped; it ALWAYS exits 0. A meter must never be
    able to fail a user's tool call.
  * Zero dependencies — standard library only, no network, fast (<5ms typical).

Tune the constants below to taste. Self-test: `python3 session-load.py --self-test`.
"""

from __future__ import annotations

import json
import os
import re
import sys
import time
from pathlib import Path

# --- Tunables ---------------------------------------------------------------
HEAVY_WEIGHT = 8          # a build/e2e/device run counts as this many tool calls
ELAPSED_DIVISOR = 8.0     # elapsed minutes / this, added to the score
ELEVATED = 140            # score at which risk is "climbing"
HIGH = 260                # score at which risk is "significant"
COOLDOWN_CALLS = 60       # re-nudge at the same level only after this many more calls

# Bash commands that are multi-minute grinds — the strongest fatigue signal.
HEAVY_RE = re.compile(
    r"\b(expo run|eas build|xcodebuild|gradlew|pod install|npm ci|"
    r"maestro (test|cloud)|e2e[:-]|run e2e|e2e-local-setup|e2e-run|"
    r"simctl (boot|install|erase|bootstatus)|--configuration Release)\b",
    re.IGNORECASE,
)
STATE_DIR = Path(os.environ.get("CC_SESSION_LOAD_DIR") or (Path.home() / ".cache" / "cc" / "session-load"))


# --- Pure logic (unit-tested) ----------------------------------------------
def is_heavy(tool_name: str, command: str) -> bool:
    """True for the multi-minute device/build/e2e loops that drive fatigue."""
    if tool_name and "maestro" in tool_name.lower():
        return True  # mcp maestro run = a device op
    if tool_name == "Bash" and command:
        return bool(HEAVY_RE.search(command))
    return False


def score(calls: int, heavy: int, elapsed_min: float) -> float:
    return calls + HEAVY_WEIGHT * heavy + elapsed_min / ELAPSED_DIVISOR


def level_for(sc: float) -> str:
    if sc >= HIGH:
        return "high"
    if sc >= ELEVATED:
        return "elevated"
    return "none"


def should_nudge(level: str, last_level: str, calls: int, last_nudge_calls: int) -> bool:
    """Nudge on a level increase, or again after COOLDOWN_CALLS at the same level."""
    if level == "none":
        return False
    order = {"none": 0, "elevated": 1, "high": 2}
    if order[level] > order.get(last_level, 0):
        return True
    return calls - last_nudge_calls >= COOLDOWN_CALLS


def human_elapsed(minutes: float) -> str:
    m = int(minutes)
    return f"{m // 60}h{m % 60:02d}m" if m >= 60 else f"{m}m"


def format_nudge(level: str, calls: int, heavy: int, elapsed_min: float) -> str:
    stats = f"~{calls} tool calls, {heavy} build/e2e/device runs, {human_elapsed(elapsed_min)}"
    if level == "high":
        return (
            f"[SESSION-LOAD: HIGH] {stats}. Accumulated-context error-risk is significant "
            "— this is where slips happen (hasty greps, wrong reverts, misread results). "
            "SURFACE THIS TO THE USER, and prefer landing in-flight work + a clean handoff "
            "for complex NEW work over grinding. Heuristic nudge, not a stop."
        )
    return (
        f"[SESSION-LOAD: ELEVATED] {stats}. Accumulated-context error-risk is climbing. "
        "Worth mentioning to the user; favor finishing in-flight work over opening complex "
        "NEW threads. Heuristic nudge, not a stop."
    )


# --- I/O + state (not unit-tested) -----------------------------------------
def _read(session_id: str) -> dict:
    try:
        return json.loads((STATE_DIR / f"{session_id}.json").read_text())
    except Exception:
        return {"calls": 0, "heavy": 0, "first_ts": time.time(),
                "last_nudge_calls": 0, "last_level": "none"}


def _write(session_id: str, st: dict) -> None:
    try:
        STATE_DIR.mkdir(parents=True, exist_ok=True)
        (STATE_DIR / f"{session_id}.json").write_text(json.dumps(st))
    except Exception:
        pass


def _prune() -> None:
    """Best-effort: drop state files older than a day so the cache stays small."""
    try:
        cutoff = time.time() - 86400
        for f in STATE_DIR.glob("*.json"):
            if f.stat().st_mtime < cutoff:
                f.unlink()
    except Exception:
        pass


def main() -> int:
    try:
        hook_input = json.load(sys.stdin)
    except Exception:
        return 0  # malformed/absent stdin — not ours to judge

    try:
        session_id = str(hook_input.get("session_id") or "nosession")
        tool_name = hook_input.get("tool_name") or ""
        tool_input = hook_input.get("tool_input") or {}
        command = tool_input.get("command", "") if isinstance(tool_input, dict) else ""

        st = _read(session_id)
        st["calls"] = st.get("calls", 0) + 1
        if is_heavy(tool_name, command):
            st["heavy"] = st.get("heavy", 0) + 1
        st.setdefault("first_ts", time.time())

        elapsed_min = max(0.0, (time.time() - st["first_ts"]) / 60.0)
        sc = score(st["calls"], st.get("heavy", 0), elapsed_min)
        lvl = level_for(sc)

        nudge = None
        if should_nudge(lvl, st.get("last_level", "none"), st["calls"], st.get("last_nudge_calls", 0)):
            nudge = format_nudge(lvl, st["calls"], st.get("heavy", 0), elapsed_min)
            st["last_level"] = lvl
            st["last_nudge_calls"] = st["calls"]

        _write(session_id, st)
        _prune()

        if nudge:
            print(json.dumps({"hookSpecificOutput": {
                "hookEventName": "PostToolUse", "additionalContext": nudge}}))
    except Exception:
        pass  # unbreakable
    return 0


def _self_test() -> int:
    cases = []
    cases.append(("heavy: expo run", is_heavy("Bash", "npx expo run:ios --configuration Release") is True))
    cases.append(("heavy: maestro test", is_heavy("Bash", "maestro test .maestro") is True))
    cases.append(("heavy: e2e npm", is_heavy("Bash", "npm run e2e:visual:ios") is True))
    cases.append(("heavy: mcp maestro", is_heavy("mcp__maestro__run", "") is True))
    cases.append(("not heavy: ls", is_heavy("Bash", "ls -la") is False))
    cases.append(("not heavy: Read", is_heavy("Read", "") is False))
    cases.append(("score adds heavy+elapsed", score(100, 5, 80) == 100 + 40 + 10))
    cases.append(("level none", level_for(50) == "none"))
    cases.append(("level elevated", level_for(150) == "elevated"))
    cases.append(("level high", level_for(300) == "high"))
    cases.append(("nudge on rise", should_nudge("elevated", "none", 120, 0) is True))
    cases.append(("no nudge same level in cooldown", should_nudge("elevated", "elevated", 130, 120) is False))
    cases.append(("re-nudge after cooldown", should_nudge("high", "high", 200, 130) is True))
    cases.append(("no nudge at none", should_nudge("none", "none", 500, 0) is False))
    cases.append(("elapsed humanize", human_elapsed(160) == "2h40m" and human_elapsed(45) == "45m"))
    cases.append(("nudge mentions user", "SURFACE THIS TO THE USER" in format_nudge("high", 300, 10, 190)))
    failures = 0
    for name, ok in cases:
        print(f"{'PASS' if ok else 'FAIL'}  {name}")
        failures += 0 if ok else 1
    print(f"self-test: {len(cases) - failures}/{len(cases)} passed")
    return 1 if failures else 0


if __name__ == "__main__":
    if "--self-test" in sys.argv:
        sys.exit(_self_test())
    sys.exit(main())
