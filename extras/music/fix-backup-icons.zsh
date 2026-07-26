#!/bin/zsh

# Fix Backup Icons Script
# This script applies custom folder icons to the backup directories

# Source colors
source "${ZSHRC_ROOT:-$HOME/.zshrc-config}/lib/colors.zsh"

# Configuration
BACKUP_ROOT="/Volumes/timemachine-music/_DJ-CRATE backups"
LATEST_BACKUP=$(ls -t "$BACKUP_ROOT" | grep "^2025-" | head -1)
BACKUP_PATH="$BACKUP_ROOT/$LATEST_BACKUP"

echo -e "${_m}🎨 Fixing Custom Folder Icons in Backup${_0}"
echo -e "${_c}📁 Backup path: $BACKUP_PATH${_0}\n"

if [[ ! -d "$BACKUP_PATH" ]]; then
    echo -e "${_r}❌ Backup directory not found: $BACKUP_PATH${_0}"
    exit 1
fi

# Find all Icon? files and apply them to their parent folders
find "$BACKUP_PATH" -name "Icon?" -type f | while read -r icon_file; do
    parent_dir=$(dirname "$icon_file")
    parent_name=$(basename "$parent_dir")

    echo -e "${_y}🔧 Processing: $parent_name${_0}"

    # Set the custom icon attribute on the parent folder
    if SetFile -a C "$parent_dir" 2>/dev/null; then
        echo -e "  ${_g}✅ Applied custom icon to: $parent_name${_0}"
    else
        echo -e "  ${_r}❌ Failed to apply icon to: $parent_name${_0}"
    fi
done

echo -e "\n${_g}🎉 Icon fix completed!${_0}"
echo -e "${_c}💡 You may need to refresh Finder (Cmd+R) to see the changes${_0}"
echo -e "${_c}💡 Or restart Finder if the icons don't appear immediately${_0}"
