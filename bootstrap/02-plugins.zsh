#!/bin/zsh
# ============================================================================ #
# NOTE: PLUGINS - Load zsh plugins via antidote (with caching)
# ============================================================================ #

# Skip antidote entirely in docker containers — docker-dev.zsh handles its own setup
if [[ -f /.dockerenv ]] || [[ -n "$IN_DOCKER" ]] || [[ -n "$DOCKER_CONTAINER" ]]; then
  return 0
fi

PLUGIN_LIST="$ZSHRC_ROOT/plugins/.zsh_plugins.txt"
PLUGIN_CACHE="$ZSHRC_ROOT/plugins/.zsh_plugins.zsh"
# Store generated file outside the mounted/shared volume so each host generates
# its own copy with its own $HOME paths (Mac vs container)
PLUGIN_GENERATED="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zsh_plugins.generated.zsh"
mkdir -p "${PLUGIN_GENERATED:h}"

# Use .txt file if it exists, otherwise fall back to .zsh (legacy)
if [[ ! -f "$PLUGIN_LIST" ]]; then
  PLUGIN_LIST="$ZSHRC_ROOT/plugins/.zsh_plugins.zsh"
fi

# Regenerate plugin bundle only if source changed, cache missing, or cache is empty
if [[ ! -s "$PLUGIN_GENERATED" || "$PLUGIN_LIST" -nt "$PLUGIN_GENERATED" ]]; then
  # Silent regeneration (no output before p10k instant prompt completes)
  antidote bundle < "$PLUGIN_LIST" > "$PLUGIN_GENERATED"
fi

# Source the generated plugin file
source "$PLUGIN_GENERATED"
