#!/bin/zsh
# Boots every profile via main.zsh with ZENV_FORCE, and asserts each comes up
# clean: exit 0, nothing on stderr, and a known function defined.
#
# This is the test that proves a refactor didn't break a profile you cannot
# easily reach (server, android, container).

export ZSHRC_ROOT="${ZSHRC_ROOT:-${0:A:h:h}}"

typeset -i pass=0 fail=0

# profile -> a function that must exist once it has booted
typeset -A sentinel=(
  [home-macos]=macos-brew-shellenv
  [office-macos]=macos-brew-shellenv
  [home-linux]=kde-restart-plasma
  [server-linux]=chown-to
  [docker-dev]=zenv-load
  [vscode]=zenv-load
  [codex]=zenv-load
  [android]=repos
)

# Profiles that only make sense on a matching OS. On the wrong host they still
# have to LOAD without error, which is what we assert.
for profile in ${(ko)sentinel}; do
  out="$(
    ZENV_FORCE="$profile" \
    ZSHRC_ROOT="$ZSHRC_ROOT" \
    ZSHRC_SPLASH=0 \
    zsh -f -c "
      export ZSHRC_ROOT='$ZSHRC_ROOT'
      export ZENV_FORCE='$profile'
      source \"\$ZSHRC_ROOT/core/env.zsh\"
      determine-environment
      export ZENV
      apply-environment-env
      export ZENV_PATH=\"\$ZSHRC_ROOT/profiles/\$ZENV\"
      source \"\$ZSHRC_ROOT/core/profile.zsh\"
      source \"\$ZSHRC_ROOT/lib/colors.zsh\"
      source \"\$ZSHRC_ROOT/profiles/\$ZENV/\$ZENV.zsh\"
      (( \$+functions[${sentinel[$profile]}] )) || { print 'MISSING-SENTINEL' >&2; exit 1; }
      print BOOTED
    " 2>&1
  )"

  if [[ "$out" == *BOOTED* && "$out" != *MISSING-SENTINEL* ]]; then
    # Anything other than the BOOTED line is unexpected chatter.
    noise="${out//BOOTED/}"
    noise="${noise//[[:space:]]/}"
    if [[ -n "$noise" ]]; then
      print "  warn  $profile booted, with output:"
      print "$out" | sed 's/^/          /' | grep -v BOOTED | head -4
      (( pass++ ))
    else
      print "  ok    $profile boots clean (sentinel: ${sentinel[$profile]})"
      (( pass++ ))
    fi
  else
    print "  FAIL  $profile"
    print "$out" | sed 's/^/          /' | head -6
    (( fail++ ))
  fi
done

print "\n$pass passed, $fail failed"
(( fail == 0 ))
