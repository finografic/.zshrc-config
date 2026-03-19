#!/bin/zsh
# ============================================================================ #
# NOTE: PLUGINS - Load zsh plugins via antidote (with caching)
# ============================================================================ #

PLUGIN_LIST="$ZSHRC_ROOT/plugins/.zsh_plugins.txt"
PLUGIN_CACHE="$ZSHRC_ROOT/plugins/.zsh_plugins.zsh"
PLUGIN_GENERATED="$ZSHRC_ROOT/plugins/.zsh_plugins.generated.zsh"

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
