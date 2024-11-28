# VSCODE START  ============================================================ #

export ZSH_THEME="gallois"

# CORE
source "$ZSHRC_ROOT/lib/paths.$OS_NAME_LOWER.zsh"
source "$ZSHRC_ROOT/lib/colors.zsh"

# COMMON
source "$ZSHRC_ROOT/lib/utils.zsh"
source "$ZSHRC_ROOT/lib/utils.disk.zsh"
source "$ZSHRC_ROOT/lib/common.zsh"
source "$ZSHRC_ROOT/lib/dev.zsh"
source "$ZSHRC_ROOT/lib/dev.git.zsh"
source "$ZSHRC_ROOT/lib/dev.jest.zsh"

# iTERM SHELL INTEGRATION
source $HOME/.iterm2_shell_integration.zsh

# SPECIFIC
export ZSHRC_ROOT=$HOME/.zshrc-config
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/$ZENV"
export NVM="true"
export IDE="Visual Studio Code - Insiders.app"
# export IDE="/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin"
export EDITOR="$(which $IDE)"
# code() { "$EDITOR $@"; }

# UNIVERSAL
alias dls="cd $HOME/Downloads && l"
alias www="cd /var/www && l"

# GET CURRENT ENVIRONMENT - ADDITIONAL CONFIGS
# source "${ZENV_PATH}//${ZENV}.hardware.zsh";
source "$ZENV_PATH/$ZENV.dev.zsh"
