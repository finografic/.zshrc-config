#!/bin/zsh
# ============================================================================ #
# NOTE: ANTIDOTE - Plugin manager installation and initialization
# ============================================================================ #

ANTIDOTE_HOME="${ZDOTDIR:-$HOME}/.antidote"

# Install antidote if not present (before instant prompt, may need interaction)
if [[ ! -d "$ANTIDOTE_HOME" ]]; then
  print -P "%F{cyan}Installing antidote...%f"
  git clone --depth=1 https://github.com/mattmc3/antidote.git "$ANTIDOTE_HOME"
fi

# Load antidote
source "$ANTIDOTE_HOME/antidote.zsh"
