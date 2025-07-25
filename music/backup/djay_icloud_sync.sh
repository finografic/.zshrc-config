#!/bin/bash

# djay Pro iCloud Sync Script
# This script syncs djay Pro files using iCloud Drive
# Based on the iCloud Drive structure shown in the user's screenshots

# Configuration
DJAY_PATH="$HOME/Music/djay"
ICLOUD_DJAY_PATH="$HOME/Library/Mobile Documents/com~apple~CloudDocs/djay"
LIBRARY_FILE="djay Media Library.djayMediaLibrary"
LOG_FILE="$HOME/Documents/djay_icloud_sync.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check if iCloud Drive is available
check_icloud_drive() {
    if [ ! -d "$HOME/Library/Mobile Documents/com~apple~CloudDocs" ]; then
        log_message "ERROR: iCloud Drive not found"
        echo -e "${RED}iCloud Drive not found. Please enable iCloud Drive in System Preferences.${NC}"
        return 1
    fi
    return 0
}

# Function to create iCloud djay directory
create_icloud_djay_dir() {
    if [ ! -d "$ICLOUD_DJAY_PATH" ]; then
        log_message "Creating iCloud djay directory"
        mkdir -p "$ICLOUD_DJAY_PATH"
        mkdir -p "$ICLOUD_DJAY_PATH/Key Bindings"
        mkdir -p "$ICLOUD_DJAY_PATH/MIDI Mappings"
    fi
}

# Function to get file/directory modification time
get_file_time() {
    local file="$1"
    if [ -e "$file" ]; then
        stat -f "%m" "$file"
    else
        echo "0"
    fi
}

# Function to sync files to iCloud
sync_to_icloud() {
    log_message "Syncing djay files to iCloud Drive"

    # Sync library file/directory
    if [ -e "$DJAY_PATH/$LIBRARY_FILE" ]; then
        local_time=$(get_file_time "$DJAY_PATH/$LIBRARY_FILE")
        icloud_time=$(get_file_time "$ICLOUD_DJAY_PATH/$LIBRARY_FILE")

        if [ $local_time -gt $icloud_time ]; then
            log_message "Local library file is newer, copying to iCloud"
            cp -R "$DJAY_PATH/$LIBRARY_FILE" "$ICLOUD_DJAY_PATH/"
        else
            log_message "iCloud library file is newer or same age"
        fi
    else
        log_message "WARNING: Local library file not found"
    fi

    # Sync folders
    for folder in "Key Bindings" "MIDI Mappings"; do
        if [ -d "$DJAY_PATH/$folder" ]; then
            log_message "Syncing folder: $folder"
            rsync -av --delete "$DJAY_PATH/$folder/" "$ICLOUD_DJAY_PATH/$folder/"
        fi
    done
}

# Function to sync files from iCloud
sync_from_icloud() {
    log_message "Syncing djay files from iCloud Drive"

    # Check if djay is running
    if pgrep -x "djay" > /dev/null; then
        log_message "WARNING: djay Pro is running. Please quit djay Pro before syncing."
        echo -e "${YELLOW}Please quit djay Pro and run this script again.${NC}"
        return 1
    fi

    # Sync library file/directory
    if [ -e "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" ]; then
        local_time=$(get_file_time "$DJAY_PATH/$LIBRARY_FILE")
        icloud_time=$(get_file_time "$ICLOUD_DJAY_PATH/$LIBRARY_FILE")

        if [ $icloud_time -gt $local_time ]; then
            log_message "iCloud library file is newer, copying to local"
            # Create backup first
            if [ -e "$DJAY_PATH/$LIBRARY_FILE" ]; then
                backup_file="$HOME/Documents/djay_backup_$(date '+%Y%m%d_%H%M%S').djayMediaLibrary"
                cp -R "$DJAY_PATH/$LIBRARY_FILE" "$backup_file"
                log_message "Backup created: $backup_file"
            fi
            cp -R "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" "$DJAY_PATH/"
        else
            log_message "Local library file is newer or same age"
        fi
    else
        log_message "WARNING: iCloud library file not found"
    fi

    # Sync folders
    for folder in "Key Bindings" "MIDI Mappings"; do
        if [ -d "$ICLOUD_DJAY_PATH/$folder" ]; then
            log_message "Syncing folder: $folder"
            rsync -av --delete "$ICLOUD_DJAY_PATH/$folder/" "$DJAY_PATH/$folder/"
        fi
    done
}

# Function to show sync status
show_status() {
    echo -e "${BLUE}=== djay Pro iCloud Sync Status ===${NC}"

    # Local files
    echo -e "${GREEN}Local djay directory:${NC}"
    if [ -d "$DJAY_PATH" ]; then
        echo "  Path: $DJAY_PATH"
        if [ -e "$DJAY_PATH/$LIBRARY_FILE" ]; then
            local_time=$(get_file_time "$DJAY_PATH/$LIBRARY_FILE")
            echo "  Library file: $(date -r $local_time)"
            echo "  Size: $(du -sh "$DJAY_PATH/$LIBRARY_FILE" | cut -f1)"
        else
            echo "  Library file: Not found"
        fi
    else
        echo "  Directory: Not found"
    fi

    # iCloud files
    echo -e "${GREEN}iCloud djay directory:${NC}"
    if [ -d "$ICLOUD_DJAY_PATH" ]; then
        echo "  Path: $ICLOUD_DJAY_PATH"
        if [ -e "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" ]; then
            icloud_time=$(get_file_time "$ICLOUD_DJAY_PATH/$LIBRARY_FILE")
            echo "  Library file: $(date -r $icloud_time)"
            echo "  Size: $(du -sh "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" | cut -f1)"
        else
            echo "  Library file: Not found"
        fi
    else
        echo "  Directory: Not found"
    fi

    # Compare timestamps
    if [ -e "$DJAY_PATH/$LIBRARY_FILE" ] && [ -e "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" ]; then
        local_time=$(get_file_time "$DJAY_PATH/$LIBRARY_FILE")
        icloud_time=$(get_file_time "$ICLOUD_DJAY_PATH/$LIBRARY_FILE")

        echo -e "${GREEN}Sync status:${NC}"
        if [ $local_time -gt $icloud_time ]; then
            echo "  Local file is newer (needs upload to iCloud)"
        elif [ $icloud_time -gt $local_time ]; then
            echo "  iCloud file is newer (needs download to local)"
        else
            echo "  Files are in sync"
        fi
    fi
}

