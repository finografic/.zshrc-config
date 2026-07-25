#!/bin/zsh
# Exercises every branch of determine-environment in isolation.
# Resolve the repo root from this script's own location, so the test runs
# anywhere (CI checkout, a clone under a different name, a worktree).
export ZSHRC_ROOT="${ZSHRC_ROOT:-${0:A:h:h}}"

typeset -i pass=0 fail=0

function check() {
  local desc="$1" expected="$2" got="$3"
  if [[ "$got" == "$expected" ]]; then
    print "  ok    $desc -> $got"
    (( pass++ ))
  else
    print "  FAIL  $desc -> got '$got', expected '$expected'"
    (( fail++ ))
  fi
}

# Each case runs in its own `zsh -f` with every relevant var cleared first, so
# neither the ambient shell nor a previous case can leak in.
function resolve() {
  zsh -f -c "
    unset ZENV ZENV_FORCE ZENV_RESOLVED_BY IS_CODEX CODEX_CI CODEX_THREAD_ID
    unset __CFBundleIdentifier TERM_PROGRAM IN_DOCKER DOCKER_CONTAINER IS_DOCKER
    unset IS_HOME IS_OFFICE IS_SERVER OS_NAME
    export ZSHRC_ROOT='$ZSHRC_ROOT'
    $1
    source '$ZSHRC_ROOT/core/detect.zsh'
    determine-environment
    print \"\${ZENV}:\${ZENV_RESOLVED_BY}\"
  "
}

print "determine-environment precedence:"
check "ZENV_FORCE override"  "server-linux:forced"   "$(resolve 'export ZENV_FORCE=server-linux')"
check "codex via IS_CODEX"   "codex:agent"           "$(resolve 'export IS_CODEX=true')"
check "codex via THREAD_ID"  "codex:agent"           "$(resolve 'export CODEX_THREAD_ID=abc')"
check "codex via bundle id"  "codex:agent"           "$(resolve 'export __CFBundleIdentifier=com.openai.codex')"
check "vscode terminal"      "vscode:ide"            "$(resolve 'export TERM_PROGRAM=vscode')"
check "container IN_DOCKER"  "docker-dev:container"  "$(resolve 'export IN_DOCKER=1')"
check "container IS_DOCKER"  "docker-dev:container"  "$(resolve 'export IS_DOCKER=true')"
check "flag IS_HOME"         "home-macos:flags"      "$(resolve 'export IS_HOME=true OS_NAME=macOS')"
check "flag IS_OFFICE"       "office-macos:flags"    "$(resolve 'export IS_OFFICE=true OS_NAME=macOS')"
check "flag IS_SERVER"       "server-linux:flags"    "$(resolve 'export IS_SERVER=true OS_NAME=Linux')"
check "fallback macOS"       "home-macos:fallback"   "$(resolve 'export OS_NAME=macOS')"
check "fallback Linux"       "home-linux:fallback"   "$(resolve 'export OS_NAME=Linux')"
check "fallback Android"     "android:fallback"      "$(resolve 'export OS_NAME=Android')"
check "fallback unknown OS"  "home-linux:fallback"   "$(resolve 'export OS_NAME=Plan9')"

print "\nprecedence ordering:"
check "agent > flags"      "codex:agent"          "$(resolve 'export IS_CODEX=true IS_HOME=true')"
check "ide > flags"        "vscode:ide"           "$(resolve 'export TERM_PROGRAM=vscode IS_HOME=true')"
check "container > flags"  "docker-dev:container" "$(resolve 'export IN_DOCKER=1 IS_HOME=true')"
check "force > agent"      "custom:forced"        "$(resolve 'export ZENV_FORCE=custom IS_CODEX=true')"
check "home flag > office" "home-macos:flags"     "$(resolve 'export IS_HOME=true IS_OFFICE=true OS_NAME=macOS')"

print "\nregressions this fixes:"
check "IS_OFFICE reaches office (was shadowed)" "office-macos:flags" "$(resolve 'export IS_OFFICE=true OS_NAME=macOS')"
check "inherited ZENV does NOT pin a nested shell" "vscode:ide" "$(resolve 'export ZENV=home-macos TERM_PROGRAM=vscode')"

print "\nunset flags must not error:"
out="$(zsh -f -c "
  unset ZENV ZENV_FORCE IS_HOME IS_OFFICE IS_SERVER OS_NAME TERM_PROGRAM
  export ZSHRC_ROOT='$ZSHRC_ROOT'
  source '$ZSHRC_ROOT/core/detect.zsh'
  determine-environment
" 2>&1)"
if [[ -z "$out" ]]; then
  print "  ok    silent with nothing set"
  (( pass++ ))
else
  print "  FAIL  produced: $out"
  (( fail++ ))
fi

print "\n$pass passed, $fail failed"
(( fail == 0 ))
