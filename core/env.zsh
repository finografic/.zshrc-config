#!/bin/zsh
# ============================================================================ #
# NOTE: CORE ENV - Environment detection and variables
# ============================================================================ #

# Detect when running inside GitHub Desktop's minimal environment and avoid
# loading the user's project `.env` (which may reference tools not available
# to the GUI/git hook environment). We set a flag so the later loader can
# skip sourcing the file.
if [[ -n "${XPC_SERVICE_NAME:-}" && "${XPC_SERVICE_NAME}" == *"GitHubClient"* ]]; then
  SKIP_ENV_LOAD=true
fi

# Load environment variables (skip when flagged above)
if [[ -z "${SKIP_ENV_LOAD:-}" && -f "$ZSHRC_ROOT/.env" ]]; then
  source "$ZSHRC_ROOT/.env"
  export NPM_TOKEN=$(awk -F= '/^NPM_TOKEN=/ {print $2; exit}' "$ZSHRC_ROOT/.env" 2>/dev/null)
fi

# VSCode memory allocation
export NODE_OPTIONS="$NODE_OPTIONS --max_old_space_size=4096"
export SIMPLE_GIT_HOOKS_RC="$HOME/.simple-git-hooks.rc"

# OS Detection and System Info =====================
# Detect OS and Version
if command -v sw_vers >/dev/null; then
  export OS_NAME="macOS"
  export OS_VERSION=$(sw_vers -productVersion)
  export OS_BUILD=$(sw_vers -buildVersion)
else
  export OS_NAME=$(uname -s)
  export OS_VERSION=$(uname -v)
  export OS_KERNEL=$(uname -r)
fi

# System Architecture and Network
export OS_ARCH=$(uname -m)
export HOSTNAME=$(hostname)

# IP Detection (with fallback)
if command -v ipconfig >/dev/null; then
  export IP=$(ipconfig getifaddr en0 2>/dev/null || curl -s ipinfo.io/ip)
else
  export IP=$(curl -s ipinfo.io/ip)
fi

# Known IP Addresses
declare -A IP_ADDRESSES=(
  [APNAES]='REDACTED-IP'
  [OFFICE]='REDACTED-IP'
  [HOME]='REDACTED-IP'
)

# Environment Detection ============================
# These variables should be set in your .env file:
# IS_HOME, IS_OFFICE, IS_SERVER

determine_environment() {
  if [[ $IS_HOME == true ]]; then
    echo "home-macos"
  elif [[ $IS_OFFICE == true ]]; then
    echo "office-macos"
  elif [[ $IS_OFFICE == true || $IS_DOCKER == true ]]; then
    echo "docker-dev"
  elif [[ $IS_SERVER == true || $IP == ${IP_ADDRESSES[APNAES]} ]]; then
    export OS_NAME='Linux'
    echo "apnaes"
  elif [[ $OS_NAME == "Android" ]]; then
    export STORAGE_ROOT="${HOME}"
    export PATH_ZSHRC=$STORAGE_ROOT
    echo "android"
  else
    echo "home-macos" # Default
  fi
}

# Compilation flags ============================
# detect and set architecture
if [[ $(uname -m) == "arm64" ]]; then
  export ARCHFLAGS="-arch arm64"
else
  export ARCHFLAGS="-arch x86_64"
fi
