# ============================================================================ #
# PATHS INDEX - Loads OS paths from lib/paths/ (by $OS_NAME, not $ZENV)
# ============================================================================ #

case "$OS_NAME" in
macOS) source "$ZSHRC_ROOT/lib/paths/paths.macos.zsh" ;;
Linux) source "$ZSHRC_ROOT/lib/paths/paths.linux.zsh" ;;
Android) source "$ZSHRC_ROOT/lib/paths/paths.android.zsh" ;;
*) source "$ZSHRC_ROOT/lib/paths/paths.linux.zsh" ;;
esac

# REMOVE DUPLICATES FROM PATH (legacy; build-path.mjs used at end of main.zsh)
function flatten-path() {
	export PATH=$(node "${ZSHRC_ROOT:-$HOME/.zshrc-config}/packages/node/dist/build-path.mjs")
}
