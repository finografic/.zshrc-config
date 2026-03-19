# SPECIFIC ===================================================== #
export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/${ZENV}"
export NVM="true"

# EDITOR + IDE OVERRIDES (set originally in main.zsh)
# ...

# Setting PATH for Python 3.11
# The original version is saved in .zprofile.pysave
export PATH=$PATH:/Library/Frameworks/Python.framework/Versions/3.11/bin

# ============================================================== #

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

# ============================================================== #

# INCLUDES: DEFAULTS
source "$ZSHRC_ROOT/lib/aliases.common.zsh"
source "$ZSHRC_ROOT/lib/git.zsh"
# source "$ZSHRC_ROOT/lib/dev.jest.zsh"
source "$ZSHRC_ROOT/lib/maintenance.zsh"

# INCLUDES: DEV ZENV-SPECIFIC
source "$ZENV_PATH/$ZENV.paths.zsh"
source "$ZENV_PATH/$ZENV.aliases.zsh"
source "$ZENV_PATH/$ZENV.dev.zsh"
source "$ZENV_PATH/$ZENV.dev.jest.zsh"

# ============================================================== #
# TODO: TESTING CLI TOOL - Helper for merging template.ui

# source "$ZENV_PATH/lib/template-tool/__tool.zsh"
# source "$HOME/.zshrc-config/lib/template-tool/__tool.zsh"
# source "$HOME/.zshrc-config/lib/template-tool/__tool-accept.zsh"
# source "$HOME/.zshrc-config/lib/template-tool/__TOOLS.zsh"

# NEW: COVERAGE SUMMARY TOOL
# source "$ZENV_PATH/parse-test-coverage.zsh"
alias parse-coverage="~/bin/parse-test-coverage.zsh"
export PATH=$PATH:$HOME/bin/gen-test-summary
export PATH=$PATH:$HOME/bin/gen-todo-coverage

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
# ENSURE LOUPEDECK POINTS to CORRECT $HOME FOLDER
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
# NOTE: START docker (Docker Desktop)..

# if ! docker info &>/dev/null; then
#   echo "${_grey}Starting Docker Desktop...${_0}"
#   open -a Docker &>/dev/null
#   # Wait for Docker to be ready
#   while ! docker info &>/dev/null; do
#     sleep 1
#   done
#   echo "${_g}Docker is ready${_0}"
# fi

# ============================================================== #
# SECURITY CHECKS: Maximum Security for Work System

# Check macOS Firewall status (OFFICE: Show warning if disabled)
FIREWALL_STATUS=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null | grep -i "enabled" || echo "")
if [[ -z "$FIREWALL_STATUS" ]]; then
  echo "${_y}⚠️  Firewall may not be enabled. For security, enable in System Settings → Network → Firewall${_0}"
fi

# WIP: Security check commented out for now
# # Check for suspicious external ESTABLISHED connections (excluding known safe ports 11434, 3001)
# # NOTE: Ports 11434 (Ollama) and 3001 (OpenWebUI) are intentionally excluded
# if command -v lsof &>/dev/null; then
#   SUSPICIOUS_CONN=$(lsof -i -P 2>/dev/null | grep "ESTABLISHED" | grep -vE "127.0.0.1|localhost|::1|:11434|:3001" || echo "")
#   if [[ -n "$SUSPICIOUS_CONN" ]]; then
#     echo "${_r}⚠️  SECURITY WARNING: Non-localhost ESTABLISHED connections detected!${_0}"
#     echo "${_r}   Check: lsof -i -P | grep ESTABLISHED${_0}"
#   fi
# fi

# ============================================================== #
# VERIFY: LaunchAgent Services (djay backup, etc.)

# Check djay backup service
DJAY_BACKUP_PLIST="$HOME/Library/LaunchAgents/com.user.dj-crate-backup.plist"
if [[ -f "$DJAY_BACKUP_PLIST" ]]; then
  if ! launchctl list | grep -q "com.user.dj-crate-backup"; then
    echo "${_y}⚠️  djay backup service not loaded. Loading...${_0}"
    launchctl load "$DJAY_BACKUP_PLIST" 2>/dev/null && echo "${_g}✅ djay backup service loaded${_0}" || echo "${_r}❌ Failed to load djay backup service${_0}"
  fi
  # TODO: Initial setup - ensure plist has RunAtLoad=true for startup execution
fi

# Check djay sync service (if exists)
DJAY_SYNC_PLIST="$HOME/Library/LaunchAgents/com.user.djay-sync.plist"
if [[ -f "$DJAY_SYNC_PLIST" ]]; then
  if ! launchctl list | grep -q "com.user.djay-sync"; then
    echo "${_y}⚠️  djay sync service not loaded. Loading...${_0}"
    launchctl load "$DJAY_SYNC_PLIST" 2>/dev/null && echo "${_g}✅ djay sync service loaded${_0}" || echo "${_r}❌ Failed to load djay sync service${_0}"
  fi
fi
