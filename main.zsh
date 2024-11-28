#!/bin/zsh

export ZSH_DISABLE_COMPFIX="true"
export ZSHRC_ROOT=$HOME/.zshrc-config

# ZINIT - FASTEST PLUGIN MANAGER ===================================================== #

# ref: https://github.com/zdharma-continuum/zinit
# source "$ZSHRC_ROOT/_zinit.zsh"

# DETERMINE OS + IP and DETERMINE ENVIRONMENT ================================ #

echo "\n${_grey} config + env --------------------------------- ${_0}"

source "$HOME/.zshrc-config/.env"
source "$ZSHRC_ROOT/_get-env.zsh"

# MAIN ZSH =================================================================== #

echo "\n${_grey} config --------------------------------- ${_0}"

source "$ZSHRC_ROOT/_zsh-config.zsh"
source "$ZSHRC_ROOT/lib/k.plugin.sh" # LOAD 'k' LOCALLY 😁

# SET NODE VERSION =========================================================== #

echo "\n${_grey} nvm --------------------------------- ${_0}"

source "$ZSHRC_ROOT/lib/nvm.zsh"

# SET NODE VERSION =========================================================== #

# NOTE: this file could be ROOT to import all other COMMON vendor configs from /vendor/.. folder
# fzf, nvm, pmpm, etc.

echo "\n${_grey} vendor --------------------------------- ${_0}"

source "$ZSHRC_ROOT/_vendor.zsh"

# INIT FZF (moved from _fin.zsh) ============================================= #

echo "\n${_grey} fzf --------------------------------- ${_0}"

source "$ZSHRC_ROOT/lib/fzf.zsh"
source "$ZSHRC_ROOT/lib/fzf.custom.zsh"

# ============================================================================ #

# LOCALE (DEFAULT, MAY BE OVERWRITTEN BY ENV)
export LC_ALL=C
export LANGUAGE=en_US.UTF-8

# ============================================================================ #

# LOCALE (DEFAULT, MAY BE OVERWRITTEN BY ENV)
export EDITOR="vim"
# export IDE="code-insiders"
export IDE="code"
edit() { "$EDITOR $@"; }
# code() { "$IDE $@"; }
alias code="/Applications/Visual\ Studio\ Code.app/Contents/MacOS/Electron"
alias code-insiders="/Applications/Visual\ Studio\ Code\ -\ Insiders.app/Contents/MacOS/Electron"

# ============================================================================ #
# TERMINAL INSIDE VSCode ?? ================================================== #
# ============================================================================ #

echo "\n${_grey} vscode -or- terminal --------------------------------- ${_0}"

# NOTE: MIN INIT (terminal in VSCode)

if [ $TERM_PROGRAM = 'vscode' ]; then
  export ZENV='vscode'
  source "$ZSHRC_ROOT/_zenvs/$ZENV/$ZENV.zsh"
  export PATH=$HOME/.nvm/versions/node/$(node --version)/bin:$PATH
  export PATH=/usr/local/bin:$PATH
  export PATH=$HOME/bin:$PATH
else

  # ========================================================================== #
  #  DEFAULT SETUP (not in VSCode) =========================================== #
  # ========================================================================== #

  # NOTE: DEFAULT INIT (not in VSCode)

  # START/RESTART: CLEAR CLI + SPINNER
  clear
  echo "\n"
  node "$ZSHRC_ROOT/lib/spinner.js"

  # CORE
  source "$ZSHRC_ROOT/lib/colors.zsh"
  # source "$ZSHRC_ROOT/lib/paths.$OS_NAME_LOWER.zsh"
  export PATH=$HOME/.nvm/versions/node/$(node --version)/bin:$PATH
  export PATH=/usr/local/bin:$PATH
  export PATH=$HOME/bin:$PATH

  # COMMON
  source "$ZSHRC_ROOT/lib/utils.zsh"
  source "$ZSHRC_ROOT/lib/utils.disk.zsh"
  source "$ZSHRC_ROOT/lib/common.zsh"
  source "$ZSHRC_ROOT/lib/dev.zsh"

  source "$ZSHRC_ROOT/_zenvs/$ZENV/$ZENV.zsh"

  # FINALIZATION OUTPUT
  source "$ZSHRC_ROOT/_fin.zsh"
fi

# REMOVE DUPLICATES FROM PATH ================================================ #

flatten_PATH
