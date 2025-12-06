# SPECIFIC
export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/${ZENV}"
export NVM="true"

export ZSH_THEME="gallois"

# CORE
# source "$ZSHRC_ROOT/lib/paths.$OS_NAME_LOWER.zsh"
# source "$ZSHRC_ROOT/lib/colors.zsh"

# COMMON
# source "$ZSHRC_ROOT/lib/utils.zsh"
# source "$ZSHRC_ROOT/lib/utils.disk.zsh"
source "$ZSHRC_ROOT/lib/common.zsh"
source "$ZSHRC_ROOT/lib/dev.zsh"
source "$ZSHRC_ROOT/lib/git.zsh"
source "$ZSHRC_ROOT/lib/dev.jest.zsh"

source "$ZSHRC_ROOT/_zenvs/home-macos/home-macos.aliases.zsh"

# ========================================================================== #
# VSCODE START  ============================================================ #

# Basic environment
export ZENV='vscode'
export LANG="en_US.UTF-8"
export EDITOR="vim"

# Node.js settings
export NODE_OPTIONS="--max_old_space_size=4096"
export NVM_DIR="$HOME/.nvm"
[ -s "$HOME/nvm.sh" ] && source "$HOME/nvm.sh" # Load NVM

# Path management
typeset -U path
path=(
  "$HOME/bin"
  "/usr/local/bin"
  "/opt/homebrew/bin"
  "$HOME/.nvm/versions/node/$(node --version 2>/dev/null || echo 'v16')/bin"
  $path
)

# Basic aliases
alias ll='ls -la'
alias ..='cd ..'

# Minimal git configuration
# autoload -Uz compinit && compinit
autoload -Uz vcs_info
precmd() {
  vcs_info
}

zstyle ':vcs_info:git:*' formats '%b '

# Simple prompt with git branch
setopt PROMPT_SUBST
PROMPT='%F{green}%~%f %F{blue}${vcs_info_msg_0_}%f$ '
