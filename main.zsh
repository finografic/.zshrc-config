#!/bin/zsh

export ZSH_DISABLE_COMPFIX="true"
export ZSHRC_ROOT=$HOME/.zshrc-config

# DETERMINE OS + IP and DETERMINE ENVIRONMENT ================================ #

source "$HOME/.zshrc-config/.env"
source "$ZSHRC_ROOT/_get-env.zsh"

# MAIN ZSH =================================================================== #

source "$ZSHRC_ROOT/_zsh-config.zsh"
source "$ZSHRC_ROOT/lib/k.plugin.sh" # LOAD 'k' LOCALLY 😁

# SET NODE VERSION =========================================================== #

source "$ZSHRC_ROOT/lib/nvm.zsh"

# SET NODE VERSION =========================================================== #

# NOTE: this file could be ROOT to import all other COMMON vendor configs from /vendor/.. folder
# fzf, nvm, pmpm, etc.
source "$ZSHRC_ROOT/_vendor.zsh"

# INIT FZF (moved from _fin.zsh) ============================================= #

source "$ZSHRC_ROOT/lib/fzf.zsh"
source "$ZSHRC_ROOT/lib/fzf.custom.zsh"

# ============================================================================ #

# LOCALE (DEFAULT, MAY BE OVERWRITTEN BY ENV)
export LC_ALL=C
export LANGUAGE=en_US.UTF-8

# ============================================================================ #

# LOCALE (DEFAULT, MAY BE OVERWRITTEN BY ENV)
export EDITOR="vim"
export IDE="code-insiders"
edit() { "$EDITOR $@"; }
code() { "$IDE $@"; }
alias code-insiders="/Applications/Visual\ Studio\ Code\ -\ Insiders.app/Contents/MacOS/Electron"

# COMMON UNIVERSALS ========================================================== #

source "$ZSHRC_ROOT/lib/common.git.zsh"

# TERMINAL INSIDE VSCode ?? ================================================== #

# NOTE: MIN INIT (terminal in VSCode)

if [ $TERM_PROGRAM = 'vscode' ]; then
  export ZENV='vscode'
  source "$ZSHRC_ROOT/_zenvs/$ZENV/$ZENV.zsh"
else

  # NOTE: DEFAULT INIT (not in VSCode)

  # START/RESTART: CLEAR CLI + SPINNER
  clear
  echo "\n"
  node "$ZSHRC_ROOT/lib/spinner.js"

  # CORE
  source "$ZSHRC_ROOT/lib/colors.zsh"
  source "$ZSHRC_ROOT/lib/paths.$OS_NAME_LOWER.zsh"

  # COMMON
  source "$ZSHRC_ROOT/lib/utils.zsh"
  source "$ZSHRC_ROOT/lib/common.zsh"
  source "$ZSHRC_ROOT/lib/common.dev.zsh"

  source "$ZSHRC_ROOT/_zenvs/$ZENV/$ZENV.zsh"

  # FINALIZATION OUTPUT
  source "$ZSHRC_ROOT/_fin.zsh"
fi

# REMOVE DUPLICATES FROM PATH ================================================ #

flatten_PATH
