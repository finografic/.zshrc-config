# ============================================================================ #
# GHOSTTY
# ============================================================================ #

GHOSTTY_CONFIG_FILE_PATH="$HOME/Library/Application Support/com.mitchellh.ghostty/config"

# Resolves which tracked ghostty config this environment should use.
function ghostty-config-source() {
  if [[ "$ZENV" == "office-macos" && -f "$ZSHRC_ROOT/configs/ghostty.config.office" ]]; then
    print "$ZSHRC_ROOT/configs/ghostty.config.office"
  else
    print "$ZSHRC_ROOT/configs/ghostty.config"
  fi
}

# Copies the tracked config into place, but only when the tracked file is newer
# than the installed one. This used to run unconditionally at profile load; the
# `-nt` test is a zsh builtin, so the no-op path costs no subprocess.
# Pass --force to copy regardless.
function update-ghostty-config() {
  local src force=false
  [[ "$1" == "--force" ]] && force=true
  src="$(ghostty-config-source)"

  [[ -f "$src" ]] || return 0

  if [[ "$force" == false && -f "$GHOSTTY_CONFIG_FILE_PATH" && ! "$src" -nt "$GHOSTTY_CONFIG_FILE_PATH" ]]; then
    return 0
  fi

  mkdir -p "${GHOSTTY_CONFIG_FILE_PATH:h}"
  cp -a "$src" "$GHOSTTY_CONFIG_FILE_PATH"
}

function _config() {
  update-ghostty-config --force
  osascript -e 'tell application "System Events" to keystroke "," using {command down, shift down}'
  # osascript -e 'tell application "Ghostty" to activate' -e 'tell application "System Events" to keystroke "," using {command down, shift down}'
}
