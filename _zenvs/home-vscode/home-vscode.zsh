# SPECIFIC
export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/${ZENV}"
export NVM="true"
export IDE="Visual Studio Code - Insiders.app"
# export IDE="/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin"
export EDITOR="$(which $IDE)"
code () { "$EDITOR $@"; }

# UNIVERSAL
alias dls="cd $HOME/Downloads && l"
alias www="cd /var/www && l"

# GET CURRENT ENVIRONMENT - ADDITIONAL CONFIGS
# source "${ZENV_PATH}//${ZENV}.hardware.zsh";
source "${ZENV_PATH}/${ZENV}.dev.zsh";
