#!/bin/bash

###########################################
########## INCLUDE CONFIGS FILES  #########
###########################################
export ZSH_DISABLE_COMPFIX="true";

# WHICH SYS/OS ARE WE ON ??
if [ "$(sw_vers -productName 2> /dev/null)" ]; then
  productName="$(sw_vers -productName)";
  [ $productName = "Mac OS X" ] || [ $productName = "macOS" ] && export OS_NAME="macOS" || export OS_NAME=$(sw_vers -productName);
  export OS_VERSION=$(sw_vers -productVersion);
  export OS_KERNEL=$(sw_vers -buildVersion); # NOT ACTUALLY "KERNEL" ON macOS HERE
else
  [[ $(uname -o) = "GNU/Linux" ]] && export OS_NAME="Linux" || export OS_NAME=$(uname -o);
  export OS_VERSION=$(uname -s);
  export OS_KERNEL=$(uname -r);
fi;

OS_NAME_LOWER=$(echo $OS_NAME | awk '{print tolower($0)}');

# HOSTNAME
export HOSTNAME=$(hostname);

# GET IP ADDRESS
# [[ $(ipconfig 2> /dev/null) ]] && export IP=$(ipconfig getifaddr en0) || export IP=$(curl -s ipinfo.io/ip);
[ $(ipconfig getifaddr en0 2> /dev/null) ] && export IP=$(ipconfig getifaddr en0) || export IP=$(curl -s ipinfo.io/ip);
IP_HOME='REDACTED-IP'; # OLD HOME IP ??
IP_HOME_MAC='REDACTED-IP';
IP_A2='REDACTED-IP';
IP_ROCK='REDACTED-IP';
IP_OFFICE_MAC='REDACTED-IP';
export PATH_ZSHRC=$HOME; # DEFAULT - $(pwd) COULD BE USED ??

# DETERMINE ENVIRONMENT and POINT
if [ $IP = $IP_A2 ]; then
  # SERVER: REMOVE(A2)
  export OS_NAME='Linux';
  export ZENV='a2'
  export ZSH_THEME="gallois"
  elif [ $OS_NAME = 'macOS' ] && [ $IP = $IP_HOME_MAC ]; then
  # HOME: (MACOS)
  export ZENV='home-mac'
  export ZSH_THEME="gallois"
  elif [ $OS_NAME = 'macOS' ]; then
  # OFFICE: (MACOS)
  export ZENV='office-mac'
  export ZSH_THEME="gallois"
  elif [ $IP = $IP_ROCK ]; then
  # SERVER: REMOVE(A2)
  export OS_NAME='Linux';
  export ZENV='a2-rock'
  export ZSH_THEME="gallois"
  elif [ $OS_NAME = 'Android' ]; then
  # MOBILE: (ANDROID + TMUX)
  export ZENV='android'
  export ZSH_THEME="gallois"
  export STORAGE_ROOT="${HOME}"
  export PATH_ZSHRC=$STORAGE_ROOT
else
  # DEFAULT: LOCAL (HOME)
  export OS_NAME='Linux';
  export ZENV='home'
  export ZSH_THEME="fino-time"
fi;

# MAIN ZSH
export ZSHRC_ROOT=$PATH_ZSHRC/.zshrc-config
source "$ZSHRC_ROOT/_zsh-config.zsh";
source "$ZSHRC_ROOT/lib/k.plugin.sh"; # LOAD 'k' LOCALLY 😁

# SET NODE VERSION
export NVM_DIR="$HOME/.nvm"
[ OS_NAME="Android" ] && unset PREFIX;
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm

# DETERMINE ENVIRONMENT and POINT
if [ $OS_NAME = 'Linux' ]; then nvm use 14;
  elif [ $OS_NAME = 'macOS' ]; then nvm use 14; # ports4;
  elif [ $OS_NAME = 'Android' ]; then nvm use 14;# NADA
else nvm use 12; # DEFAULT ALIAS
fi;

export NODE_CURRENT_VERSION=$(node --version)
# export NPM_GLOBALS=$NVM_DIR/versions/node/$NODE_CURRENT_VERSION/lib/node_modules/
export NPM_GLOBALS=$NVM_DIR/versions/node/$NODE_CURRENT_VERSION/bin

# LOCALE (DEFAULT, MAY BE OVERWRITTEN BY ENV)
export LC_ALL=C

# INIT FZF (moved from _fin.zsh)
[ -e ${HOME}/.fzf.zsh ] && source ${HOME}/.fzf.zsh

# INSIDE VSCODE ??
if [ $TERM_PROGRAM = 'vscode' ]; then
  # CORE
  source "$ZSHRC_ROOT/lib/paths-${OS_NAME_LOWER}.zsh";
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
  source "$ZSHRC_ROOT/lib/paths-${OS_NAME_LOWER}.zsh";
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


