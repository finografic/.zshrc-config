# ============================================================================ #
# FUNCTIONS + ALIASES
# ============================================================================ #

# Colors and emoji
# source "$ZSHRC_ROOT/lib/colors.zsh"

# ============================================================================ #

function show-tmutil-snapshots() {
  # TMUTIL LOCAL SNAPSHOTS WIDGET
  if command -v tmutil &>/dev/null; then
    # Count snapshots
    TM_SNAPSHOTS=( $(tmutil listlocalsnapshots / | grep -Eo 'com.apple.TimeMachine.[0-9\-]+' | sort) )
    TM_COUNT=${#TM_SNAPSHOTS[@]}

    # Set status and colors based on count
    if [[ $TM_COUNT -gt 0 ]]; then
      TM_STATUS="active"
      TM_COLOR="${_c}"  # Blue for active
      STATUS_COLOR="${_g}"  # Green for status
    else
      TM_STATUS="inactive"
      TM_COLOR="${_grey}"  # Grey for inactive
      STATUS_COLOR="${_grey}"  # Grey for status
    fi

    echo "${TM_COLOR}🕰️ Time Machine Snapshots:${_0} ${STATUS_COLOR}$TM_COUNT${_0} ${STATUS_COLOR}$TM_STATUS${_0}\n"
  fi
}

# ============================================================================ #

function show-custom-launch-agents() {
  if [[ -d ~/Library/LaunchAgents ]]; then
    # Create array using find with multiple patterns
    CUSTOM_AGENTS=($(find ~/Library/LaunchAgents -name "com.user.tmutil.plist" -o -name "com.user.dj-crate-backup.plist" -o -name "com.user.dj-crate-backup.plist"))

    if [[ ${#CUSTOM_AGENTS[@]} -gt 0 ]]; then
      echo "${_g}🚀 Custom Launch Agents:${_0}"
      for plist in "${CUSTOM_AGENTS[@]}"; do
        label=$(defaults read "${plist%.plist}" Label 2>/dev/null)
        agent_status=$(launchctl list | grep "$label")
        if [[ -n "$agent_status" ]]; then
          echo " ${_y}•${_0} ${_w}$label${_0}: ${_g}running${_0}"
        else
          echo " ${_y}•${_0} ${_w}$label${_0}: ${_r}not loaded${_0}"
        fi
      done
      echo "\n"
    fi
  fi
}

# ============================================================================ #
# LIST PORTS - localhost listeners (macOS, Linux, Android)
# ============================================================================ #

function show-ports() {
  if [[ "$OS_NAME" == "Linux" && "$ZENV" != "server-linux" ]]; then
    ports
  elif [[ "$OS_NAME" == "macOS" ]]; then
    ports
  elif [[ "$OS_NAME" == "Android" ]]; then
    ports 2>/dev/null
  fi
  echo "\n"
}

# ============================================================================ #
# DOCKER CONTAINERS WIDGET
# ============================================================================ #

function show-docker-containers() {
  if command -v docker &>/dev/null && docker info &>/dev/null 2>/dev/null; then
    RUNNING_CONTAINERS=$(docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}" 2>/dev/null | tail -n +2)
    if [[ -n "$RUNNING_CONTAINERS" ]]; then
      echo "${_c}🐳 Docker Containers:${_0}"
      echo "$RUNNING_CONTAINERS" | while IFS=$'\t' read -r name status image; do
        echo "  ${_y}•${_0} ${_w}$name${_0} (${_g}$status${_0}) - ${_b}$image${_0}"
      done
    fi
  fi
}

# ============================================================================ #
# SPLASH SCREEN - FASTFETCH or NEOFETCH, based on SYSTEM ARCHITECTURE
# ============================================================================ #

function show-splash-neofetch() {
  if command -v fastfetch >/dev/null; then
    fastfetch
  elif command -v neofetch >/dev/null; then
    neofetch
  else
    echo "${_c:-}${OS_NAME:-$(uname -s)} · ${ZENV:-unknown}${_0:-}"
    echo "install fastfetch or neofetch for a richer splash: scripts/setup/install-tools.zsh"
  fi
}

# ============================================================================ #
# SPLASH SCREEN BANNER
# ============================================================================ #

function show-splash-sys-banner() {
  source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.banner.zsh"
}

# ============================================================================ #
# SPLASH SCREEN FOOTER INFO
# ============================================================================ #

function show-splash-sys-banner-footer-info() {
  D="${_c}::${_0}"
  RESET_STRING="$HOSTNAME $D ${_w}$(myip)"
  echo "\n${_c} ---=====${_w} $RESET_STRING ${_c}=====--- \n"
}

# ============================================================================ #
# SPLASH SCREEN VERSIONS + OS INFO
# ============================================================================ #

# versions of macOS, NodeJS, npm... etc

function show-os-version-and-sys-info() {
  echo "${_y}$OS_NAME \t $([[ $OS != "Android" ]] && echo "$OS_VERSION") $([[ $OS = "Linux" ]] && echo $OS_KERNEL)"
  [ -e /etc/os-release ] && echo "${_y}$(env -i bash -c '. /etc/os-release; echo $PRETTY_NAME')"
  echo "${_c}NodeJS \t$(node --version)"
  # Prefer pnpm to avoid npm warnings for pnpm-specific .npmrc options (node-linker, hoist-workspace-packages)
  if command -v pnpm >/dev/null; then
    echo "${_c}pnpm \tv$(pnpm --version)\n${_0}"
  else
    echo "${_c}npm \tv$(npm --version)\n${_0}"
  fi
}
