#!/bin/zsh

export ZSH_DISABLE_COMPFIX="true";
export ZSHRC_ROOT=$HOME/.zshrc-config

# DETERMINE OS + IP and DETERMINE ENVIRONMENT ================================ #

source "$HOME/.zshrc-config/.env";
source "$ZSHRC_ROOT/_get-env.zsh";

# MAIN ZSH =================================================================== #

source "$ZSHRC_ROOT/_zsh-config.zsh";
source "$ZSHRC_ROOT/lib/k.plugin.sh"; # LOAD 'k' LOCALLY 😁

# SET NODE VERSION =========================================================== #

source "$ZSHRC_ROOT/lib/nvm.zsh";

# INIT FZF (moved from _fin.zsh) ============================================= #

source "$ZSHRC_ROOT/lib/fzf.zsh";
source "$ZSHRC_ROOT/lib/fzf.custom.zsh";

# ============================================================================ #

# LOCALE (DEFAULT, MAY BE OVERWRITTEN BY ENV)
export LC_ALL=C
export LANGUAGE=en_US.UTF-8

# ============================================================================ #

# LOCALE (DEFAULT, MAY BE OVERWRITTEN BY ENV)
export EDITOR="vim"
export IDE="code-insiders"
edit () { "$EDITOR $@"; }
code () { "$IDE $@"; }
alias code-insiders="/Applications/Visual\ Studio\ Code\ -\ Insiders.app/Contents/MacOS/Electron"

# COMMON UNIVERSALS ========================================================== #

source "$ZSHRC_ROOT/lib/common.git.zsh";

# INSIDE VSCODE ?? =========================================================== #

if [ $TERM_PROGRAM = 'vscode' ]; then
  export ZENV='vscode'
  source "$ZSHRC_ROOT/_zenvs/$ZENV/$ZENV.zsh";
else

  # DEFAULT START (not VSCode!) ============================================== #

  # START/RESTART: CLEAR CLI + SPINNER
  clear;
  echo "\n";
  node "$ZSHRC_ROOT/lib/spinner.js";

  # CORE
  source "$ZSHRC_ROOT/lib/paths.$OS_NAME_LOWER.zsh";
  source "$ZSHRC_ROOT/lib/colors.zsh";

  # COMMON
  source "$ZSHRC_ROOT/lib/utils.zsh";
  source "$ZSHRC_ROOT/lib/common.zsh";
  source "$ZSHRC_ROOT/lib/common.dev.zsh";

  # GET CURRENT ENVIRONMENT
  source "$ZSHRC_ROOT/_zenvs/$ZENV/$ZENV.zsh";

  # FINALIZATION OUTPUT
  source "$ZSHRC_ROOT/_fin.zsh";

fi;
