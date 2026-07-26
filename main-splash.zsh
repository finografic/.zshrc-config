# ============================================================================ #
# FINAL INI + RESET MESSAGE
# ============================================================================ #

# NOTE: PATH deduplication is handled by `typeset -U path PATH` in bootstrap/index.zsh

# ============================================================================ #
# NOTE: SPLASH GATE
#
# The splash costs ~475 ms (measured): tmutil snapshot queries, launchctl
# lookups, an lsof port scan, a fetch tool, and `node`/`pnpm --version`.
#
#   ZSHRC_SPLASH=0     never show
#   anything else      show (DEFAULT)
#
# DEFAULT IS ON, for every interactive shell including nested ones. An earlier
# version of this gate defaulted to "outermost shell only" on the theory that a
# splash in the second and third nested shell is waste. That was wrong for this
# config: typing `zsh` in an existing terminal is a deliberate act, and the
# splash is the expected result of it. Opting out is the user's call, not the
# config's — so the cost is opt-out, not opt-in.
#
# The only unconditional skip is a non-interactive shell, where printing a
# banner would be actively wrong (it would corrupt piped/captured output).
# ============================================================================ #

function _zshrc-splash-wanted() {
  [[ -o interactive ]] || return 1

  case "${ZSHRC_SPLASH:-1}" in
  0 | false | no) return 1 ;;
  esac

  return 0
}

if ! _zshrc-splash-wanted; then
  unset -f _zshrc-splash-wanted
  return 0
fi
unset -f _zshrc-splash-wanted

# ============================================================================ #
# SPLASH SCREEN - CUSTOM WIDGETS
# ============================================================================ #

source "$ZSHRC_ROOT/lib/widgets.zsh"

show-tmutil-snapshots
show-custom-launch-agents
# show-docker-containers
show-ports

# SPLASH SCREEN BANNER + OS / SYS INFO..
show-splash-neofetch

show-splash-sys-banner
show-splash-sys-banner-footer-info

# VERSIONS: OS, NodeJS, npm... etc
show-os-version-and-sys-info
