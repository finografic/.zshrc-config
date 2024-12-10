#!/bin/zsh

# Load environment variables
if [[ -f "$HOME/.zshrc-config/.env" ]]; then
  source "$HOME/.zshrc-config/.env"
else
  echo "Warning: .env file not found in ~/.zshrc-config/"
fi

# VSCode memory allocation
export NODE_OPTIONS="$NODE_OPTIONS --max_old_space_size=4096"

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
