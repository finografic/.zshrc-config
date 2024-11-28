# SPECIFIC ===================================================== #

export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/$ZENV"
export NVM="true"

# ============================================================== #

# BUN - https://bun.sh
# TODO: CAUSING ERROR IN $PATH !!
# [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
# export BUN_INSTALL="$HOME/.bun"
# export PATH="$BUN_INSTALL/bin:$PATH"

# ============================================================== #

# INCLUDES: DEFAULT
source "$ZSHRC_ROOT/lib/dev.git.zsh"
source "$ZSHRC_ROOT/lib/dev.jest.zsh"

# INCLUDES: HOME-macOS
# source "$ZENV_PATH//$ZENV.hardware.zsh";
source "$ZENV_PATH/$ZENV.paths.zsh"
source "$ZENV_PATH/$ZENV.aliases.zsh"
source "$ZENV_PATH/$ZENV.dev.zsh"

# iTERM SHELL INTEGRATION
source $HOME/.iterm2_shell_integration.zsh

# INCLUDES - if NOT in VSCode environment
[ $TERM_PROGRAM != 'vscode' ] && source "$ZSHRC_ROOT/lib/clean.zsh"
[ $TERM_PROGRAM != 'vscode' ] && source "$ZENV_PATH/$ZENV.backups.zsh"

# ENSURE LOUPDECK POINTS to CORRECT $HOME FOLDER
sh $HOME/.local/share/Loupedeck/_Loupedeck_DEV/scripts/loupedeck/setHomeUserPaths.sh

# ============================================================== #

# iTerm2 PROFILES > ADVANCED > SMART-SELECTION > ADD:
# (REGEX for IGNORING CLI PROMPT WHEN SELECTING VIA TRIPLE-CLICK):
# \b[^\]\$]*$

# INCLUDE PM2 USING macOS "lanchd" // NOTE: MAY REQUIRE "sudo"
# PM2 startup DOCS: https://pm2.keymetrics.io/docs/usage/startup/
# [ -e ${NPM_GLOBALS}/pm2 ] && eval "sudo env PATH=\$PATH:${NPM_GLOBALS}/../lib/node_modules/pm2/bin/pm2 startup launchd -u ${USER} --hp ${HOME}";
