# SPECIFIC
export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/${ZENV}"
export NVM="true"
export IDE="code-insiders"
export EDITOR="$(which $IDE)"
code () { "$EDITOR $@"; }

# UNIVERSAL
alias dls="cd $HOME/Downloads && l"
alias www="cd /var/www && l"

# UNIVERSAL - DEV
# PROJECTS="$HOME/dev_projects"
# alias proj="cd $PROJECTS && l"

# UNIVERSAL - DEV ALIAS TO **CURRENT** PROJECT
alias dev="echo 'CHOOSE AN ALIAS!'"

# PROJECTS
PROJECTS="$HOME/repos"
alias repos="cd $PROJECTS && l"
alias misc="cd $HOME/repos-misc && l"
alias apps="cd $HOME/repos-apps && l"
alias my="cd $HOME/repos-my && l"

# GET CURRENT ENVIRONMENT - ADDITIONAL CONFIGS
# source "${ZENV_PATH}//${ZENV}.hardware.zsh";
source "${ZENV_PATH}/${ZENV}.dev.zsh";

# iTERM SHELL INTEGRATION
source $HOME/.iterm2_shell_integration.zsh

# INCLUDE PM2 USING MacOS "lanchd" // NOTE: MAY REQUIRE "sudo"
# PM2 startup DOCS: https://pm2.keymetrics.io/docs/usage/startup/
# [ -e ${NPM_GLOBALS}/pm2 ] && eval "sudo env PATH=\$PATH:${NPM_GLOBALS}/../lib/node_modules/pm2/bin/pm2 startup launchd -u ${USER} --hp ${HOME}";

# JFROG ARTIFACTORY
source $HOME/.nvmrc

# BACKUP APP CONFIGS
source "${ZENV_PATH}/${ZENV}.backups.zsh";
