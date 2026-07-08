#!/usr/bin/env bash
# cc-filter.sh — shared primitives for the two operations several cc install/
# distribution scripts perform: (a) reading a mirror-profile's exclude list, and
# (b) baking cc.config.json values into content (${user_config.*} + [TOKEN]
# substitution).
#
# This is a SOURCED library. It defines functions and must not be executed
# directly — source it from a script that has resolved its own dir, e.g.
#     source "$SCRIPT_DIR/lib/cc-filter.sh"
#
# Scope note (deliberately narrow): the profile *filtering mechanics* are NOT
# unified here, because they genuinely differ by design —
#   • cc-mirror.sh filters a git INDEX/tree (git update-index --force-remove) and
#     FAILS LOUDLY on a stale exclude entry (it ships committed state publicly);
#   • cc-profile-filter.sh filters an installed FILESYSTEM cache (rm -rf) and
#     only WARNS on a missing path (it edits a live install in place).
# Merging those would erase intended behavior. The one thing they truly share —
# and previously parsed with two separate inline python one-liners at risk of
# drift — is reading the exclude[] array, centralized below as
# cc_profile_exclude_paths.

# Guard against direct execution — this file only makes sense sourced.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "cc-filter.sh is a sourced library; source it, don't execute it." >&2
  exit 1
fi

# ── Profile filtering ─────────────────────────────────────────────────────────

# Print each entry of a mirror-profile's "exclude" array, one per line.
# Reads the profile JSON from STDIN, so callers keep control of the source:
#   cc-profile-filter.sh reads the working-tree file:
#       cc_profile_exclude_paths < "$PROFILE_FILE"
#   cc-mirror.sh reads the committed blob (never the working tree):
#       git cat-file blob "HEAD:$PROFILE_FILE" | cc_profile_exclude_paths
cc_profile_exclude_paths() {
  python3 -c 'import json,sys; [print(p) for p in json.load(sys.stdin)["exclude"]]'
}

# ── Config-token substitution ─────────────────────────────────────────────────

# Emit the substitution map for a cc.config.json: lines of PLACEHOLDER<TAB>value.
# For every entry in the config's "placeholders" map this prints the bracketed
# [TOKEN] and, for filled values, the matching ${user_config.<lastKey>} form so
# clone installs bake both. Unfilled ("[...]") values print only the [TOKEN]
# line (the second is skipped so the unfilled warning doesn't double-fire).
cc_build_substitution_map() {
  local config="$1"
  python3 - "$config" <<'PYEOF'
import json, sys

with open(sys.argv[1]) as f:
    cfg = json.load(f)

def resolve(cfg, path):
    keys = path.split(".")
    val = cfg
    for k in keys:
        val = val[k]
    return val

placeholders = cfg.get("placeholders", {})
for placeholder, path in placeholders.items():
    try:
        value = resolve(cfg, path)
        print(f"{placeholder}\t{value}")
        # Skills/commands reference config as ${user_config.<key>} (the plugin
        # userConfig mechanism); bake those too for clone installs. Key = last
        # segment of the config path. Skip unfilled values here so the unfilled
        # warning below doesn't fire twice per entry.
        if not str(value).startswith("["):
            key = path.split(".")[-1]
            print(f"${{user_config.{key}}}\t{value}")
    except (KeyError, TypeError):
        pass
PYEOF
}

# Apply a substitution map to a string and print the result.
#   $1 = content to transform
#   $2 = substitution map (PLACEHOLDER<TAB>value lines, as from
#        cc_build_substitution_map)
# Unfilled ("[...]") values are skipped. Placeholders are escaped for use as a
# sed BRE pattern (brackets for [TOKEN]s, $ and . for ${user_config.key}
# references); braces stay UNESCAPED — in BRE, \{ opens a repetition interval, a
# bare { is the literal. Replacement values escape sed-special &, / and \.
cc_substitute_tokens() {
  local content="$1"
  local subs="$2"
  local placeholder value escaped_ph escaped_val
  while IFS=$'\t' read -r placeholder value; do
    # Skip unfilled values
    [[ "$value" == \[* ]] && continue
    escaped_ph=$(printf '%s' "$placeholder" | sed 's/[][$.^*\/]/\\&/g')
    escaped_val=$(printf '%s' "$value" | sed 's/[&/\]/\\&/g')
    content=$(printf '%s' "$content" | sed "s/$escaped_ph/$escaped_val/g")
  done <<< "$subs"
  printf '%s' "$content"
}
