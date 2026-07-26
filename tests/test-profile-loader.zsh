#!/bin/zsh
# Exercises core/profile.zsh: manifest resolution, canonical ordering, the nvm
# load-order invariant, and validation failures.

export ZSHRC_ROOT="${ZSHRC_ROOT:-${0:A:h:h}}"

typeset -i pass=0 fail=0

function check() {
  local desc="$1" expected="$2" got="$3"
  if [[ "$got" == "$expected" ]]; then
    print "  ok    $desc"
    (( pass++ ))
  else
    print "  FAIL  $desc"
    print "        expected: $expected"
    print "        got:      $got"
    (( fail++ ))
  fi
}

function check-contains() {
  local desc="$1" needle="$2" haystack="$3"
  if [[ "$haystack" == *"$needle"* ]]; then
    print "  ok    $desc"
    (( pass++ ))
  else
    print "  FAIL  $desc"
    print "        expected to contain: $needle"
    print "        got:                 $haystack"
    (( fail++ ))
  fi
}

# Runs a snippet in a bare zsh with core/profile.zsh loaded. `source` is stubbed
# to record what would be loaded instead of actually loading it, so we can test
# resolution order without booting a real shell.
function trace-load() {
  zsh -f -c "
    unset NVM ZENV_PRESET ZENV_MODULES ZENV_FEATURES ZENV_OPT_IN
    export ZSHRC_ROOT='$ZSHRC_ROOT'
    export ZENV='${2:-testenv}'
    export ZENV_PATH=\"\$ZSHRC_ROOT/_zenvs/\$ZENV\"
    source '$ZSHRC_ROOT/core/profile.zsh'

    # Stub: record instead of load. Keeps the real file-existence checks in
    # zenv-validate honest, since those use [[ -r ]], not source.
    function source() { print -- \"\${1##\$ZSHRC_ROOT/}\"; }

    $1
  " 2>&1
}

print "canonical ordering (declaration order must NOT matter):"
# Declare deliberately backwards; expect canonical order out.
out="$(trace-load '
  ZENV_PRESET=none
  ZENV_MODULES=(widgets git colors dev)
  ZENV_FEATURES=()
  zenv-modules "widgets git colors dev"
')"
check "reversed declaration resolves in canonical order" \
  "lib/colors.zsh
lib/git.zsh
lib/dev.zsh
lib/widgets.zsh" "$out"

print "\nnvm load-order invariant:"
out="$(trace-load '
  NVM=true
  zenv-modules "node"
')"
check "NVM=true sources pnpm-path, then nvm, then lib/node.zsh" \
  "vendor/pnpm-path.zsh
vendor/nvm.zsh
lib/node.zsh" "$out"

out="$(trace-load '
  NVM=false
  zenv-modules "node"
')"
check "NVM=false skips vendor/nvm.zsh but keeps pnpm-path" \
  "vendor/pnpm-path.zsh
lib/node.zsh" "$out"

out="$(trace-load '
  NVM=true
  zenv-modules "node git colors"
')"
check-contains "nvm still precedes lib/node.zsh when other modules present" \
  "vendor/nvm.zsh
lib/node.zsh" "$out"

print "\npresets:"
out="$(trace-load 'zenv-modules "${ZENV_PRESET_MODULES[minimal]}"')"
check "minimal = colors, git, node, dev" \
  "lib/colors.zsh
lib/git.zsh
vendor/pnpm-path.zsh
lib/node.zsh
lib/dev.zsh" "$out"

out="$(trace-load 'zenv-modules "${ZENV_PRESET_MODULES[container]}"')"
check-contains "container includes utils" "lib/utils.zsh" "$out"
out="$(trace-load 'print -- "${ZENV_PRESET_MODULES[container]}"')"
check "container has no macOS module" "1" \
  "$([[ "$out" != *macos* ]] && print 1 || print 0)"

out="$(trace-load 'print -- "${ZENV_PRESET_MODULES[full]}"')"
check-contains "full includes clean" "clean" "$out"
check "full excludes widgets (main-splash.zsh owns it)" "1" \
  "$([[ "$out" != *widgets* ]] && print 1 || print 0)"
check "full excludes ghostty (macOS-specific path)" "1" \
  "$([[ "$out" != *ghostty* ]] && print 1 || print 0)"

print "\npositional-parameter isolation (real sourcing, no source stub):"
# `source file` does NOT clear $@ — a sourced file inherits the caller's
# positional parameters. Since every loader function takes its work list as
# "$1", a naive `source "$path"` hands each sourced file a $1 of e.g.
# "music/backup-dj-crate music/djay_icloud_sync". Any extra with a CLI
# dispatcher at the bottom (extras/music/djay_icloud_sync.zsh has exactly that)
# then acts on garbage. These cases source a REAL probe file, so the source
# stub used above cannot hide the problem.
probe_dir="${TMPDIR:-/tmp}/zenv-argtest-$$"
mkdir -p "$probe_dir/extras/probe" "$probe_dir/_zenvs/argtest"
print 'print "argc=$# argv=[$*]"' > "$probe_dir/extras/probe/target.zsh"
print 'print "argc=$# argv=[$*]"' > "$probe_dir/_zenvs/argtest/argtest.feature.zsh"

out="$(zsh -f -c "
  export ZSHRC_ROOT='$probe_dir'
  export ZENV=argtest
  export ZENV_PATH=\"\$ZSHRC_ROOT/_zenvs/\$ZENV\"
  source '$ZSHRC_ROOT/core/profile.zsh'
  zenv-opt-in 'probe/target'
" 2>&1)"
check "opt-in sees empty \$@, not the opt-in list" "argc=0 argv=[]" "$out"

out="$(zsh -f -c "
  export ZSHRC_ROOT='$probe_dir'
  export ZENV=argtest
  export ZENV_PATH=\"\$ZSHRC_ROOT/_zenvs/\$ZENV\"
  source '$ZSHRC_ROOT/core/profile.zsh'
  zenv-features 'feature'
" 2>&1)"
check "feature sees empty \$@, not the feature list" "argc=0 argv=[]" "$out"
rm -rf "$probe_dir"

print "\nvalidation:"
out="$(trace-load 'zenv-validate "git nosuchmodule" "" && print OK || print FAILED')"
check-contains "unknown module is an error, not a silent skip" "unknown module 'nosuchmodule'" "$out"
check-contains "unknown module returns non-zero" "FAILED" "$out"

out="$(trace-load 'zenv-validate "git" "" && print OK || print FAILED')"
check-contains "known module validates" "OK" "$out"

out="$(trace-load '
  ZENV_PRESET=nosuchpreset
  ZENV_MODULES=()
  ZENV_FEATURES=()
  zenv-load && print OK || print FAILED
')"
check-contains "unknown preset is an error" "unknown preset 'nosuchpreset'" "$out"

out="$(trace-load 'zenv-validate "" "nosuchfeature" && print OK || print FAILED' home-macos)"
check-contains "missing feature file is an error" "missing file" "$out"

print "\nreal profile manifests must validate:"

# Extracts just the manifest assignments from a profile and validates them,
# without executing the rest of the profile body.
cat > "$TMPDIR/zenv-validate-profile.zsh" <<'VALIDATOR'
export ZENV="$1"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/$ZENV"
source "$ZSHRC_ROOT/core/profile.zsh"
eval "$(grep -E '^(ZENV_PRESET|ZENV_MODULES|ZENV_FEATURES|ZENV_OPT_IN)=' "$ZENV_PATH/$ZENV.zsh")"
typeset -a mods
mods=(${=ZENV_PRESET_MODULES[${ZENV_PRESET:-none}]} ${ZENV_MODULES[@]})
zenv-validate "${mods[*]}" "${ZENV_FEATURES[*]}" && print OK
VALIDATOR

for profile in home-macos office-macos home-linux server-linux docker-dev vscode codex android; do
  out="$(ZSHRC_ROOT="$ZSHRC_ROOT" zsh -f "$TMPDIR/zenv-validate-profile.zsh" "$profile" 2>&1)"
  check-contains "$profile manifest validates" "OK" "$out"
done
rm -f "$TMPDIR/zenv-validate-profile.zsh"

print "\n$pass passed, $fail failed"
(( fail == 0 ))
