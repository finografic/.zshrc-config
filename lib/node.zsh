# ============================================================================ #
# NOTE: NODE - Barrel for lib/node/ helpers (non-cleaning)
# Requires nvm.sh already loaded for nvm-autoload (no-ops if nvm missing).
# ============================================================================ #

(( ${+_ZSHRC_NODE_LOADED} )) && return 0
typeset -g _ZSHRC_NODE_LOADED=1

source "$ZSHRC_ROOT/lib/node/nvm-autoload.zsh"
source "$ZSHRC_ROOT/lib/node/pnpm.zsh"
source "$ZSHRC_ROOT/lib/node/node.globals.zsh"
