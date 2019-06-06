###########################################
########## INCLUDE CONFIGS FILES  #########
###########################################

# INIT DIR
ZSH_CONFIG=$HOME/.zshrc-config

# MAIN INCLUDES
source "$ZSH_CONFIG/_zsh-init.zsh";
source "$ZSH_CONFIG/_zsh-config.zsh";
source "$ZSH_CONFIG/_zsh-paths.zsh";

# ADDITIONAL FUNCTIONALITY
source "$ZSH_CONFIG/colors.zsh";
source "$ZSH_CONFIG/aliases.zsh";
source "$ZSH_CONFIG/misc-dev.zsh";

# GET VARIOUS CUSTOM ENVIRONMENTS
source "$ZSH_CONFIG/_${ZENV}/${ZENV}.zsh"; # $ZENV DEFINED IN _zsh-bash.zsh

# FINALIZATION OUTPUT
source "$ZSH_CONFIG/_zsh-finalize.zsh";
