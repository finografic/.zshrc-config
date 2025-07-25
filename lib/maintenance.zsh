# ========================================================================= #
# MAINTENANCE OPERATIONS
# ========================================================================= #
# Clear VSCode caches and temp files

vsclean() {
  echo "\n${_grey}Select VSCode variant:${_0}"
  echo "${_y}1. VSCode Insiders ${_grey}(default)${_0}"
  echo "${_y}2. VSCode Stable${_0}"

  echo "\n${_grey}Which variant? ${_grey}(1-2, Enter for Insiders)${_0}"
  read -r variant
  variant=${variant:-1}

  # Set the base path according to variant
  local CODE_PATH
  case $variant in
  1)
    CODE_PATH="Code - Insiders"
    echo "\n${_grey}Target: ${_y}VSCode Insiders${_0}"
    ;;
  2)
    CODE_PATH="Code"
    echo "\n${_grey}Target: ${_y}VSCode Stable${_0}"
    ;;
  *)
    echo "\n${_y}Invalid selection, defaulting to Insiders${_0}"
    CODE_PATH="Code - Insiders"
    ;;
  esac

  echo "\n${_grey}Cache Locations:${_0}"
  echo "${_y}1. Code Storage ${_grey}- Clears user settings and state files${_0}"
  echo "${_y}2. Cache files ${_grey}- Removes temporary data and cached resources${_0}"
  echo "${_y}3. Crash Reports ${_grey}- Cleans up crash logs and diagnostics${_0}"
  echo "${_y}4. Workbench State ${_grey}- Resets workspace-specific settings${_0}"
  # echo "${_y}5. Extensions ${_grey}- Removes ALL installed extensions (requires reinstall)${_0}"

  # echo "\n${_r}⚠️  Which cache would you like to clear? ${_grey}(1-5, A for ALL, Enter to cancel)${_0}\n"
  echo "\n${_r}⚠️  Which cache would you like to clear? ${_grey}(1-4, A for ALL, Enter to cancel)${_0}\n"
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
  # 5)
  #   rm -rf ~/.${CODE_PATH}/extensions/*
  #   echo "\n${_g}✅ Extensions cleared${_0}\n"
  #   echo "${_y}⚠️  You'll need to reinstall your extensions${_0}\n"
  #   ;;
  [Aa])
    echo "\n${_r}⚠️  This will clear ALL caches and extensions! Continue? ${_grey}(y/N)${_0}\n"
    read -r confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      rm -rf ~/Library/Application\ Support/${CODE_PATH}/User/globalStorage/*
      rm -rf ~/Library/Application\ Support/${CODE_PATH}/Cache/*
      rm -rf ~/Library/Application\ Support/${CODE_PATH}/CachedData/*
      rm -rf ~/Library/Application\ Support/${CODE_PATH}/Crashpad/*
      rm -rf ~/Library/Application\ Support/${CODE_PATH}/User/workspaceStorage/*
      rm -rf ~/.${CODE_PATH}/extensions/*
      echo "\n${_g}✅ All caches cleared${_0}"
      echo "${_y}⚠️  You'll need to reinstall your extensions${_0}\n"
    else
      echo "\n${_y}Operation aborted${_0}\n"
    fi
    ;;
  *)
    echo "\n${_y}Operation aborted${_0}\n"
    ;;
  esac

  echo "${_grey}It's recommended to restart ${CODE_PATH} after clearing caches${_0}\n"
}
