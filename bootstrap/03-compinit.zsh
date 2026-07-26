# ============================================================================ #
# NOTE: COMPINIT - Completion system initialization (with caching)
# ============================================================================ #

# Initialize completion system with caching for speed
autoload -Uz compinit

# Cache compinit for 24 hours
COMPINIT_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
COMPINIT_CACHE_DIR="${COMPINIT_CACHE:h}"

# Ensure cache directory exists
[[ -d "$COMPINIT_CACHE_DIR" ]] || mkdir -p "$COMPINIT_CACHE_DIR"

# Only regenerate once per day
if [[ -f "$COMPINIT_CACHE" && $(date +'%j') == $(date -r "$COMPINIT_CACHE" +'%j' 2>/dev/null) ]]; then
  compinit -C -d "$COMPINIT_CACHE"
else
  compinit -d "$COMPINIT_CACHE"
fi
