#!/bin/bash

# djay Pro Playlist Sync Script
# This script syncs the djay Media Library between two Macs
# Usage: ./djay_sync.sh [source_mac_name] [destination_mac_name]

# Configuration
DJAY_PATH="$HOME/Music/djay"
LIBRARY_FILE="djay Media Library.djayMediaLibrary"
BACKUP_DIR="$HOME/Documents/djay_backups"
LOG_FILE="$HOME/Documents/djay_sync.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to create backup
create_backup() {
    local source_file="$1"
    local backup_name="djay_backup_$(date '+%Y%m%d_%H%M%S').djayMediaLibrary"

    if [ -f "$source_file" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$source_file" "$BACKUP_DIR/$backup_name"
        log_message "Backup created: $backup_name"
    fi
}

# Function to sync files
sync_djay_files() {
    local source="$1"
    local destination="$2"

    log_message "Starting sync from $source to $destination"

    # Create backup of destination before sync
    if [ -e "$destination/$LIBRARY_FILE" ]; then
        create_backup "$destination/$LIBRARY_FILE"
    fi

    # Sync the library file/directory
    if rsync -av --update "$source/$LIBRARY_FILE" "$destination/$LIBRARY_FILE"; then
        log_message "Library file synced successfully"
    else
        log_message "ERROR: Failed to sync library file"
        return 1
    fi

    # Sync other folders (optional)
    for folder in "Key Bindings" "MIDI Mappings"; do
        if [ -d "$source/$folder" ]; then
            if rsync -av --delete "$source/$folder/" "$destination/$folder/"; then
                log_message "Folder '$folder' synced successfully"
            else
                log_message "WARNING: Failed to sync folder '$folder'"
            fi
        fi
    done

    log_message "Sync completed"
}

# Main script
main() {
    log_message "=== djay Pro Sync Started ==="

    # Check if djay is running
    if pgrep -x "djay" > /dev/null; then
        log_message "WARNING: djay Pro is running. Please quit djay Pro before syncing."
        echo -e "${YELLOW}Please quit djay Pro and run this script again.${NC}"
        exit 1
    fi

    # Check if source directory exists
    if [ ! -d "$DJAY_PATH" ]; then
        log_message "ERROR: djay directory not found at $DJAY_PATH"
        echo -e "${RED}djay directory not found. Please check the path.${NC}"
        exit 1
    fi

    # Check if library file exists
    if [ ! -e "$DJAY_PATH/$LIBRARY_FILE" ]; then
        log_message "ERROR: Library file not found at $DJAY_PATH/$LIBRARY_FILE"
        echo -e "${RED}Library file not found. Please check if djay Pro has been used.${NC}"
        exit 1
    fi

    # Get file modification time
    local_mod_time=$(stat -f "%m" "$DJAY_PATH/$LIBRARY_FILE")
    log_message "Local library file modification time: $(date -r $local_mod_time)"

    # For now, just show the current state
    echo -e "${GREEN}Current djay Pro library file:${NC}"
    echo "Path: $DJAY_PATH/$LIBRARY_FILE"
    echo "Size: $(du -sh "$DJAY_PATH/$LIBRARY_FILE" | cut -f1)"
    echo "Modified: $(date -r $local_mod_time)"

    # TODO: Add remote sync logic here
    # This would require setting up SSH keys between Macs or using a cloud service

    log_message "=== djay Pro Sync Completed ==="
}

# Run main function
main "$@"
