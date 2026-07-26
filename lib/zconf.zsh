# ============================================================================ #
# NOTE: ZCONF - thin wrapper around the maintainer CLI (packages/zconf)
#
# `zconf` is a Node program and is therefore NOT on the startup path: it is a
# maintainer tool you invoke deliberately, never something a shell needs in
# order to start. This file only defines the wrapper (sourced, not executed);
# nothing here runs Node until you call `zconf`.
#
# Everything the shell itself depends on — environment detection, PATH
# building, zupdate — stays pure zsh and keeps working on a machine with no
# Node at all.
# ============================================================================ #

(( ${+_ZSHRC_ZCONF_LOADED} )) && return 0
typeset -g _ZSHRC_ZCONF_LOADED=1

source "$ZSHRC_ROOT/lib/colors.zsh"

function zconf() {
  local pkg="$ZSHRC_ROOT/packages/zconf"
  local built="$pkg/dist/index.js"

  if ! command -v node > /dev/null 2>&1; then
    print "${_r}zconf needs Node, which is not installed on this machine.${_0}" >&2
    print "${_grey}Everything the shell needs to start works without it.${_0}" >&2
    return 127
  fi

  # Prefer the build; fall back to running the source directly so the tool is
  # usable in a fresh checkout before anyone has run a build.
  if [[ -f "$built" ]]; then
    node "$built" "$@"
    return $?
  fi

  if [[ -d "$pkg" ]]; then
    print "${_y}zconf: no build found, running from source${_0}" >&2
    print "${_grey}build it once with: pnpm -C \"$pkg\" build${_0}" >&2
    (cd "$pkg" && pnpm exec tsx src/index.ts "$@")
    return $?
  fi

  print "${_r}zconf: packages/zconf not found under \$ZSHRC_ROOT${_0}" >&2
  return 1
}
