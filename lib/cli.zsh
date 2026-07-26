# ============================================================================ #
# CLI UTILITIES INDEX - Loads all cli modules from lib/cli/
# ============================================================================ #

(( ${+_ZSHRC_CLI_LOADED} )) && return 0
typeset -g _ZSHRC_CLI_LOADED=1

source "$ZSHRC_ROOT/lib/cli/cli.listing.zsh"
source "$ZSHRC_ROOT/lib/cli/cli.navigation.zsh"
