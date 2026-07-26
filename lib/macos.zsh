# ============================================================================ #
# MACOS UTILITIES INDEX - Loads all macos modules from lib/macos/
# ============================================================================ #

(( ${+_ZSHRC_MACOS_LOADED} )) && return 0
typeset -g _ZSHRC_MACOS_LOADED=1

source "$ZSHRC_ROOT/lib/macos/macos.brew.zsh"
source "$ZSHRC_ROOT/lib/macos/macos.dock.zsh"
source "$ZSHRC_ROOT/lib/macos/macos.time-machine.zsh"
source "$ZSHRC_ROOT/lib/macos/macos.media.zsh"

