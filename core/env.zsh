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
fi

# VSCode memory allocation
export NODE_OPTIONS="$NODE_OPTIONS --max_old_space_size=4096"
export SIMPLE_GIT_HOOKS_RC="$HOME/.simple-git-hooks.rc"

# ============================================================================ #
# OS Detection and System Info
# ============================================================================ #

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

# IP lookup is lazy and on demand — never at shell start. The previous
# implementation ran `curl ipinfo.io/ip` on every shell, which is both a network
# round-trip on the load path and a leak of your address to a third party.
#
#   myip            local address on the primary interface
#   myip --public   public address (network call, explicit opt-in)
function myip() {
  if [[ "$1" == "--public" ]]; then
    curl -s https://ipinfo.io/ip
    print
    return
  fi

  if command -v ipconfig >/dev/null; then
    ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null
  elif command -v ip >/dev/null; then
    ip -4 -o addr show scope global | awk '{print $4}' | cut -d/ -f1 | head -1
  else
    print "myip: no supported IP lookup tool found" >&2
    return 1
  fi
}

# ============================================================================ #
# Environment Detection
# ============================================================================ #

# These variables should be set in your .env file:
# IS_HOME, IS_OFFICE, IS_SERVER

function determine-environment() {
  if [[ $IS_HOME == true ]]; then
    echo "home-macos"
  elif [[ $IS_OFFICE == true ]]; then
    echo "office-macos"
  elif [[ $IS_OFFICE == true || $IS_DOCKER == true ]]; then
    echo "docker-dev"
  elif [[ $IS_SERVER == true ]]; then
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

# ============================================================================ #
# Compilation flags
# ============================================================================ #

# detect and set architecture
if [[ $(uname -m) == "arm64" ]]; then
  export ARCHFLAGS="-arch arm64"
else
  export ARCHFLAGS="-arch x86_64"
fi
