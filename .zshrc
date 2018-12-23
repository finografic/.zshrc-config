###########################################
########## INCLUDE CONFIGS FILES  #########
###########################################

ZSH_CONFIG=$HOME/.zshrc-config

source "$ZSH_CONFIG/_zsh-base.zsh";
source "$ZSH_CONFIG/_zsh-config.zsh";
source "$ZSH_CONFIG/colors.zsh";
source "$ZSH_CONFIG/functions.zsh";
source "$ZSH_CONFIG/misc-dev.zsh";

if [ $IS_SSH=false ]; then source "$ZSH_CONFIG/local.zsh"; fi;
if [ $IP = $IP_GD ]; then source "$ZSH_CONFIG/_godaddy/godaddy-config.zsh"; fi;
if [ $IP = $IP_AWS ]; then source "$ZSH_CONFIG/_aws/aws-config.zsh"; fi;

source "$ZSH_CONFIG/_zsh-finalize.zsh";