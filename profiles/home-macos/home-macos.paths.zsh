# SYSTEM
# export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# ============================================================================ #
# NOTE: bun
# ============================================================================ #

# bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ============================================================================ #
# NOTE: development
# ============================================================================ #

export PATH="$(brew --prefix llvm@18)/bin:$PATH"

REPOS="$HOME/repos"
