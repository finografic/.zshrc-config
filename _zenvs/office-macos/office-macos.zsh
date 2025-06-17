# SPECIFIC ===================================================== #
export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/${ZENV}"
export NVM="true"

# EDITOR + IDE OVERRIDES (set originally in main.zsh)
# ...

# GET: ARTIFACTORY_NPM_TOKEN
source $HOME/.nvmrc

# Setting PATH for Python 3.11
# The original version is saved in .zprofile.pysave
export PATH=$PATH:/Library/Frameworks/Python.framework/Versions/3.11/bin
eval "$(/usr/local/bin/brew shellenv)"

# GET CURRENT ENVIRONMENT - ADDITIONAL CONFIGS
# source "${ZENV_PATH}//${ZENV}.hardware.zsh";

# ============================================================== #

# INCLUDES: DEFAULTS
source "$ZSHRC_ROOT/lib/aliases.common.zsh"
source "$ZSHRC_ROOT/lib/git.zsh"
source "$ZSHRC_ROOT/lib/dev.jest.zsh"
source "$ZSHRC_ROOT/lib/maintenance.zsh"

# INCLUDES: DEV ZENV-SPECIFIC
source "$ZENV_PATH/$ZENV.paths.zsh"
source "$ZENV_PATH/$ZENV.aliases.zsh"
source "$ZENV_PATH/$ZENV.dev.zsh"

# ============================================================== #
# GIT UTIL OVERRIDE

# Branch operations
_gb() {
  if [[ $1 > "" ]]; then
    NEW_BRANCH="SBS-${1}"
    git checkout -b "${NEW_BRANCH/SBS-SBS/"SBS"}"
  else
    # git branch-select -l
    echo "\n${_y}⚠️   NO BRANCH NAME SUPPLIED\n"
    checkout # git branch-select
  fi
}

# ============================================================== #

# iTERM SHELL INTEGRATION
# source $ZSHRC_ROOT/.iterm2_shell_integration.zsh

# iTerm2 PROFILES > ADVANCED > SMART-SELECTION > ADD:
# (REGEX for IGNORING CLI PROMPT WHEN SELECTING VIA TRIPLE-CLICK):
# \b[^\]\$]*$

# NOTE: UPDATE GHOSTTY CONFIG
update_ghostty_config

# ============================================================== #

# INCLUDE PM2 USING macOS "lanchd" // NOTE: MAY REQUIRE "sudo"
# PM2 startup DOCS: https://pm2.keymetrics.io/docs/usage/startup/
# [ -e ${NPM_GLOBALS}/pm2 ] && eval "sudo env PATH=\$PATH:${NPM_GLOBALS}/../lib/node_modules/pm2/bin/pm2 startup launchd -u ${USER} --hp ${HOME}";

# TODO: NOT EVERY LAUNCH - ESPECIALLY IF NOT ON M1
# ENSURE LOUPDECK POINTS to CORRECT $HOME FOLDER
# sh $HOME/.local/share/Loupedeck/_Loupedeck_DEV/scripts/loupedeck/setHomeUserPaths.sh

# ============================================================== #

# Setup git config
if [ -f "$ZSHRC_ROOT/.gitconfig" ]; then
  chmod 600 "$ZSHRC_ROOT/.gitconfig"
  cp "$ZSHRC_ROOT/.gitconfig" "$ZSHRC_ROOT/.git/config"
  # git config --local --get user.name || git config --local user.name "Justin Rankin"
  # git config --local --get user.email || git config --local user.email "justin.blair.rankin@gmail.com"
fi

if [ -f "$ZSHRC_ROOT/.git/config" ]; then
  chmod 600 "$ZSHRC_ROOT/.git/config"
fi

git config --global user.name "Justin Rankin"
git config --global user.email "REDACTED-EMAIL"

# ...existing code...

# ============================================================== #
# NOTE: START colima / docker..

# if ! colima status &>/dev/null; then
#   echo "${_grey}Starting Colima...${_0}"
#   colima start &>/dev/null &
#   while ! colima status &>/dev/null; do
#     sleep 1
#   done
#   echo "${_g}Colima is ready${_0}"
# fi
