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

eval "$(/usr/local/bin/brew shellenv)"

# ============================================================== #

# INCLUDES: DEFAULTS
source "$ZSHRC_ROOT/lib/aliases.common.zsh"
source "$ZSHRC_ROOT/lib/dev.git.zsh"
source "$ZSHRC_ROOT/lib/dev.jest.zsh"

# INCLUDES: MISC
source "$ZSHRC_ROOT/lib/clean.zsh"
source "$ZENV_PATH/$ZENV.backups.zsh"

# INCLUDES: DEV ZENV-SPECIFIC
# source "$ZENV_PATH//$ZENV.hardware.zsh";
source "$ZENV_PATH/$ZENV.paths.zsh"
source "$ZENV_PATH/$ZENV.aliases.zsh"
source "$ZENV_PATH/$ZENV.dev.zsh"

# ============================================================== #

# iTERM SHELL INTEGRATION
# source $ZSHRC_ROOT/.iterm2_shell_integration.zsh

# PM2 + VERDACCIO
# sudo env PATH=$PATH:/Users/REDACTED/.nvm/versions/node/v22.1.0/bin /Users/REDACTED/.nvm/versions/node/v22.1.0/lib/node_modules/pm2/bin/pm2 startup launchd -u justin --hp /Users/REDACTED

# iTerm2 PROFILES > ADVANCED > SMART-SELECTION > ADD:
# (REGEX for IGNORING CLI PROMPT WHEN SELECTING VIA TRIPLE-CLICK):
# \b[^\]\$]*$

# INCLUDE PM2 USING macOS "lanchd" // NOTE: MAY REQUIRE "sudo"
# PM2 startup DOCS: https://pm2.keymetrics.io/docs/usage/startup/
# [ -e ${NPM_GLOBALS}/pm2 ] && eval "sudo env PATH=\$PATH:${NPM_GLOBALS}/../lib/node_modules/pm2/bin/pm2 startup launchd -u ${USER} --hp ${HOME}";

# NOTE: UPDATE GHOSTTY CONFIG
update_ghostty_config

# ============================================================== #

# TODO: NOT EVERY LAUNCH - ESPECIALLY IF NOT ON M1
# ENSURE LOUPDECK POINTS to CORRECT $HOME FOLDER
# sh $HOME/.local/share/Loupedeck/_Loupedeck_DEV/scripts/loupedeck/setHomeUserPaths.sh

# ============================================================== #

# ============================================================== #
# NOTE: START colima / docker..

if ! colima status &>/dev/null; then
  echo "${_grey}Starting Colima...${_0}"
  colima start &>/dev/null &
  while ! colima status &>/dev/null; do
    sleep 1
  done
  echo "${_g}Colima is ready${_0}"
fi
