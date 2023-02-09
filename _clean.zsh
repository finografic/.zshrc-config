#!/bin/bash

###########################################
########## INCLUDE CONFIGS FILES  #########
###########################################
source "$HOME/.zshrc-config/.env";
export ZSH_DISABLE_COMPFIX="true";

# DETERMINE OS + IP and DETERMINE ENVIRONMENT ================================ #

source "$ZSHRC_ROOT/_get-env.zsh";

# MAIN ZSH =================================================================== #

export ZSHRC_ROOT=$PATH_ZSHRC/.zshrc-config
source "$ZSHRC_ROOT/_zsh-config.zsh";
source "$ZSHRC_ROOT/lib/k.plugin.sh"; # LOAD 'k' LOCALLY 😁

# SET NODE VERSION =========================================================== #

source "$ZSHRC_ROOT/lib/nvm.zsh";

# ============================================================================ #

# LOCALE (DEFAULT, MAY BE OVERWRITTEN BY ENV)
export LC_ALL=C

# INIT FZF (moved from _fin.zsh)
[ -e ${HOME}/.fzf.zsh ] && source ${HOME}/.fzf.zsh

# INSIDE VSCODE ??
if [ $TERM_PROGRAM = 'vscode' ]; then

  export ZENV='vscode'
  export ZSH_THEME="gallois"

  # CORE
  source "$ZSHRC_ROOT/lib/paths.${OS_NAME_LOWER}.zsh";
  source "$ZSHRC_ROOT/lib/colors.zsh";

  # COMMON
  source "$ZSHRC_ROOT/lib/functions-utils.zsh";
  source "$ZSHRC_ROOT/lib/common.zsh";
  source "$ZSHRC_ROOT/lib/common-dev.zsh";

  # GET CURRENT ENVIRONMENT
  source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.zsh";

else

  # START/RESTART: CLEAR CLI + SPINNER
  clear;
  echo "\n";
  node "$ZSHRC_ROOT/lib/spinner.js";

  # DETERMINE ENVIRONMENT and POINT
  # CORE
  source "$ZSHRC_ROOT/lib/paths.${OS_NAME_LOWER}.zsh";
  source "$ZSHRC_ROOT/lib/colors.zsh";

  # COMMON
  source "$ZSHRC_ROOT/lib/functions-utils.zsh";
  source "$ZSHRC_ROOT/lib/common.zsh";
  source "$ZSHRC_ROOT/lib/common-dev.zsh";

  # GET CURRENT ENVIRONMENT
  source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.zsh";

  # FINALIZATION OUTPUT
  source "$ZSHRC_ROOT/_fin.zsh";

fi;
