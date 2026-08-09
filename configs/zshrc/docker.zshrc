# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH


export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="devcontainers"

plugins=(git)

source $ZSH/oh-my-zsh.sh
zstyle ':omz:update' mode disabled
source ~/.env-vars


# ============================================================================ #
# NOTE: 0. CORE PATHS
# ============================================================================ #

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:/opt/homebrew/bin:$PATH"

# ============================================================================ #
# NOTE: 1. P10K INSTANT PROMPT (must be early, before other console output)
# ============================================================================ #

# Disable instant prompt so the prompt appears only at the END after full
# bootstrap/splash output. Instant prompt causes a premature prompt to appear
# while bootstrapping continues in the background.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================ #
# NOTE: 2. ZSHRC-CONFIG BOOTSTRAP
# ============================================================================ #

export ZSHRC_ROOT="$HOME/.zshrc-config"
source "$ZSHRC_ROOT/bootstrap/index.zsh"

# ============================================================================ #
# NOTE: 3. MAIN CONFIG
# ============================================================================ #

source "$ZSHRC_ROOT/main.zsh"

