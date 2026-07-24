source "$ZSHRC_ROOT/lib/cli/cli.listing.zsh"
source "$ZSHRC_ROOT/lib/cli/cli.navigation.zsh"

# ============================================================================ #
# UNIVERSAL ALIASES
# ============================================================================ #

alias dls="cd $HOME/Downloads && l"
alias www="cd /var/www && l"

# ============================================================================ #
# NEW (2024-05)
# ============================================================================ #

# TODO: WHAT HAPPENED TO `batcat` ??
# alias bat="batcat"

# ============================================================================ #
# FUNCTIONS + ALIASES
# ============================================================================ #

alias cdz="cd ${ZSHRC_ROOT} && l"
alias os="cd ${HOME}/os-setup && l"

# LIST SYSTEM PATHS
alias path="tr ':' '\n' <<< '$PATH'"
