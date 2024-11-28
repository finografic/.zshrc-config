# SPECIFIC
export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/${ZENV}"
export NVM="true"

# EDITOR + IDE OVERRIDES (set originally in main.zsh)
# ...

# GET: ARTIFACTORY_NPM_TOKEN
source $HOME/.nvmrc

# UNIVERSAL
alias dls="cd $HOME/Downloads && l"

# GET CURRENT ENVIRONMENT - ADDITIONAL CONFIGS
# source "${ZENV_PATH}//${ZENV}.hardware.zsh";

source "$ZENV_PATH/$ZENV.paths.zsh"
source "$ZENV_PATH/$ZENV.aliases.zsh"
source "$ZENV_PATH/$ZENV.dev.zsh"
source "$ZSHRC_ROOT/lib/dev.git.zsh"
source "$ZSHRC_ROOT/lib/dev.jest.zsh"

# iTERM SHELL INTEGRATION
source $HOME/.iterm2_shell_integration.zsh

# INCLUDE PM2 USING macOS "lanchd" // NOTE: MAY REQUIRE "sudo"
# PM2 startup DOCS: https://pm2.keymetrics.io/docs/usage/startup/
# [ -e ${NPM_GLOBALS}/pm2 ] && eval "sudo env PATH=\$PATH:${NPM_GLOBALS}/../lib/node_modules/pm2/bin/pm2 startup launchd -u ${USER} --hp ${HOME}";

# INSIDE VSCODE ??
# [ $TERM_PROGRAM != 'vscode' ] && source "${ZENV_PATH}/${ZENV}.backups.zsh";

# iTerm2 PROFILES > ADVANCED > SMART-SELECTION > ADD:
# (REGEX for IGNORING CLI PROMPT WHEN SELECTING VIA TRIPLE-CLICK):
# \b[^\]\$]*$

# ENSURE LOUPDECK POINTS to CORRECT $HOME FOLDER
sh $HOME/.local/share/Loupedeck/_Loupedeck_DEV/scripts/loupedeck/setHomeUserPaths.sh

# Setting PATH for Python 3.11
# The original version is saved in .zprofile.pysave
export PATH=$PATH:/Library/Frameworks/Python.framework/Versions/3.11/bin

eval "$(/usr/local/bin/brew shellenv)"

git config --global user.name "Justin Rankin"
git config --global user.email "REDACTED-EMAIL"
