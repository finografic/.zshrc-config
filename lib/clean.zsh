# ============================================================================ #
# NOTE: CLEAN - Barrel for lib/clean/ modules (source-only; call functions to run)
# ============================================================================ #

# Modules (define functions only)
source "$ZSHRC_ROOT/lib/clean/clean.downloads.zsh"
source "$ZSHRC_ROOT/lib/clean/clean.browsers.zsh"
source "$ZSHRC_ROOT/lib/clean/clean.ides.zsh"
source "$ZSHRC_ROOT/lib/clean/clean.node.zsh"

# Aliases
alias vsclean="clean-ides"
alias _cnm="clean-node-modules-report"
alias _cnpm="clean-caches-npm"
alias _cpnpm="clean-caches-pnpm"

# ============================================================================ #
# NOTE: AUTO-RUN on shell start
# ============================================================================ #

clean-downloads
clean-browsers
clean-caches-npm
# clean-caches-pnpm
