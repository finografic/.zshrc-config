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
elif [ $OS = 'Android' ]
then
    # MOBILE: (ANDROID + TMUX)
    export ZENV='android'
    export STORAGE_ROOT="/storage/emulated/0/termux" # would $(pwd) WORK IN THIS CASE ??
    export PATH_ZSHRC=$STORAGE_ROOT/.zshrc-config
else
    # DEFAULT: LOCAL (HOME)
    export ZENV='home'
fi

export ZSHRC_ROOT=$PATH_ZSHRC/.zshrc-config

# START/RESTART: CLEAR CLI + SPINNER
clear;
echo "\n";
node "$ZSHRC_ROOT/lib/spinner.js";

# LOCALE (DEFAULT, MAY BE OVERWRITTEN BY ENV)
export LC_ALL=C

# NODE
export NODE_CURRENT_VERSION=$(node -v);

# MAIN ZSH
source "$ZSHRC_ROOT/_zsh-config.zsh";

# CORE
source "$ZSHRC_ROOT/lib/colors.zsh";
source "$ZSHRC_ROOT/hardware/hardware.zsh";
source "$ZSHRC_ROOT/lib/paths.zsh";

# COMMON
source "$ZSHRC_ROOT/lib/functions-sys.zsh";
source "$ZSHRC_ROOT/lib/functions-utils.zsh";
source "$ZSHRC_ROOT/lib/common.zsh";
source "$ZSHRC_ROOT/lib/common-dev.zsh";

# GET CURRENT ENVIRONMENT
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.zsh";
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.hardware.zsh";
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.dev.zsh";

# FINALIZATION OUTPUT
source "$ZSHRC_ROOT/_fin.zsh";