# Function to setup automatic sync
setup_automatic_sync() {
    log_message "Setting up automatic sync"

    # Create launch agent plist
    local plist_dir="$HOME/Library/LaunchAgents"
    local plist_file="$plist_dir/com.user.djay-sync.plist"

    mkdir -p "$plist_dir"

    cat > "$plist_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.djay-sync</string>
    <key>ProgramArguments</key>
    <array>
        <string>$(which bash)</string>
        <string>$(pwd)/$0</string>
        <string>auto</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$LOG_FILE</string>
    <key>StandardErrorPath</key>
    <string>$LOG_FILE</string>
</dict>
</plist>
EOF

    # Load the launch agent
    launchctl load "$plist_file"
    log_message "Automatic sync setup complete. Will run every 5 minutes."
}

# Function to stop automatic sync
stop_automatic_sync() {
    local plist_file="$HOME/Library/LaunchAgents/com.user.djay-sync.plist"

    if [ -f "$plist_file" ]; then
        launchctl unload "$plist_file"
        rm "$plist_file"
        log_message "Automatic sync stopped and removed"
        echo -e "${GREEN}Automatic sync stopped and removed${NC}"
    else
        log_message "No automatic sync found to stop"
        echo -e "${YELLOW}No automatic sync found to stop${NC}"
    fi
}

# Function to check automatic sync status
check_automatic_sync() {
    local plist_file="$HOME/Library/LaunchAgents/com.user.djay-sync.plist"

    if [ -f "$plist_file" ]; then
        echo -e "${GREEN}Automatic sync is ENABLED${NC}"
        echo "  Plist file: $plist_file"
        echo "  Log file: $LOG_FILE"
        echo "  Interval: Every 5 minutes"

        # Check if it's currently loaded
        if launchctl list | grep -q "com.user.djay-sync"; then
            echo "  Status: Active and running"
        else
            echo "  Status: Not currently loaded"
        fi
    else
        echo -e "${YELLOW}Automatic sync is DISABLED${NC}"
        echo "  Run './djay_icloud_sync.sh setup-auto' to enable"
    fi
}

# Function to show recent log entries
show_recent_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo -e "${BLUE}=== Recent djay Sync Log Entries ===${NC}"
        echo "Log file: $LOG_FILE"
        echo ""
        tail -20 "$LOG_FILE"
    else
        echo -e "${YELLOW}No log file found at $LOG_FILE${NC}"
    fi
}

# Main script
main() {
    log_message "=== djay Pro iCloud Sync Started ==="

    # Check iCloud Drive
    if ! check_icloud_drive; then
        exit 1
    fi

    # Create iCloud directory if needed
    create_icloud_djay_dir

    # Sync both directions
    sync_to_icloud
    sync_from_icloud

    log_message "=== djay Pro iCloud Sync Completed ==="
}

# Parse command line arguments
case "${1:-sync}" in
    "sync")
        main
        ;;
    "to-icloud")
        check_icloud_drive && create_icloud_djay_dir && sync_to_icloud
        ;;
    "from-icloud")
        check_icloud_drive && sync_from_icloud
        ;;
    "status")
        show_status
        ;;
    "auto")
        main
        ;;
    "setup-auto")
        setup_automatic_sync
        ;;
    "stop-auto")
        stop_automatic_sync
        ;;
    "check-auto")
        check_automatic_sync
        ;;
    "logs")
        show_recent_logs
        ;;
    "help")
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  sync        - Sync both directions"
        echo "  to-icloud   - Sync local files to iCloud"
        echo "  from-icloud - Sync iCloud files to local"
        echo "  status      - Show sync status"
        echo "  setup-auto  - Setup automatic sync every 5 minutes"
        echo "  stop-auto   - Stop and remove automatic sync"
        echo "  check-auto  - Check if automatic sync is enabled and its status"
        echo "  logs        - Show recent log entries"
        echo "  help        - Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 sync        # Sync both directions"
        echo "  $0 status      # Check current sync status"
        echo "  $0 setup-auto  # Enable automatic sync"
        echo "  $0 logs        # View recent activity"
        ;;
    *)
        echo "Usage: $0 [sync|to-icloud|from-icloud|status|setup-auto|stop-auto|check-auto|logs|help]"
        echo "  sync        - Sync both directions"
        echo "  to-icloud   - Sync local files to iCloud"
        echo "  from-icloud - Sync iCloud files to local"
        echo "  status      - Show sync status"
        echo "  setup-auto  - Setup automatic sync every 5 minutes"
        echo "  stop-auto   - Stop and remove automatic sync"
        echo "  check-auto  - Check if automatic sync is enabled and its status"
        echo "  logs        - Show recent log entries"
        echo "  help        - Show detailed help"
        exit 1
        ;;
esac
