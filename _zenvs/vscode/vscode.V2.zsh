# Minimal VSCode Terminal Configuration

# Basic environment
export ZENV='vscode'
export LANG="en_US.UTF-8"
export EDITOR="vim"

# Node.js settings
export NODE_OPTIONS="--max_old_space_size=4096"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" # Load NVM

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
