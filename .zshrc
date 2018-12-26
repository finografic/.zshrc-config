###########################################
########## INCLUDE CONFIGS FILES  #########
###########################################

# INIT DIR
ZSH_CONFIG=$HOME/.zshrc-config

# MAIN INCLUDES
source "$ZSH_CONFIG/_zsh-base.zsh";
source "$ZSH_CONFIG/_zsh-config.zsh";
source "$ZSH_CONFIG/_zsh-paths.zsh";

# ADDITIONAL FUNCTIONALITY
source "$ZSH_CONFIG/colors.zsh";
source "$ZSH_CONFIG/functions.zsh";
source "$ZSH_CONFIG/misc-dev.zsh";

# GET VARIOUS CUSTOM ENVIRONMENTS
source "$ZSH_CONFIG/_${ZENV}/${ZENV}-config.zsh"; # $ZENV DEFINED IN _zsh-bash.zsh

# FINALIZATION OUTPUT
source "$ZSH_CONFIG/_zsh-finalize.zsh";