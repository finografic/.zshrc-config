# ============================================================================ #
# FINAL INI + RESET MESSAGE
# ============================================================================ #

# NOTE: PATH deduplication is handled by `typeset -U path PATH` in bootstrap/index.zsh

# ============================================================================ #
# NOTE: SPLASH GATE
#
# The splash costs ~475 ms (measured): tmutil snapshot queries, launchctl
# lookups, an lsof port scan, a fetch tool, and `node`/`pnpm --version`. That is
# worth it once, when you open a terminal. It is pure waste in the second,
# third and fourth nested shell of the same session, and in any script that
# happens to start an interactive shell.
#
#   ZSHRC_SPLASH=1     always show
#   ZSHRC_SPLASH=0     never show
#   unset (default)    show only for the OUTERMOST interactive shell
#
# The default deliberately keys on `-o login` first: a terminal emulator
# (Ghostty, Terminal.app, iTerm) starts a login shell, so a real terminal
# window always gets its splash no matter how deep $SHLVL happens to be.
# ============================================================================ #

function _zshrc-splash-wanted() {
  case "${ZSHRC_SPLASH:-auto}" in
  0 | false | no) return 1 ;;
  1 | true | yes) return 0 ;;
  esac

  # auto: interactive only, and only the outermost shell.
  [[ -o interactive ]] || return 1
  [[ -o login ]] && return 0
  (( SHLVL <= 1 ))
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
