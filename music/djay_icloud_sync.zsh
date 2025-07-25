#!/bin/zsh

# djay Pro iCloud Sync Script
# This script syncs djay Pro files using iCloud Drive
# Based on the iCloud Drive structure shown in the user's screenshots

# Source colors (with fallback)
if [[ -f ~/.zshrc-config/lib/colors.zsh ]]; then
    source ~/.zshrc-config/lib/colors.zsh
else
    # Fallback color definitions if colors.zsh is not available
    export _m="\033[35m"  # Magenta
    export _g="\033[32m"  # Green
    export _c="\033[36m"  # Cyan
    export _y="\033[33m"  # Yellow
    export _r="\033[31m"  # Red
    export _0="\033[0m"   # Reset
fi

# Configuration
DJAY_PATH="$HOME/Music/djay"
ICLOUD_DJAY_PATH="$HOME/Library/Mobile Documents/com~apple~CloudDocs/djay"
LIBRARY_FILE="djay Media Library.djayMediaLibrary"
LOG_FILE="$HOME/Documents/djay_icloud_sync.log"

# Main djay command function
djay() {
    case "${1:-help}" in
        "sync")
            djay_icloud_sync_main
            ;;
        "status")
            show_status
            ;;
        "to-icloud")
            check_icloud_drive && create_icloud_djay_dir && sync_to_icloud
            ;;
        "from-icloud")
            check_icloud_drive && sync_from_icloud
            ;;
        "logs")
            show_recent_logs
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
        "help"|"--help"|"-h")
            echo -e "${_m}🎵 djay Pro Sync - Main Command${_0}\n"
            echo "Usage: djay [command]"
            echo ""
            echo -e "${_g}Commands:${_0}"
            echo "  sync        - Sync both directions"
            echo "  status      - Show sync status"
            echo "  to-icloud   - Upload to iCloud"
            echo "  from-icloud - Download from iCloud"
            echo "  logs        - Show recent logs"
            echo "  setup-auto  - Setup automatic sync"
            echo "  stop-auto   - Stop automatic sync"
            echo "  check-auto  - Check auto sync status"
            echo "  help        - Show this help"
            echo ""
            echo -e "${_c}Examples:${_0}"
            echo "  djay sync        # Sync both directions"
            echo "  djay status      # Check current status"
            echo "  djay to-icloud   # Upload to iCloud"
            echo "  djay logs        # View recent activity"
            echo ""
            ;;
        *)
            echo -e "${_r}❌ Unknown command: $1${_0}\n"
            echo "Use 'djay help' to see available commands"
            echo ""
            return 1
            ;;
    esac
}

# Convenient aliases (keeping for backward compatibility)
alias djay-sync='~/.zshrc-config/music/djay_icloud_sync.zsh'
alias djay-status='~/.zshrc-config/music/djay_icloud_sync.zsh status'
alias djay-to-icloud='~/.zshrc-config/music/djay_icloud_sync.zsh to-icloud'
alias djay-from-icloud='~/.zshrc-config/music/djay_icloud_sync.zsh from-icloud'
alias djay-logs='~/.zshrc-config/music/djay_icloud_sync.zsh logs'
alias djay-help='~/.zshrc-config/music/djay_icloud_sync.zsh help'

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check if iCloud Drive is available
check_icloud_drive() {
    if [[ ! -d "$HOME/Library/Mobile Documents/com~apple~CloudDocs" ]]; then
        log_message "ERROR: iCloud Drive not found"
        echo -e "\n${_r}❌ iCloud Drive not found${_0}"
        echo "${_y}⚠️  Please enable iCloud Drive in System Preferences > Apple ID > iCloud${_0}\n"
        return 1
    fi
    return 0
}

# Function to create iCloud djay directory
create_icloud_djay_dir() {
    if [[ ! -d "$ICLOUD_DJAY_PATH" ]]; then
        log_message "Creating iCloud djay directory"
        mkdir -p "$ICLOUD_DJAY_PATH"
        mkdir -p "$ICLOUD_DJAY_PATH/Key Bindings"
        mkdir -p "$ICLOUD_DJAY_PATH/MIDI Mappings"
        echo -e "${_g}📁 Created iCloud djay directory${_0}\n"
    fi
}

# Function to get file/directory modification time
get_file_time() {
    local file="$1"
    if [[ -e "$file" ]]; then
        stat -f "%m" "$file"
    else
        echo "0"
    fi
}

