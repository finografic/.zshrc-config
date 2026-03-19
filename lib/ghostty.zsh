########################################
###  GHOSTTY  ##########################
########################################

GHOSTTY_CONFIG_FILE_PATH="$HOME/Library/Application Support/com.mitchellh.ghostty/config"

update_ghostty_config() {
  cp -a "$ZSHRC_ROOT/configs/ghostty.config" "$GHOSTTY_CONFIG_FILE_PATH"
}

_config() {
  update_ghostty_config
  osascript -e 'tell application "System Events" to keystroke "," using {command down, shift down}'
  # osascript -e 'tell application "Ghostty" to activate' -e 'tell application "System Events" to keystroke "," using {command down, shift down}'
}
