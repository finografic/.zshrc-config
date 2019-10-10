###########################################
########## INCLUDE CONFIGS FILES  #########
###########################################

# GET SYS 
export OS=$(uname -o);
export HOSTNAME=$(hostname);
export IP=$(curl -s ipinfo.io/ip);
export IP_A2='REDACTED-IP';

if [ $IP = $IP_A2 ]
then
  export ZENV='a2'
  export ZSH_CONFIG=$HOME/.zshrc-config
elif [ $OS = 'Android' ] 
then 
  export ZENV='android'
  export STORAGE_ROOT="/storage/emulated/0/termux"
  export ZSH_CONFIG=$STORAGE_ROOT/.zshrc-config
else
  export ZENV='local'
   export ZSH_CONFIG=$HOME/.zshrc-config
fi

# NODE
export NODE_CURRENT=$(node -v);

# MAIN INCLUDES
source "$ZSH_CONFIG/_zsh-config.zsh";
source "$ZSH_CONFIG/lib/paths.zsh";

# ADDITIONAL FUNCTIONALITY
source "$ZSH_CONFIG/lib/colors.zsh";
source "$ZSH_CONFIG/lib/aliases-common.zsh";
source "$ZSH_CONFIG/lib/dev-common.zsh";

# GET VARIOUS CUSTOM ENVIRONMENTS
source "$ZSH_CONFIG/zenvs/${ZENV}/${ZENV}.zsh"; # $ZENV DEFINED IN _zsh-bash.zsh

# FINALIZATION OUTPUT
source "$ZSH_CONFIG/_finalize.zsh";

