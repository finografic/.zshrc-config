#!/bin/zsh

# ============================================================================ #
# NOTE: VSCODE - Minimal config for IDE integrated terminals (fast startup)
# ============================================================================ #

# Early exit from main.zsh - skips splash, widgets, hardware detection.
# Target: essential dev tools only, <200ms startup.
# ============================================================================ #

export ZENV='vscode'
export ZSHRC_ROOT="$HOME/.zshrc-config"
export LANG="en_US.UTF-8"
export EDITOR="nvim"
export VISUAL="nvim"

# Colors (needed for prompts/aliases)
source "$ZSHRC_ROOT/lib/colors.zsh"

# Node/VSCode
export NODE_OPTIONS="$NODE_OPTIONS --max_old_space_size=4096"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# PATH basics
PATH_NODE="$HOME/.nvm/versions/node/$(node --version)/bin"
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH_NODE:$PATH"


# pnpm (use vendor config)
source "$ZSHRC_ROOT/vendor/pnpm.zsh"

# Core aliases
alias ll='ls -la'
alias ..='cd ..'

# VSCode command (macOS)
[[ "$OS_NAME" = "macOS" ]] && alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"

# Git - essential only
source "$ZSHRC_ROOT/lib/git.zsh"

# Common dev aliases
source "$ZSHRC_ROOT/lib/common.zsh"
source "$ZSHRC_ROOT/lib/dev.zsh"

# Simple prompt with git branch (p10k loads from bootstrap, but we use minimal for speed)
autoload -Uz vcs_info
function precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%b '
setopt PROMPT_SUBST
PROMPT='%F{green}%~%f %F{blue}${vcs_info_msg_0_}%f$ '
