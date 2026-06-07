# SPECIFIC ===================================================== #

export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/$ZENV"
export NVM="true"

# ============================================================================ #

# BUN - https://bun.sh
# TODO: CAUSING ERROR IN $PATH !!
# [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
# export BUN_INSTALL="$HOME/.bun"
# export PATH="$BUN_INSTALL/bin:$PATH"

# Dynamic brew path detection
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  echo "Warning: Homebrew not found in /opt/homebrew/bin/brew or /usr/local/bin/brew"
fi

# ============================================================================ #

# INCLUDES: DEFAULTS
source "$ZSHRC_ROOT/lib/aliases.common.zsh"
source "$ZSHRC_ROOT/lib/git.zsh"
source "$ZSHRC_ROOT/lib/dev.jest.zsh"

# INCLUDES: MISC
source "$ZSHRC_ROOT/lib/clean.zsh"
source "$ZENV_PATH/$ZENV.backups.zsh"

# INCLUDES: DEV ZENV-SPECIFIC
# source "$ZENV_PATH//$ZENV.hardware.zsh";
source "$ZENV_PATH/$ZENV.paths.zsh"
source "$ZENV_PATH/$ZENV.aliases.zsh"
source "$ZENV_PATH/$ZENV.dev.zsh"

# INCLUDES: SCRIPTS
source "$ZSHRC_ROOT/extras/music/backup-dj-crate.zsh"
# djay-backup-music

# ============================================================================ #

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
update-ghostty-config

# ============================================================================ #

# TODO: NOT EVERY LAUNCH - ESPECIALLY IF NOT ON M1
# ENSURE LOUPDECK POINTS to CORRECT $HOME FOLDER
# sh $HOME/.local/share/Loupedeck/_Loupedeck_DEV/scripts/loupedeck/setHomeUserPaths.sh

# ============================================================================ #

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

# ============================================================================ #
# SECURITY CHECKS: Minimal Security for Home System
# ============================================================================ #

# NOTE: No firewall warning for home (relaxed security)
# Ports 11434 (Ollama) and 3001 (OpenWebUI) are intentionally excluded from checks

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

# ============================================================================ #
# VERIFY: LaunchAgent Services (djay backup, etc.)
# ============================================================================ #

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
