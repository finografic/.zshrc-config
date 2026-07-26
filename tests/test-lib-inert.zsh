#!/bin/zsh
# Exit criteria for P1.2: sourcing any lib/**.zsh must be inert.
# Each module is sourced in a fresh `zsh -f`; any stdout/stderr is a failure.
#
# Also covers the opt-in extras and scripts that ship a CLI dispatcher: those
# must be inert when SOURCED (however deeply, and whatever the caller's
# positional parameters are) and must still dispatch when EXECUTED.

# Resolve the repo root from this script's own location unless one is passed in.
export ZSHRC_ROOT="${1:-${0:A:h:h}}"
cd "$ZSHRC_ROOT" || exit 1

typeset -i failures=0

for f in lib/**/*.zsh(N); do
  out="$(zsh -f -c "export ZSHRC_ROOT='$ZSHRC_ROOT'; source '$ZSHRC_ROOT/$f'" 2>&1)"
  if [[ -n "$out" ]]; then
    print "FAIL $f"
    print "$out" | sed 's/^/     | /' | head -5
    (( failures++ ))
  fi
done

# ---------------------------------------------------------------------------
# Files with a "run only when executed directly" CLI block.
#
# Regression guard for a real bug: the guards used to be
# `[[ $ZSH_EVAL_CONTEXT == "toplevel"* ]]` (matches ALWAYS — it is a
# colon-separated stack that always begins with "toplevel") and
# `[[ ${BASH_SOURCE[0]} == $0 ]]` (BASH_SOURCE does not exist in zsh, so always
# false). djay_icloud_sync.zsh would therefore dispatch while being sourced,
# defaulting to "sync" — starting a real iCloud sync at shell startup.
# ---------------------------------------------------------------------------
typeset -a cli_files=(
  extras/music/djay_icloud_sync.zsh
  scripts/docker-cleanup.zsh
)

# The harness MUST drive this from a real script file, not `zsh -c`. The two
# produce different eval contexts — `zsh script.zsh` gives "toplevel...", while
# `zsh -c` gives "cmdarg..." — and the historical broken guard only misfired
# under the former. A `zsh -c` harness silently passes even with the bug present.
harness="${TMPDIR:-/tmp}/zenv-cli-guard-$$.zsh"

for f in $cli_files; do
  [[ -r "$ZSHRC_ROOT/$f" ]] || continue

  # Sourced from inside a function that still holds positional parameters —
  # the exact shape core/profile.zsh's loaders use.
  cat > "$harness" <<EOF
export ZSHRC_ROOT='$ZSHRC_ROOT'
source '$ZSHRC_ROOT/lib/colors.zsh'
function loader() { source '$ZSHRC_ROOT/$f'; }
loader 'music/a music/b'
EOF
  out="$(zsh -f "$harness" 2>&1)"
  if [[ -n "$out" ]]; then
    print "FAIL $f — dispatched while being sourced"
    print "$out" | sed 's/^/     | /' | head -5
    (( failures++ ))
  fi

  # ...but executing it must still reach the CLI.
  out="$(zsh "$ZSHRC_ROOT/$f" help 2>&1)"
  if [[ -z "$out" ]]; then
    print "FAIL $f — executed directly but produced nothing (dead CLI guard)"
    (( failures++ ))
  fi
done
rm -f "$harness"

# ---------------------------------------------------------------------------
# lib/colors.zsh must not export its vars into child processes.
#
# Regression guard for a real bug: `typeset -g` on a name that is ALREADY
# exported does not strip the export flag, only updates the value. Every one
# of these vars WAS `export`ed by this file until this fix, so any ancestor
# shell still running old config (a tmux server, a login shell predating an
# update) has already exported them — and a plain `zsh -f` test cannot
# reproduce that, because it starts with a clean environment. This harness
# simulates the contaminated-ancestor case explicitly: export the vars the
# old way FIRST, then source the current file, then check a child process.
# ---------------------------------------------------------------------------
color_harness="${TMPDIR:-/tmp}/zenv-color-export-$$.zsh"
cat > "$color_harness" <<EOF
export ZSHRC_ROOT='$ZSHRC_ROOT'
export _c="old" _r="old" _g="old" _y="old" _0="old"
source "\$ZSHRC_ROOT/lib/colors.zsh"
env | grep -E '^_(c|r|g|y|0)='
EOF
out="$(zsh -f "$color_harness" 2>&1)"
if [[ -n "$out" ]]; then
  print "FAIL lib/colors.zsh — vars still exported after sourcing, even with a clean env:"
  print "$out" | sed 's/^/     | /'
  (( failures++ ))
fi
rm -f "$color_harness"

print ""
if (( failures == 0 )); then
  print "PASS — lib/ modules source inertly; CLI guards correct"
else
  print "$failures failure(s)"
fi
