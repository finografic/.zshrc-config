#!/bin/zsh

# djay Pro Playlist Sync Script
# This script syncs the djay Media Library between two Macs
# Usage: ./djay_sync.zsh [source_mac_name] [destination_mac_name]

# Source colors
source ~/.zshrc-config/lib/colors.zsh

# Configuration
DJAY_PATH="$HOME/Music/djay"
LIBRARY_FILE="djay Media Library.djayMediaLibrary"
BACKUP_DIR="$HOME/Documents/djay_backups"
LOG_FILE="$HOME/Documents/djay_sync.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to create backup
create_backup() {
    local source_file="$1"
    local backup_name="djay_backup_$(date '+%Y%m%d_%H%M%S').djayMediaLibrary"

    if [[ -f "$source_file" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp "$source_file" "$BACKUP_DIR/$backup_name"
        log_message "Backup created: $backup_name"
        echo -e "${_c}💾 Backup created: $backup_name${_0}"
    fi
}

# Function to sync files
sync_djay_files() {
    local source="$1"
    local destination="$2"

    log_message "Starting sync from $source to $destination"
    echo -e "${_m}🔄 Starting sync from $source to $destination${_0}"

    # Create backup of destination before sync
    if [[ -e "$destination/$LIBRARY_FILE" ]]; then
        create_backup "$destination/$LIBRARY_FILE"
    fi

    # Sync the library file/directory
    if rsync -av --update "$source/$LIBRARY_FILE" "$destination/$LIBRARY_FILE"; then
        log_message "Library file synced successfully"
        echo -e "${_g}✅ Library file synced successfully${_0}"
    else
        log_message "ERROR: Failed to sync library file"
        echo -e "${_r}❌ Failed to sync library file${_0}"
        return 1
    fi

    # Sync other folders (optional)
    for folder in "Key Bindings" "MIDI Mappings"; do
        if [[ -d "$source/$folder" ]]; then
            if rsync -av --delete "$source/$folder/" "$destination/$folder/"; then
                log_message "Folder '$folder' synced successfully"
                echo -e "${_g}✅ $folder synced successfully${_0}"
            else
                log_message "WARNING: Failed to sync folder '$folder'"
                echo -e "${_y}⚠️  Failed to sync folder '$folder'${_0}"
            fi
        fi
    done

    log_message "Sync completed"
    echo -e "${_g}✅ Sync completed${_0}\n"
}

# Main script
main() {
    log_message "=== djay Pro Sync Started ==="
    echo -e "${_m}🎵 djay Pro Sync Started${_0}\n"

    # Check if djay is running
    if pgrep -x "djay" > /dev/null; then
        log_message "WARNING: djay Pro is running. Please quit djay Pro before syncing."
        echo -e "${_y}⚠️  djay Pro is running${_0}"
        echo -e "${_y}⚠️  Please quit djay Pro and run this script again${_0}\n"
        exit 1
    fi

    # Check if source directory exists
    if [[ ! -d "$DJAY_PATH" ]]; then
        log_message "ERROR: djay directory not found at $DJAY_PATH"
        echo -e "${_r}❌ djay directory not found at $DJAY_PATH${_0}"
        echo -e "${_y}⚠️  Please check the path${_0}\n"
        exit 1
    fi

    # Check if library file exists
    if [[ ! -e "$DJAY_PATH/$LIBRARY_FILE" ]]; then
        log_message "ERROR: Library file not found at $DJAY_PATH/$LIBRARY_FILE"
        echo -e "${_r}❌ Library file not found at $DJAY_PATH/$LIBRARY_FILE${_0}"
        echo -e "${_y}⚠️  Please check if djay Pro has been used${_0}\n"
        exit 1
    fi

    # Get file modification time
    local_mod_time=$(stat -f "%m" "$DJAY_PATH/$LIBRARY_FILE")
    log_message "Local library file modification time: $(date -r $local_mod_time)"

    # Show the current state
    echo -e "${_g}📊 Current djay Pro library file:${_0}"
    echo "  📍 Path: $DJAY_PATH/$LIBRARY_FILE"
    echo "  📏 Size: $(du -sh "$DJAY_PATH/$LIBRARY_FILE" | cut -f1)"
    echo "  📅 Modified: $(date -r $local_mod_time)"
    echo ""

    # TODO: Add remote sync logic here
    # This would require setting up SSH keys between Macs or using a cloud service
    echo -e "${_c}💡 TODO: Add remote sync logic here${_0}"
    echo -e "${_c}💡 This would require setting up SSH keys between Macs or using a cloud service${_0}"

    log_message "=== djay Pro Sync Completed ==="
    echo -e "\n${_g}✅ djay Pro Sync Completed${_0}\n"
}

# Show help if no arguments or help requested
if [[ $# -eq 0 || "$1" == "help" || "$1" == "--help" || "$1" == "-h" ]]; then
    echo -e "${_m}🎵 djay Pro Basic Sync - Help${_0}\n"
    echo "Usage: $0 [source_mac_name] [destination_mac_name]"
    echo ""
    echo -e "${_g}Description:${_0}"
    echo "  This script syncs djay Pro files between two Macs"
    echo "  Currently shows local file information only"
    echo ""
    echo -e "${_c}Examples:${_0}"
    echo "  $0                    # Show current file info"
    echo "  $0 help              # Show this help message"
    echo "  $0 mac1 mac2         # Sync from mac1 to mac2 (TODO)"
    echo ""
    echo -e "${_y}Note:${_0} Remote sync functionality needs to be implemented"
    echo ""
    exit 0
fi

# Run main function
main "$@"
