# SPECIFIC ===================================================== #
export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/${ZENV}"
export NVM="true"

# EDITOR + IDE OVERRIDES (set originally in main.zsh)
# ...

# Setting PATH for Python 3.11
# The original version is saved in .zprofile.pysave
export PATH=$PATH:/Library/Frameworks/Python.framework/Versions/3.11/bin

# ============================================================================ #

# Apple Silicon Macs (M1/M2/M3) - /opt/homebrew
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
# Intel Macs - /usr/local
elif [[ -f "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  echo "Warning: Homebrew not found in /opt/homebrew/bin/brew or /usr/local/bin/brew"
fi

# GET CURRENT ENVIRONMENT - ADDITIONAL CONFIGS
# source "${ZENV_PATH}//${ZENV}.hardware.zsh";

# ============================================================================ #

# INCLUDES: DEFAULTS
source "$ZSHRC_ROOT/lib/git.zsh"
# source "$ZSHRC_ROOT/lib/dev.jest.zsh"

# INCLUDES: DEV ZENV-SPECIFIC
source "$ZENV_PATH/$ZENV.aliases.zsh"
source "$ZENV_PATH/$ZENV.dev.zsh"
source "$ZENV_PATH/$ZENV.dev.jest.zsh"

# ============================================================================ #
# TODO: TESTING CLI TOOL - Helper for merging template.ui
# ============================================================================ #

# NEW: COVERAGE SUMMARY TOOL
# source "$ZENV_PATH/parse-test-coverage.zsh"
alias parse-coverage="~/bin/parse-test-coverage.zsh"
export PATH=$PATH:$HOME/bin/gen-test-summary
export PATH=$PATH:$HOME/bin/gen-todo-coverage

# ============================================================================ #
# GIT UTIL OVERRIDE
# ============================================================================ #

# Branch operations
function _gb() {
  if [[ $1 > "" ]]; then
    NEW_BRANCH="SBS-${1}"
    git checkout -b "${NEW_BRANCH/SBS-SBS/"SBS"}"
  else
    # git branch-select -l
    echo "\n${_y}⚠️   NO BRANCH NAME SUPPLIED\n"
    checkout # git branch-select
  fi
}

# ============================================================================ #

# iTERM SHELL INTEGRATION
# source $ZSHRC_ROOT/.iterm2_shell_integration.zsh

# iTerm2 PROFILES > ADVANCED > SMART-SELECTION > ADD:
# (REGEX for IGNORING CLI PROMPT WHEN SELECTING VIA TRIPLE-CLICK):
# \b[^\]\$]*$

# NOTE: UPDATE GHOSTTY CONFIG
update-ghostty-config

# ============================================================================ #

# INCLUDE PM2 USING macOS "lanchd" // NOTE: MAY REQUIRE "sudo"
# PM2 startup DOCS: https://pm2.keymetrics.io/docs/usage/startup/
# [ -e ${NPM_GLOBALS}/pm2 ] && eval "sudo env PATH=\$PATH:${NPM_GLOBALS}/../lib/node_modules/pm2/bin/pm2 startup launchd -u ${USER} --hp ${HOME}";

# TODO: NOT EVERY LAUNCH - ESPECIALLY IF NOT ON M1
# ENSURE LOUPEDECK POINTS to CORRECT $HOME FOLDER
# sh $HOME/.local/share/Loupedeck/_Loupedeck_DEV/scripts/loupedeck/setHomeUserPaths.sh

# ============================================================================ #

# Git identity is a one-time machine-setup step, not a shell-start step.
# Run scripts/setup/configure-git-identity.zsh once per machine instead.

# ============================================================================ #
# NOTE: START docker (Docker Desktop)..
# ============================================================================ #

# if ! docker info &>/dev/null; then
#   echo "${_grey}Starting Docker Desktop...${_0}"
#   open -a Docker &>/dev/null
#   # Wait for Docker to be ready
#   while ! docker info &>/dev/null; do
#     sleep 1
#   done
#   echo "${_g}Docker is ready${_0}"
# fi

# The firewall check moved into `zdoctor` (lib/doctor.zsh) — a security warning
# is worth showing when you ask for it, not a `socketfilterfw` shell-out on every
# shell start. LaunchAgent status likewise:
#   source "$ZSHRC_ROOT/extras/music/djay-services.zsh" && djay-services-check
