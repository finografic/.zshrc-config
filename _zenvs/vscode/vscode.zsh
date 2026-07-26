# ============================================================================ #
# NOTE: VSCODE - Minimal config for IDE integrated terminals (fast startup)
#
# Early exit from main.zsh — skips splash, widgets, hardware detection.
# Target: essential dev tools only, <200ms startup.
# ============================================================================ #

export ZENV='vscode'
export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/$ZENV"
export LANG="en_US.UTF-8"
export EDITOR="nvim"
export VISUAL="nvim"
export NODE_OPTIONS="$NODE_OPTIONS --max_old_space_size=4096"

# nvm + pnpm + lib/node.zsh + .nvmrc autoload are all handled by the `node`
# module in the manifest below — this used to be hand-rolled here.
export NVM="true"

# ============================================================================ #
# NOTE: MANIFEST
# ============================================================================ #

ZENV_PRESET=minimal
ZENV_MODULES=()
ZENV_FEATURES=(dev)

zenv-load

# ============================================================================ #
# NOTE: PROFILE-SPECIFIC
# ============================================================================ #

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

alias ll='ls -la'
alias ..='cd ..'

[[ "$OS_NAME" = "macOS" ]] && alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"

# Simple prompt with git branch — p10k is skipped here for speed.
autoload -Uz vcs_info
function precmd() { vcs_info; }
zstyle ':vcs_info:git:*' formats '%b '
setopt PROMPT_SUBST
PROMPT='%F{green}%~%f %F{blue}${vcs_info_msg_0_}%f$ '
