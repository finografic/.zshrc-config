#!/bin/zsh

# ========================================================================= #
# vsclean - clear VSCode caches and temp files
# ========================================================================= #

# Reset and colors (ANSI)
_0="\033[0m"     # Reset all colors and styles
_w="\033[37m"    # White
_g="\033[32m"    # Green
_y="\033[33m"    # Yellow
_r="\033[31m"    # Red

vsclean() {
  local CODE_PATH="Code"

  echo "\n${_w}Cache Locations:${_0}"
  echo "${_y}1. Code Storage ${_w}- Clears user settings and state files${_0}"
  echo "${_y}2. Cache files ${_w}- Removes temporary data and cached resources${_0}"
  echo "${_y}3. Crash Reports ${_w}- Cleans up crash logs and diagnostics${_0}"
  echo "${_y}4. Workbench State ${_w}- Resets workspace-specific settings${_0}"

  echo "\n${_r}⚠️  Which VSCode cache(s) would you like to clear? ${_w}(1-4, A for ALL, Enter to cancel)${_0}\n"
  read -r response
  response=${response:-N}

  case $response in
  1)
    rm -rf ~/Library/Application\ Support/${CODE_PATH}/User/globalStorage/*
    echo "\n${_g}✅ Code Storage cleared${_0}\n"
    ;;
  2)
    rm -rf ~/Library/Application\ Support/${CODE_PATH}/Cache/*
    rm -rf ~/Library/Application\ Support/${CODE_PATH}/CachedData/*
    echo "\n${_g}✅ Cache files cleared${_0}\n"
    ;;
  3)
    rm -rf ~/Library/Application\ Support/${CODE_PATH}/Crashpad/*
    echo "\n${_g}✅ Crash reports cleared${_0}\n"
    ;;
  4)
    rm -rf ~/Library/Application\ Support/${CODE_PATH}/User/workspaceStorage/*
    echo "\n${_g}✅ Workbench state cleared${_0}\n"
    ;;
  [Aa])
    echo "\n${_r}⚠️  This will clear ALL caches! Continue? ${_w}(y/N)${_0}\n"
    read -r confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      rm -rf ~/Library/Application\ Support/${CODE_PATH}/User/globalStorage/*
      rm -rf ~/Library/Application\ Support/${CODE_PATH}/Cache/*
      rm -rf ~/Library/Application\ Support/${CODE_PATH}/CachedData/*
      rm -rf ~/Library/Application\ Support/${CODE_PATH}/Crashpad/*
      rm -rf ~/Library/Application\ Support/${CODE_PATH}/User/workspaceStorage/*
      echo "\n${_g}✅ All caches cleared${_0}"
    else
      echo "\n${_y}Operation aborted${_0}\n"
    fi
    ;;
  *)
    echo "\n${_y}Operation aborted${_0}\n"
    ;;
  esac

  echo "${_w}It's recommended to restart VSCode after clearing caches${_0}\n"
}

# NOTE: ⚠️comment this line if you wish to use add funciton to profile, and NOT run it automatically.
vsclean