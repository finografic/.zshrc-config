#!/bin/bash

# Define paths
PREFERRED_THEME="$ZSHRC_ROOT/themes/gallois-custom.zsh-theme"
ANTIDOTE_THEME="$HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh/themes/gallois.zsh-theme"
BACKUP_DIR="$HOME/.zsh-theme-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup current theme if it exists
if [ -f "$ANTIDOTE_THEME" ]; then
  echo "Backing up current theme to $BACKUP_DIR/gallois-custom.zsh-theme.$TIMESTAMP"
  cp "$ANTIDOTE_THEME" "$BACKUP_DIR/gallois-custom.zsh-theme.$TIMESTAMP"
fi

# Copy preferred theme
if [ -f "$PREFERRED_THEME" ]; then
  echo "Restoring preferred theme from $PREFERRED_THEME"
  cp "$PREFERRED_THEME" "$ANTIDOTE_THEME"
  echo "Theme restored successfully!"
  echo "Reloading shell..."
  exec zsh
else
  echo "Error: Preferred theme not found at $PREFERRED_THEME"
  exit 1
fi
