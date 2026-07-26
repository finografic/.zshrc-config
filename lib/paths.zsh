# ============================================================================ #
# PATHS INDEX - Loads OS paths from lib/paths/ (by $OS_NAME, not $ZENV)
# ============================================================================ #

(( ${+_ZSHRC_PATHS_LOADED} )) && return 0
typeset -g _ZSHRC_PATHS_LOADED=1

case "$OS_NAME" in
macOS) source "$ZSHRC_ROOT/lib/paths/paths.macos.zsh" ;;
Linux) source "$ZSHRC_ROOT/lib/paths/paths.linux.zsh" ;;
Android) source "$ZSHRC_ROOT/lib/paths/paths.android.zsh" ;;
*) source "$ZSHRC_ROOT/lib/paths/paths.linux.zsh" ;;
esac

# PATH de-duplication is handled by `typeset -U path PATH` in bootstrap/index.zsh.
