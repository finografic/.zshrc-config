#!/bin/zsh
# Exit criteria for P1.2: sourcing any lib/**.zsh must be inert.
# Each module is sourced in a fresh `zsh -f`; any stdout/stderr is a failure.

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

print ""
if (( failures == 0 )); then
  print "PASS — all lib/ modules source inertly"
else
  print "$failures module(s) produced output"
fi
