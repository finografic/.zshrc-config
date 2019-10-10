###########################################
########## INCLUDE CONFIGS FILES  #########
###########################################

# GET SYS 
OS=$(uname -o);
HOSTNAME=$(hostname);
IP=$(curl -s ipinfo.io/ip);
IP_A2='REDACTED-IP';

# NODE
NODE_CURRENT=$(node -v);

# ENVIRONMENT
if [[ $IP = $IP_A2 ]] then ZENV='a2'
  elif [[ $OS = 'Android' ]] then ZENV='android'
  else ZENV='local'
fi

# INIT DIR
if [[ $ZENV = 'android' ]] 
  then
    export STORAGE_ROOT="/storage/emulated/0/termux" 
    ZSH_CONFIG="$STORAGE_ROOT/.zshrc-config"
  else ZSH_CONFIG="$HOME/.zshrc-config"
fi

# MAIN INCLUDES
source "$ZSH_CONFIG/_zsh-config.zsh";
source "$ZSH_CONFIG/paths.zsh";

# ADDITIONAL FUNCTIONALITY
source "$ZSH_CONFIG/colors.zsh";
source "$ZSH_CONFIG/aliases-common.zsh";
source "$ZSH_CONFIG/misc-dev.zsh";

# GET VARIOUS CUSTOM ENVIRONMENTS
source "$ZSH_CONFIG/zenvs/${ZENV}/${ZENV}.zsh"; # $ZENV DEFINED IN _zsh-bash.zsh

# FINALIZATION OUTPUT
source "$ZSH_CONFIG/_finalize.zsh";

