# ============================================================================ #
# DISKSPACE
# ============================================================================ #

# GET DISK USAGE
function _du() {
  # If no argument: run default (sudo) summary for current dir
  if [[ -z "$1" ]]; then
    sudo du -hd .
    return 0
  fi

  # If a positive integer depth is provided: run without sudo using that depth
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    du -h -d "$1" .
    return 0
  fi

  # Fallback: treat argument as a path and show sudo'd human-readable sizes
  sudo du -hd "$1"
}

# DISK SPACE -- PERFORMS *FULL* DISK SCAN
function _du-scan() {
  ncdu
}

function diskspace-df-with-temps() {
  echo "\n\e[36m$(df -H -ai | grep "" --max-count 1)\e[0m"
  df -H -ai | sed -n '1!p'
}

function space() {
  if [[ "$OS_NAME" == "Linux" ]]; then
    echo "\n"
    # LIST IMPORTANT DRIVES, IGNORE TMPS AND SNAPS etc..
    df -h -x "squashfs" -x "devtmpfs"
  elif [[ "$OS_NAME" == "macOS" ]]; then
    # LIST IMPORTANT DRIVES ONLY
    # HEADERS (CYAN)
    echo "\n\e[36m$(df -b -H -ailn | grep "" --max-count 1)\e[0m"
    df -b -H -ailn | grep "/Volumes/.timemachine" -v | grep "/Volumes/.com.apple.*" -v | sed -n '1!p'
  else
    # Android / default — LIST IMPORTANT DRIVES ONLY
    # HEADERS (CYAN)
    echo "\n\e[36m$(df -H -ai | grep "" --max-count 1)\e[0m"
    df -H -ai | sed -n '1!p'
  fi
}
