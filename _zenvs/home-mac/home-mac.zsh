# SPECIFIC
export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/${ZENV}"
export NVM="true"
export IDE="vim"
# export IDE="Visual Studio Code - Insiders.app"
# export IDE="/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin"
export EDITOR="$(which $IDE)"
code () { "$EDITOR $@"; }

# UNIVERSAL
alias dls="cd $HOME/Downloads && l"
alias www="cd /var/www && l"

# GET CURRENT ENVIRONMENT - ADDITIONAL CONFIGS
# source "${ZENV_PATH}//${ZENV}.hardware.zsh";
source "${ZENV_PATH}/${ZENV}.dev.zsh";

# iTERM SHELL INTEGRATION
source $HOME/.iterm2_shell_integration.zsh

# INCLUDE PM2 USING macOS "lanchd" // NOTE: MAY REQUIRE "sudo"
# PM2 startup DOCS: https://pm2.keymetrics.io/docs/usage/startup/
# [ -e ${NPM_GLOBALS}/pm2 ] && eval "sudo env PATH=\$PATH:${NPM_GLOBALS}/../lib/node_modules/pm2/bin/pm2 startup launchd -u ${USER} --hp ${HOME}";

source $HOME/.nvmrc

# INSIDE VSCODE ??
[ $TERM_PROGRAM != 'vscode' ] && source "${ZENV_PATH}/${ZENV}.backups.zsh";
