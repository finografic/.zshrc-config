#!/bin/zsh

# ============================================================================ #
# NOTE: CODEX - Minimal config for Codex agent shells (fast startup)
# ============================================================================ #

# Early exit from main.zsh - skips splash, widgets, hardware detection.
# Target: essential dev tools only, <200ms startup.
# ============================================================================ #

export ZENV='codex'
export ZSHRC_ROOT="$HOME/.zshrc-config"
export LANG="en_US.UTF-8"
export EDITOR="nvim"
export VISUAL="nvim"
export OS_NAME="${OS_NAME:-macOS}"
export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
export GRAPHIFY_PYTHON_PINNED="${GRAPHIFY_PYTHON_PINNED:-$HOME/.local/pipx/venvs/graphifyy/bin/python}"

# Node/Codex
export NODE_OPTIONS="$NODE_OPTIONS --max_old_space_size=4096"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Node helpers (.nvmrc autoload + pn / pnr / npmls)
source "$ZSHRC_ROOT/lib/node.zsh"

# PATH basics
if command -v node >/dev/null 2>&1; then
  PATH_NODE="${NPM_GLOBALS:-$HOME/.nvm/versions/node/$(node --version)/bin}"
else
  PATH_NODE=""
fi
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/opt/homebrew/bin:$PATH_NODE:$PNPM_HOME:$PATH"

# pnpm PATH / PNPM_HOME
source "$ZSHRC_ROOT/vendor/pnpm-path.zsh"

# Minimal aliases
alias ll='ls -la'
alias ..='cd ..'

# Keep Codex shells quiet and predictable.
export PROMPT='%~ %# '