# Function to sync files to iCloud
sync_to_icloud() {
    log_message "Syncing djay files to iCloud Drive"
    echo -e "${_m}☁️  Syncing djay files to iCloud Drive...${_0}"

    # Sync library file/directory
    if [[ -e "$DJAY_PATH/$LIBRARY_FILE" ]]; then
        local_time=$(get_file_time "$DJAY_PATH/$LIBRARY_FILE")
        icloud_time=$(get_file_time "$ICLOUD_DJAY_PATH/$LIBRARY_FILE")

        if [[ $local_time -gt $icloud_time ]]; then
            log_message "Local library file is newer, copying to iCloud"
            echo -e "${_y}📤 Local library file is newer, copying to iCloud...${_0}"
            cp -R "$DJAY_PATH/$LIBRARY_FILE" "$ICLOUD_DJAY_PATH/"
            echo -e "${_g}✅ Library file copied to iCloud${_0}\n"
        else
            log_message "iCloud library file is newer or same age"
            echo -e "${_c}ℹ️  iCloud library file is newer or same age${_0}\n"
        fi
    else
        log_message "WARNING: Local library file not found"
        echo -e "${_y}⚠️  Local library file not found${_0}\n"
    fi

    # Sync folders
    for folder in "Key Bindings" "MIDI Mappings"; do
        if [[ -d "$DJAY_PATH/$folder" ]]; then
            log_message "Syncing folder: $folder"
            echo -e "${_m}📁 Syncing folder: ${_c}$folder${_0}"
            rsync -av --delete "$DJAY_PATH/$folder/" "$ICLOUD_DJAY_PATH/$folder/"
            echo -e "${_g}✅ $folder synced${_0}\n"
        fi
    done
}

# Function to sync files from iCloud
sync_from_icloud() {
    log_message "Syncing djay files from iCloud Drive"
    echo -e "${_m}⬇️  Syncing djay files from iCloud Drive...${_0}"

    # Check if djay is running
    if pgrep -x "djay" > /dev/null; then
        log_message "WARNING: djay Pro is running. Please quit djay Pro before syncing."
        echo -e "\n${_y}⚠️  djay Pro is running${_0}"
        echo "${_y}⚠️  Please quit djay Pro and run this script again${_0}\n"
        return 1
    fi

    # Sync library file/directory
    if [[ -e "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" ]]; then
        local_time=$(get_file_time "$DJAY_PATH/$LIBRARY_FILE")
        icloud_time=$(get_file_time "$ICLOUD_DJAY_PATH/$LIBRARY_FILE")

        if [[ $icloud_time -gt $local_time ]]; then
            log_message "iCloud library file is newer, copying to local"
            echo -e "${_y}📥 iCloud library file is newer, copying to local...${_0}"
            # Create backup first
            if [[ -e "$DJAY_PATH/$LIBRARY_FILE" ]]; then
                backup_file="$HOME/Documents/djay_backup_$(date '+%Y%m%d_%H%M%S').djayMediaLibrary"
                cp -R "$DJAY_PATH/$LIBRARY_FILE" "$backup_file"
                log_message "Backup created: $backup_file"
                echo -e "${_c}💾 Backup created: $(basename "$backup_file")${_0}"
            fi
            cp -R "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" "$DJAY_PATH/"
            echo -e "${_g}✅ Library file copied from iCloud${_0}\n"
        else
            log_message "Local library file is newer or same age"
            echo -e "${_c}ℹ️  Local library file is newer or same age${_0}\n"
        fi
    else
        log_message "WARNING: iCloud library file not found"
        echo -e "${_y}⚠️  iCloud library file not found${_0}\n"
    fi

    # Sync folders
    for folder in "Key Bindings" "MIDI Mappings"; do
        if [[ -d "$ICLOUD_DJAY_PATH/$folder" ]]; then
            log_message "Syncing folder: $folder"
            echo -e "${_m}📁 Syncing folder: ${_c}$folder${_0}"
            rsync -av --delete "$ICLOUD_DJAY_PATH/$folder/" "$DJAY_PATH/$folder/"
            echo -e "${_g}✅ $folder synced${_0}\n"
        fi
    done
}

# Function to show sync status
show_status() {
    echo -e "\n${_m}📊 djay Pro iCloud Sync Status${_0}\n"

    # Local files
    echo -e "${_g}🏠 Local djay directory:${_0}"
    if [[ -d "$DJAY_PATH" ]]; then
        echo "  📍 Path: $DJAY_PATH"
        if [[ -e "$DJAY_PATH/$LIBRARY_FILE" ]]; then
            local_time=$(get_file_time "$DJAY_PATH/$LIBRARY_FILE")
            echo "  📄 Library file: $(date -r $local_time)"
            echo "  📏 Size: $(du -sh "$DJAY_PATH/$LIBRARY_FILE" | cut -f1)"
        else
            echo "  ❌ Library file: Not found"
        fi
    else
        echo "  ❌ Directory: Not found"
    fi

    echo ""

    # iCloud files
    echo -e "${_c}☁️  iCloud djay directory:${_0}"
    if [[ -d "$ICLOUD_DJAY_PATH" ]]; then
        echo "  📍 Path: $ICLOUD_DJAY_PATH"
        if [[ -e "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" ]]; then
            icloud_time=$(get_file_time "$ICLOUD_DJAY_PATH/$LIBRARY_FILE")
            echo "  📄 Library file: $(date -r $icloud_time)"
            echo "  📏 Size: $(du -sh "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" | cut -f1)"
        else
            echo "  ❌ Library file: Not found"
        fi
    else
        echo "  ❌ Directory: Not found"
    fi

    echo ""

    # Compare timestamps
    if [[ -e "$DJAY_PATH/$LIBRARY_FILE" && -e "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" ]]; then
        local_time=$(get_file_time "$DJAY_PATH/$LIBRARY_FILE")
        icloud_time=$(get_file_time "$ICLOUD_DJAY_PATH/$LIBRARY_FILE")

        echo -e "${_g}🔄 Sync status:${_0}"
        if [[ $local_time -gt $icloud_time ]]; then
            echo "  📤 Local file is newer (needs upload to iCloud)"
        elif [[ $icloud_time -gt $local_time ]]; then
            echo "  📥 iCloud file is newer (needs download to local)"
        else
            echo "  ✅ Files are in sync"
        fi
    fi
    echo ""
}

