###########################################
########## INCLUDE CONFIGS FILES  #########
###########################################

# GET SYS
export OS=$(uname -o);
export HOSTNAME=$(hostname);
export IP=$(curl -s ipinfo.io/ip);
export IP_HOME='REDACTED-IP';
export IP_A2='REDACTED-IP';
export PATH_ZSHRC=$HOME; # DEFAULT - $(pwd) COULD BE USED ??

# DETERMINE ENVIRONMENT and POINT
if [ $IP = $IP_A2 ]
then
    # SERVER: REMOVE(A2)
    export ZENV='a2'
    export ZSH_THEME="gallois"
elif [ $OS = 'Android' ]
then
    # MOBILE: (ANDROID + TMUX)
    export ZENV='android'
    export ZSH_THEME="gallois"
    export STORAGE_ROOT="/storage/emulated/0/termux" # would $(pwd) WORK IN THIS CASE ??
    export PATH_ZSHRC=$STORAGE_ROOT/.zshrc-config
else
    # DEFAULT: LOCAL (HOME)
    export ZENV='home'
    export ZSH_THEME="fino-time"
fi

export ZSHRC_ROOT=$PATH_ZSHRC/.zshrc-config

# SET NODE VERSION

# if [[ $NVM = "true" ]];  then
#   export NVM_DIR="$HOME/.nvm"
#   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#   [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# else
#   export PATH=$PATH:$HOME/.npm-global/bin
# fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm 

nvm use 12;
export NODE_CURRENT_VERSION=$(node --version)
# export NPM_GLOBALS=$NVM_DIR/versions/node/$NODE_CURRENT_VERSION/lib/node_modules/
export NPM_GLOBALS=$NVM_DIR/versions/node/$NODE_CURRENT_VERSION/bin

# START/RESTART: CLEAR CLI + SPINNER
clear;
echo "\n";
node "$ZSHRC_ROOT/lib/spinner.js";

# LOCALE (DEFAULT, MAY BE OVERWRITTEN BY ENV)
export LC_ALL=C

# MAIN ZSH
source "$ZSHRC_ROOT/_zsh-config.zsh";
source "$ZSHRC_ROOT/lib/k.plugin.sh"; # LOAD 'k' LOCALLY 😁

# CORE
source "$ZSHRC_ROOT/lib/colors.zsh";
source "$ZSHRC_ROOT/lib/paths.zsh";

# COMMON
source "$ZSHRC_ROOT/lib/functions-sys.zsh";
source "$ZSHRC_ROOT/lib/functions-utils.zsh";
source "$ZSHRC_ROOT/lib/common.zsh";
source "$ZSHRC_ROOT/lib/common-dev.zsh";

# GET CURRENT ENVIRONMENT
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.zsh";

# FINALIZATION OUTPUT
source "$ZSHRC_ROOT/_fin.zsh";

