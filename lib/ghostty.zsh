# ============================================================================ #
# GHOSTTY
# ============================================================================ #

GHOSTTY_CONFIG_FILE_PATH="$HOME/Library/Application Support/com.mitchellh.ghostty/config"

function update-ghostty-config() {
  # VSCode aliases (macOS specific)
  if [[ "$ZENV" = "office-macos" ]]; then
    cp -a "$ZSHRC_ROOT/configs/ghostty.config.office" "$GHOSTTY_CONFIG_FILE_PATH"
    return 0;
  fi

  cp -a "$ZSHRC_ROOT/configs/ghostty.config" "$GHOSTTY_CONFIG_FILE_PATH"
}

function _config() {
  update-ghostty-config
  osascript -e 'tell application "System Events" to keystroke "," using {command down, shift down}'
  # osascript -e 'tell application "Ghostty" to activate' -e 'tell application "System Events" to keystroke "," using {command down, shift down}'
}