# Function to setup automatic sync
setup_automatic_sync() {
    log_message "Setting up automatic sync"
    echo -e "${_m}⚙️  Setting up automatic sync...${_0}"

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
        <string>$(which zsh)</string>
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
    echo -e "${_g}✅ Automatic sync setup complete${_0}"
    echo "${_c}⏰ Will run every 5 minutes${_0}\n"
}

# Function to stop automatic sync
stop_automatic_sync() {
    local plist_file="$HOME/Library/LaunchAgents/com.user.djay-sync.plist"

    if [[ -f "$plist_file" ]]; then
        launchctl unload "$plist_file"
        rm "$plist_file"
        log_message "Automatic sync stopped and removed"
        echo -e "${_g}✅ Automatic sync stopped and removed${_0}\n"
    else
        log_message "No automatic sync found to stop"
        echo -e "${_y}⚠️  No automatic sync found to stop${_0}\n"
    fi
}

# Function to check automatic sync status
check_automatic_sync() {
    local plist_file="$HOME/Library/LaunchAgents/com.user.djay-sync.plist"

    if [[ -f "$plist_file" ]]; then
        echo -e "${_g}✅ Automatic sync is ENABLED${_0}"
        echo "  📄 Plist file: $plist_file"
        echo "  📝 Log file: $LOG_FILE"
        echo "  ⏰ Interval: Every 5 minutes"

        # Check if it's currently loaded
        if launchctl list | grep -q "com.user.djay-sync"; then
            echo "  🟢 Status: Active and running"
        else
            echo "  🟡 Status: Not currently loaded"
        fi
    else
        echo -e "${_y}⚠️  Automatic sync is DISABLED${_0}"
        echo "  💡 Run '${_c}$0 setup-auto${_0}' to enable"
    fi
    echo ""
}

# Function to show recent log entries
show_recent_logs() {
    if [[ -f "$LOG_FILE" ]]; then
        echo -e "${_m}📝 Recent djay Sync Log Entries${_0}"
        echo "📄 Log file: $LOG_FILE"
        echo ""
        tail -20 "$LOG_FILE"
    else
        echo -e "${_y}⚠️  No log file found at $LOG_FILE${_0}\n"
    fi
}

# Main script function
djay_icloud_sync_main() {
    log_message "=== djay Pro iCloud Sync Started ==="
    echo -e "${_m}🎵 djay Pro iCloud Sync Started${_0}\n"

    # Check iCloud Drive
    if ! check_icloud_drive; then
        return 1
    fi

    # Create iCloud directory if needed
    create_icloud_djay_dir

    # Sync both directions
    sync_to_icloud
    sync_from_icloud

    log_message "=== djay Pro iCloud Sync Completed ==="
    echo -e "${_g}✅ djay Pro iCloud Sync Completed${_0}\n"
}

# Command line interface (only runs when script is executed directly)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Parse command line arguments
    case "${1:-sync}" in
        "sync")
            djay_icloud_sync_main
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
            djay_icloud_sync_main
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
            echo -e "${_m}🎵 djay Pro iCloud Sync - Help${_0}\n"
            echo "Usage: $0 [command]"
            echo ""
            echo -e "${_g}Commands:${_0}"
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
            echo -e "${_c}Examples:${_0}"
            echo "  $0 sync        # Sync both directions"
            echo "  $0 status      # Check current sync status"
            echo "  $0 setup-auto  # Enable automatic sync"
            echo "  $0 logs        # View recent activity"
            echo ""
            ;;
        *)
            echo -e "${_r}❌ Invalid command: $1${_0}\n"
            echo "Usage: $0 [sync|to-icloud|from-icloud|status|setup-auto|stop-auto|check-auto|logs|help]"
            echo -e "${_g}Commands:${_0}"
            echo "  sync        - Sync both directions"
            echo "  to-icloud   - Sync local files to iCloud"
            echo "  from-icloud - Sync iCloud files to local"
            echo "  status      - Show sync status"
            echo "  setup-auto  - Setup automatic sync every 5 minutes"
            echo "  stop-auto   - Stop and remove automatic sync"
            echo "  check-auto  - Check if automatic sync is enabled and its status"
            echo "  logs        - Show recent log entries"
            echo "  help        - Show detailed help"
            echo ""
            exit 1
            ;;
    esac
fi
