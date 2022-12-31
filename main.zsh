#!/bin/bash

# $PATH for BREW
PATH="$PATH:/opt/homebrew/bin";

###########################################
########## INCLUDE CONFIGS FILES  #########
###########################################
source "$HOME/.zshrc-config/.env";
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
IP_A2='REDACTED-IP';
IP_ROCK='REDACTED-IP';
IP_OFFICE_MAC='REDACTED-IP';
IP_HOME='REDACTED-IP'; # OLD HOME IP ??
IP_HOME_MAC_2018_ORIG='REDACTED-IP';
IP_HOME_MAC_2018='REDACTED-IP';
IP_HOME_MAC_ORIG='REDACTED-IP';
IP_HOME_MAC='REDACTED-IP';

export PATH_ZSHRC=$HOME; # DEFAULT - $(pwd) COULD BE USED ??

# DETERMINE ENVIRONMENT and POINT
if [ $IS_HOME ]; then
    # DEFAULT FROM .env: HOME (MACOS)
    export ZENV='home-mac'
    export ZSH_THEME="gallois"
  elif [ $IP = $IP_HOME_MAC_2018 ]; then
    # DEFAULT FROM .env: HOME (MACOS)
    export ZENV='home-mac-2018'
    export ZSH_THEME="gallois"
  elif [ $IP = $IP_A2 ]; then
    # SERVER: REMOVE(A2)
    export OS_NAME='Linux';
    export ZENV='a2'
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
  elif [ $OS_NAME = 'Android' ]; then
    # HOME: (LINUX)
    export OS_NAME='Linux';
    export ZENV='home'
    export ZSH_THEME="fino-time"
else
    # DEFAULT: HOME (MACOS)
    export ZENV='home-mac'
    export ZSH_THEME="gallois"
fi;

# MAIN ZSH
export ZSHRC_ROOT=$PATH_ZSHRC/.zshrc-config
source "$ZSHRC_ROOT/_zsh-config.zsh";
source "$ZSHRC_ROOT/lib/k.plugin.sh"; # LOAD 'k' LOCALLY 😁

# SET NODE VERSION
export NVM_DIR="$HOME/.nvm"
[ OS_NAME="Android" ] && unset PREFIX;
  # V1: ORIG
  # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  # [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm
  # V2: NEW (CONTIONAL, BELOW..)
  # export NVM_DIR="$HOME/.nvm"
  # [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  # [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# NVM home-mac ONLY - TODO: FIX WITH ABOVE!
if [ $ZENV = 'home-mac'  ]; then
  # V1: ORIG
  # [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && . "$(brew --prefix)/opt/nvm/nvm.sh";
  # [ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && . "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm";
  # V2: NEW
  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
fi;

# DETERMINE ENVIRONMENT and POINT
NODE_VERSION_PREFERRED=14; # DEFAULT ALIAS
[ $OS_NAME = 'Linux'  ] && NODE_VERSION_PREFERRED=16;
[ $OS_NAME = 'macOS'  ] && NODE_VERSION_PREFERRED=16;
[ $OS_NAME = 'Android' ]&&  NODE_VERSION_PREFERRED=14;
nvm use $NODE_VERSION_PREFERRED;

export NODE_CURRENT_VERSION=$(node --version)
# export NPM_GLOBALS=$NVM_DIR/versions/node/$NODE_CURRENT_VERSION/lib/node_modules/
export NPM_GLOBALS=$NVM_DIR/versions/node/$NODE_CURRENT_VERSION/bin

# LOCALE (DEFAULT, MAY BE OVERWRITTEN BY ENV)
export LC_ALL=C

# INIT FZF (moved from _fin.zsh)
set rtp+=/opt/homebrew/opt/fzf
# NEW BIN FILE: /opt/homebrew/bin/fzf
[ -e ${HOME}/.fzf.zsh ] && source ${HOME}/.fzf.zsh

# INSIDE VSCODE ??
if [ $TERM_PROGRAM = 'vscode' ]; then

  export ZENV='home-vscode'
  export ZSH_THEME="gallois"

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
