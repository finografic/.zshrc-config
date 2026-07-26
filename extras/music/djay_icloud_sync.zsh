#!/bin/zsh

# djay Pro iCloud Sync Script
# This script syncs djay Pro files using iCloud Drive
# Based on the iCloud Drive structure shown in the user's screenshots

# Source colors (with fallback)
source ~/.zshrc-config/lib/colors.zsh

# Configuration
DJAY_PATH="$HOME/Music/djay"
ICLOUD_DJAY_PATH="$HOME/Library/Mobile Documents/com~apple~CloudDocs/djay"
LIBRARY_FILE="djay Media Library.djayMediaLibrary"
# Move logs to the repo
ZSHRC_ROOT="$HOME/.zshrc-config"
LOG_FILE="$ZSHRC_ROOT/extras/music/logs/djay_icloud_sync.log"

# Main djay command function
function djay() {
    case "${1:-help}" in
        "sync")
            djay-icloud-sync-main
            ;;
        "status")
            show-status
            ;;
        "up"|"to-icloud")
            check-icloud-drive && create-icloud-djay-dir && sync-to-icloud
            ;;
        "down"|"from-icloud")
            check-icloud-drive && sync-from-icloud
            ;;
        "logs")
            show-recent-logs
            ;;
        "debug")
            debug-timestamps
            ;;
        "agent-start"|"start-sync-auto"|"setup-auto")
            setup-automatic-sync
            ;;
        "agent-stop"|"stop-sync-auto"|"stop-auto")
            stop-automatic-sync
            ;;
        "agent-status"|"check-auto")
            check-automatic-sync
            ;;
        "export-ios")
            # Export the djay library directory to iCloud Drive for iOS import
            IOS_EXPORT_DIR="$ICLOUD_DJAY_PATH/ios-transfer"
            mkdir -p "$IOS_EXPORT_DIR"

            if [[ -d "$DJAY_PATH/$LIBRARY_FILE" ]]; then
                # Copy the entire directory recursively
                cp -Rv "$DJAY_PATH/$LIBRARY_FILE" "$IOS_EXPORT_DIR/"
                echo -e "\n${_g}✅ Exported djay Media Library for iOS!${_0}"
                echo -e "${_c}Next steps on your iPhone:${_0}"
                echo -e "1. Open the Files app."
                echo -e "2. Go to iCloud Drive > djay > ios-transfer."
                echo -e "3. Tap and hold the djay Media Library.djayMediaLibrary folder, then tap Copy."
                echo -e "4. Navigate to On My iPhone > djay > User Data."
                echo -e "5. Tap and hold, then tap Paste. If prompted, choose Replace."
                echo -e "6. Relaunch djay Pro on your iPhone."
                echo -e "\n${_y}Note: Playlists and cues will be included, but you may need to relink audio files if they are not on your device.${_0}"
            else
                echo -e "\n${_r}❌ djay Media Library not found at: $DJAY_PATH/$LIBRARY_FILE${_0}"
                echo -e "${_y}Please ensure djay Pro is installed and has been run at least once.${_0}"
            fi
            ;;
        "auto-export-ios")
            # Automatically export to ios-transfer during sync operations
            IOS_EXPORT_DIR="$ICLOUD_DJAY_PATH/ios-transfer"
            mkdir -p "$IOS_EXPORT_DIR"

            if [[ -d "$DJAY_PATH/$LIBRARY_FILE" ]]; then
                # Copy the entire directory recursively
                cp -Rv "$DJAY_PATH/$LIBRARY_FILE" "$IOS_EXPORT_DIR/"
                echo -e "\n${_g}✅ Auto-exported djay Media Library for iOS!${_0}"
                echo -e "${_c}Available in iCloud Drive > djay > ios-transfer${_0}"
                log-message "Auto-exported djay library to ios-transfer"
            else
                echo -e "\n${_r}❌ djay Media Library not found at: $DJAY_PATH/$LIBRARY_FILE${_0}"
                echo -e "${_y}Please ensure djay Pro is installed and has been run at least once.${_0}"
            fi
            ;;
        "help"|"--help"|"-h")
            echo -e "${_m}🎵 djay Pro Sync - Main Command${_0}\n"
            echo "Usage: djay [command]"
            echo ""
            echo -e "${_g}Commands:${_0}"
            echo "  sync          - Sync both directions"
            echo "  status        - Show sync status"
            echo "  up            - Upload to iCloud"
            echo "  down          - Download from iCloud"
            echo "  logs          - Show recent logs"
            echo "  debug         - Show detailed timestamp and permission info"
            echo "  export-ios    - Manual export for iPhone (one-time)"
            echo "  auto-export-ios - Auto-export for iPhone (during sync)"
            echo "  agent-start   - Setup automatic sync"
            echo "  agent-stop    - Stop automatic sync"
            echo "  agent-status  - Check auto sync status"
            echo "  help          - Show this help"
            echo ""
            echo -e "${_c}Examples:${_0}"
            echo "  djay sync          # Sync both directions"
            echo "  djay status        # Check current status"
            echo "  djay up            # Upload to iCloud"
            echo "  djay logs          # View recent activity"
            echo "  djay agent-start   # Enable automatic sync"
            echo "  djay agent-stop    # Disable automatic sync"
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
alias djay-sync='~/.zshrc-config/extras/music/djay_icloud_sync.zsh'
alias djay-status='~/.zshrc-config/extras/music/djay_icloud_sync.zsh status'
alias djay-up='~/.zshrc-config/extras/music/djay_icloud_sync.zsh up'
alias djay-down='~/.zshrc-config/extras/music/djay_icloud_sync.zsh down'
alias djay-logs='~/.zshrc-config/extras/music/djay_icloud_sync.zsh logs'
alias djay-help='~/.zshrc-config/extras/music/djay_icloud_sync.zsh help'

# Function to log messages
function log-message() {
    # Ensure log directory exists
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check if iCloud Drive is available
function check-icloud-drive() {
    if [[ ! -d "$HOME/Library/Mobile Documents/com~apple~CloudDocs" ]]; then
        log-message "ERROR: iCloud Drive not found"
        echo -e "\n${_r}❌ iCloud Drive not found${_0}"
        echo "${_y}⚠️  Please enable iCloud Drive in System Preferences > Apple ID > iCloud${_0}\n"
        return 1
    fi
    return 0
}

# Function to create iCloud djay directory
function create-icloud-djay-dir() {
    if [[ ! -d "$ICLOUD_DJAY_PATH" ]]; then
        log-message "Creating iCloud djay directory"
        mkdir -p "$ICLOUD_DJAY_PATH"
        mkdir -p "$ICLOUD_DJAY_PATH/Key Bindings"
        mkdir -p "$ICLOUD_DJAY_PATH/MIDI Mappings"
        mkdir -p "$ICLOUD_DJAY_PATH/ios-transfer"
        echo -e "${_g}📁 Created iCloud djay directory${_0}\n"
    fi
}

# Function to get file/directory modification time
function get-file-time() {
    local file="$1"
    if [[ -e "$file" ]]; then
        stat -f "%m" "$file"
    else
        echo "0"
    fi
}

# Function to update bundle timestamp (for macOS packages/bundles)
function update-bundle-timestamp() {
    local bundle_path="$1"
    local update_to_current_time="${2:-false}"

    if [[ -d "$bundle_path" ]]; then
        if [[ "$update_to_current_time" == "true" ]]; then
            # Update bundle timestamp to current time (for sync activity)
            touch "$bundle_path"
            log-message "Updated bundle timestamp to current time for: $(basename "$bundle_path")"
        else
            # Find the most recently modified file inside the bundle
            local newest_file=$(find "$bundle_path" -type f -exec stat -f "%m %N" {} \; | sort -nr | head -1 | cut -d' ' -f2-)
            if [[ -n "$newest_file" ]]; then
                # Update the bundle's timestamp to match the newest file inside
                touch -r "$newest_file" "$bundle_path"
                log-message "Updated bundle timestamp for: $(basename "$bundle_path")"
            fi
        fi
    fi
}

# Function to check iCloud Drive permissions
function check-icloud-permissions() {
    local test_file="$ICLOUD_DJAY_PATH/.test_write_permission"

    # Try to create a test file
    if touch "$test_file" 2>/dev/null; then
        rm "$test_file" 2>/dev/null
        return 0
    else
        return 1
    fi
}

# Function to sync files to iCloud
function sync-to-icloud() {
    echo -e "\n${_grey}💻 -> ☁️ SYNC TO iCLOUD${_0}${_grey} ──────────────────────────────────────────────────────────${_0}\n"
    log-message "Syncing djay files to iCloud Drive"

    # Check iCloud permissions first
    if ! check-icloud-permissions; then
        log-message "ERROR: No write permission to iCloud Drive"
        echo -e "${_r}❌ No write permission to iCloud Drive${_0}"
        echo -e "${_y}⚠️ Please check iCloud Drive permissions in System Preferences${_0}\n"
        return 1
    fi

    # Sync library file/directory (bundle)
    if [[ -e "$DJAY_PATH/$LIBRARY_FILE" ]]; then
        local_time=$(get-file-time "$DJAY_PATH/$LIBRARY_FILE")
        icloud_time=$(get-file-time "$ICLOUD_DJAY_PATH/$LIBRARY_FILE")

        if [[ $local_time -gt $icloud_time ]]; then
            echo -e "\n${_y}💻 -> ☁️ Local library is newer, copying to iCloud..${_0}"

            # Attempt copy and check for errors
            if cp -R "$DJAY_PATH/$LIBRARY_FILE" "$ICLOUD_DJAY_PATH/" 2>/dev/null; then
                # Update bundle timestamp to match newest internal file
                update-bundle-timestamp "$ICLOUD_DJAY_PATH/$LIBRARY_FILE"
                echo -e "${_g}✅ Library copied to iCloud (timestamp updated to data time)${_0}\n"
                log-message "Local library file is newer, copying to iCloud"
            else
                echo -e "${_r}❌ Library copy failed - permission denied${_0}\n"
                log-message "ERROR: Library copy failed - permission denied"
                return 1
            fi
        else
            log-message "iCloud library file is newer or same age"
            update-bundle-timestamp "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" "true"
            echo -e "\n"
            echo -e "${_grey}ℹ️ Library unchanged (no upload needed)${_0}"
            # Update bundle timestamp to show sync activity
            echo -e "${_grey}📝 Updated bundle timestamp to show sync activity${_0}\n"
        fi
    else
        log-message "WARNING: Local library file not found"
        echo -e "${_y}⚠️ Local library file not found${_0}\n"
    fi

    # Sync folders (excluding ios-transfer - it's for manual export only)
    for folder in "Key Bindings" "MIDI Mappings"; do
        if [[ -d "$DJAY_PATH/$folder" ]]; then
            echo -e "${_w}📁 ${_c}$folder${_0}"

            # Check if rsync actually made changes
            rsync_output=$(rsync -av --delete "$DJAY_PATH/$folder/" "$ICLOUD_DJAY_PATH/$folder/" 2>&1)
            rsync_exit_code=$?

            if [[ $rsync_exit_code -eq 0 ]]; then
                # Check if files were actually transferred by looking for file transfer indicators
                if echo "$rsync_output" | grep -q -E "(^[^d].*|^d.*|^sending|^receiving|^sent|^received)"; then
                    echo -e "${_g}✅ synced (files updated)${_0}"
                    log-message "synced folder: $folder"
                    # Touch the folder to update its timestamp
                    touch "$ICLOUD_DJAY_PATH/$folder"
                else
                    echo -e "${_grey}ℹ️ $folder unchanged (no files updated)${_0}"
                    # Still update folder timestamp to show sync activity
                    touch "$ICLOUD_DJAY_PATH/$folder"
                fi
            else
                echo -e "${_r}❌ $folder sync failed${_0}"
                echo -e "${_y}Debug: $rsync_output${_0}"
                log-message "ERROR: $folder sync failed - $rsync_output"
            fi
            echo ""
        fi
    done

    # echo -e "${_grey}────────────────────────────────────────────────────────────────────────────────────${_0}\n"
}

# Function to sync files from iCloud
function sync-from-icloud() {
    echo -e "\n${_grey}💻 <- ☁️ SYNC FROM iCLOUD${_0}${_grey} ────────────────────────────────────────────────────────${_0}\n"
    log-message "Syncing djay files from iCloud Drive"

    # Check if djay is running
    if pgrep -x "djay" > /dev/null; then
        log-message "WARNING: djay Pro is running. Please quit djay Pro before syncing."
        echo -e "\n${_y}⚠️ djay Pro is running${_0}"
        echo "${_y}⚠️ Please quit djay Pro and run this script again${_0}\n"
        return 1
    fi

    # Sync library file/directory (bundle)
    if [[ -e "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" ]]; then
        local_time=$(get-file-time "$DJAY_PATH/$LIBRARY_FILE")
        icloud_time=$(get-file-time "$ICLOUD_DJAY_PATH/$LIBRARY_FILE")

        if [[ $icloud_time -gt $local_time ]]; then
            log-message "iCloud library file is newer, copying to local"
            echo -e "\n${_y}💻 <- ☁️ iCloud library is newer, copying to local..${_0}"
            # Create backup first
            if [[ -e "$DJAY_PATH/$LIBRARY_FILE" ]]; then
                backup_file="$HOME/Documents/djay_backup_$(date '+%Y%m%d_%H%M%S').djayMediaLibrary"
                cp -R "$DJAY_PATH/$LIBRARY_FILE" "$backup_file"
                echo -e "${_c}\n💾 $(basename "$backup_file")${_0}"
                log-message "Backup created: $backup_file"
            fi
            cp -R "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" "$DJAY_PATH/"
            # Update bundle timestamp to match newest internal file
            update-bundle-timestamp "$DJAY_PATH/$LIBRARY_FILE"
            echo -e "${_g}✅ Library copied from iCloud (timestamp updated to data time)${_0}\n"
        else
            log-message "Local library file is newer or same age"
            # Update bundle timestamp to show sync activity
            update-bundle-timestamp "$DJAY_PATH/$LIBRARY_FILE" "true"
            echo -e "\n"
            echo -e "${_grey}ℹ️ Library unchanged (no download needed)${_0}"
            echo -e "${_grey}📝 Updated bundle timestamp to show sync activity${_0}"
        fi
    else
        log-message "WARNING: iCloud library file not found"
        echo -e "${_y}⚠️ iCloud library file not found${_0}\n"
    fi

    # Sync folders (excluding ios-transfer - it's for manual export only)
    for folder in "Key Bindings" "MIDI Mappings"; do
        if [[ -d "$ICLOUD_DJAY_PATH/$folder" ]]; then
            echo -e "${_w}📁 ${_c}$folder${_0}"

            # Check if rsync actually made changes
            rsync_output=$(rsync -av --delete "$ICLOUD_DJAY_PATH/$folder/" "$DJAY_PATH/$folder/" 2>&1)
            rsync_exit_code=$?

            if [[ $rsync_exit_code -eq 0 ]]; then
                # Check if files were actually transferred by looking for file transfer indicators
                if echo "$rsync_output" | grep -q -E "(^[^d].*|^d.*|^sending|^receiving|^sent|^received)"; then
                   log-message "synced folder: $folder"
                  echo -e "${_g}✅ files updated and synced${_0}"
                    # Touch the folder to update its timestamp
                    touch "$DJAY_PATH/$folder"
                else
                    echo -e "${_grey}ℹ️ unchanged -  no files updated${_0}"
                    # Still update folder timestamp to show sync activity
                    touch "$DJAY_PATH/$folder"
                fi
            else
                echo -e "${_r}❌ sync failed${_0}"
                echo -e "${_y}Debug: $rsync_output${_0}"
            fi
            echo ""
        fi
    done

    # echo -e "${_grey}────────────────────────────────────────────────────────────────────────────────────${_0}\n"
}

# Function to debug file timestamps
function debug-timestamps() {
    echo -e "\n${_m}🔍 TIMESTAMP DEBUG INFO${_0}"
    echo -e "${_grey}────────────────────────────────────────────────────────────────────────────────────${_0}\n"

    # Check system date
    echo -e "${_c}📅 System Date:${_0} $(date)"
    echo -e "${_c}📅 System Date (UTC):${_0} $(date -u)"
    echo ""

    # Check local file
    if [[ -e "$DJAY_PATH/$LIBRARY_FILE" ]]; then
        local_time=$(get-file-time "$DJAY_PATH/$LIBRARY_FILE")
        echo -e "${_c}💻 Local File:${_0}"
        echo -e "  Path: $DJAY_PATH/$LIBRARY_FILE"
        echo -e "  Timestamp: $local_time"
        echo -e "  Date: $(date -r $local_time)"
        echo -e "  Size: $(du -sh "$DJAY_PATH/$LIBRARY_FILE" | cut -f1)"
    else
        echo -e "${_r}❌ Local file not found${_0}"
    fi
    echo ""

    # Check iCloud file
    if [[ -e "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" ]]; then
        icloud_time=$(get-file-time "$ICLOUD_DJAY_PATH/$LIBRARY_FILE")
        echo -e "${_c}☁️ iCloud File:${_0}"
        echo -e "  Path: $ICLOUD_DJAY_PATH/$LIBRARY_FILE"
        echo -e "  Timestamp: $icloud_time"
        echo -e "  Date: $(date -r $icloud_time)"
        echo -e "  Size: $(du -sh "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" | cut -f1)"
    else
        echo -e "${_r}❌ iCloud file not found${_0}"
    fi
    echo ""

    # Check permissions
    echo -e "${_c}🔐 Permission Check:${_0}"
    if check-icloud-permissions; then
        echo -e "  ✅ iCloud Drive: Write permission OK"
    else
        echo -e "  ❌ iCloud Drive: No write permission"
    fi

    if [[ -w "$DJAY_PATH" ]]; then
        echo -e "  ✅ Local djay: Write permission OK"
    else
        echo -e "  ❌ Local djay: No write permission"
    fi
    echo ""
}

# Function to convert seconds to human-readable relative time
function format-relative-time() {
    local seconds="$1"
    local abs_seconds=${seconds#-}  # Remove negative sign for calculation

    if [[ $abs_seconds -lt 60 ]]; then
        echo "${abs_seconds}s"
    elif [[ $abs_seconds -lt 3600 ]]; then
        local minutes=$((abs_seconds / 60))
        echo "${minutes}min"
    else
        local hours=$((abs_seconds / 3600))
        echo "${hours}h"
    fi
}

# Function to check if files actually need syncing using rsync dry-run
function check-sync-needed() {
    local source="$1"
    local destination="$2"
    local direction="$3"  # "up" or "down"

    # Check if source exists
    if [[ ! -e "$source" ]]; then
        echo "missing"
        return
    fi

    # For the main library bundle, check if it exists and compare timestamps
    if [[ -d "$source/djay Media Library.djayMediaLibrary" ]]; then
        local local_time=$(get-file-time "$source/djay Media Library.djayMediaLibrary")
        local remote_time=$(get-file-time "$destination/djay Media Library.djayMediaLibrary")

        # If timestamps are within 5 seconds, consider them synchronized
        local time_diff=$((local_time - remote_time))
        if [[ ${time_diff#-} -le 5 ]]; then
            echo "synced"
            return
        fi
    fi

    # For folders, use rsync dry-run but only on specific djay folders
    local rsync_output
    local has_changes=false

    # Check each djay folder specifically (excluding ios-transfer - manual export only)
    for folder in "Key Bindings" "MIDI Mappings"; do
        if [[ -d "$source/$folder" ]]; then
            local folder_output=$(rsync -avn --delete "$source/$folder/" "$destination/$folder/" 2>/dev/null)
            if echo "$folder_output" | grep -q -E "(^[^d].*|^d.*|^sending|^receiving|^sent|^received)"; then
                has_changes=true
                break
            fi
        fi
    done

    if [[ "$has_changes" == "true" ]]; then
        echo "needed"
    else
        echo "synced"
    fi
}

# Function to show sync status
function show-status() {
    # echo -e "\n${_m}💾 djay Pro iCloud Sync Status${_0}\n"

    # Local files
    echo -e "\n${_m}💻 Local djay directory: $(du -sh "$DJAY_PATH/$LIBRARY_FILE" | cut -f1) ${_grey}$DJAY_PATH${_0}"
    if [[ -d "$DJAY_PATH" ]]; then
        if [[ -e "$DJAY_PATH/$LIBRARY_FILE" ]]; then
            local_time=$(get-file-time "$DJAY_PATH/$LIBRARY_FILE")
            echo "${_w}$(date -r $local_time)${_0}"
        else
            echo "${_r}❌ Library file: Not found${_0}"
        fi
    else
        echo "  ❌ Directory: Not found"
    fi

    echo ""

    # iCloud files
    echo -e "${_c}☁️ iCloud djay directory: $(du -sh "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" | cut -f1) ${_grey}$ICLOUD_DJAY_PATH${_0}"
    if [[ -d "$ICLOUD_DJAY_PATH" ]]; then
        if [[ -e "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" ]]; then
            icloud_time=$(get-file-time "$ICLOUD_DJAY_PATH/$LIBRARY_FILE")
            echo "${_w}$(date -r $icloud_time)${_0}"
        else
            echo "  ❌ Library file: Not found"
        fi
    else
        echo "  ❌ Directory: Not found"
    fi

    echo ""

    # Check actual sync status using rsync dry-run
    if [[ -e "$DJAY_PATH/$LIBRARY_FILE" && -e "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" ]]; then
        local_time=$(get-file-time "$DJAY_PATH/$LIBRARY_FILE")
        icloud_time=$(get-file-time "$ICLOUD_DJAY_PATH/$LIBRARY_FILE")

        # Check if upload is needed
        upload_status=$(check-sync-needed "$DJAY_PATH" "$ICLOUD_DJAY_PATH" "up")
        download_status=$(check-sync-needed "$ICLOUD_DJAY_PATH" "$DJAY_PATH" "down")

        # Calculate time difference for display
        time_diff=$((local_time - icloud_time))
        relative_time=$(format-relative-time $time_diff)

        if [[ "$upload_status" == "needed" ]]; then
            echo -e "${_w}💻 -> ☁️ Last sync: ${_y}${relative_time} ago${_0}"
            echo -e "${_w}$(date -r $icloud_time)${_0}"
            echo -e "${_y}Sync required${_0}\n"
        elif [[ "$download_status" == "needed" ]]; then
            echo -e "${_w}💻 <- ☁️ Last sync: ${_y}${relative_time} ago${_0}"
            echo -e "${_w}$(date -r $local_time)${_0}"
            echo -e "${_y}Sync required${_0}\n"
        else
            echo -e "${_w}Last sync: ${_g}${relative_time} ago${_0}"
            echo -e "${_w}$(date -r $icloud_time)${_0}"
            echo -e "${_g}✅ Files are synchronized${_0}\n"
        fi
    fi
    echo ""
}

# Function to setup automatic sync
function setup-automatic-sync() {
    log-message "Setting up automatic sync"
    echo -e "${_m}⚙️  Setting up automatic sync..${_0}"

    # Create launch agent plist
    local plist_dir="$HOME/Library/LaunchAgents"
    local plist_file="$plist_dir/com.user.djay-sync.plist"

    mkdir -p "$plist_dir"

    # Create plist with variable expansion
    cat > "$plist_file" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.djay-sync</string>
    <key>ProgramArguments</key>
    <array>
        <string>ZSH_PATH</string>
        <string>SCRIPT_PATH</string>
        <string>auto</string>
    </array>
    <key>StartInterval</key>
    <integer>900</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>LOG_PATH</string>
    <key>StandardErrorPath</key>
    <string>LOG_PATH</string>
</dict>
</plist>
EOF

    # Replace placeholders with actual values
    sed -i '' "s|ZSH_PATH|$(which zsh)|g" "$plist_file"
    sed -i '' "s|SCRIPT_PATH|$HOME/.zshrc-config/music/djay_icloud_sync.zsh|g" "$plist_file"
    sed -i '' "s|LOG_PATH|$LOG_FILE|g" "$plist_file"

    # Load the launch agent
    launchctl load "$plist_file"
    log-message "Automatic sync setup complete. Will run every 15 minutes."
    echo -e "${_g}✅ Automatic sync setup complete${_0}"
    echo "${_c}⏰ Will run every 15 minutes${_0}\n"
}

# Function to stop automatic sync
function stop-automatic-sync() {
    local plist_file="$HOME/Library/LaunchAgents/com.user.djay-sync.plist"

    if [[ -f "$plist_file" ]]; then
        launchctl unload "$plist_file"
        rm "$plist_file"
        echo -e "${_g}✅ Automatic sync stopped and removed${_0}\n"
        log-message "Automatic sync stopped and removed"
    else
        echo -e "${_y}⚠️ No automatic sync found to stop${_0}\n"
        log-message "No automatic sync found to stop"
    fi
}

# Function to check automatic sync status
function check-automatic-sync() {
    local plist_file="$HOME/Library/LaunchAgents/com.user.djay-sync.plist"

    if [[ -f "$plist_file" ]]; then
        echo -e "${_g}✅ Automatic sync is ENABLED${_0}"
        echo "  📄 Plist file: $plist_file"
        echo "  📝 Log file: $LOG_FILE"
        echo "  ⏰ Interval: Every 15 minutes"

        # Check if it's currently loaded
        if launchctl list | grep -q "com.user.djay-sync"; then
            echo "  🟢 Status: Active and running"
        else
            echo "  🟡 Status: Not currently loaded"
        fi

        # Show last sync time from log file
        if [[ -f "$LOG_FILE" ]]; then
            last_sync=$(grep "djay Pro iCloud synced" "$LOG_FILE" | tail -1 | cut -d' ' -f1,2)
            if [[ -n "$last_sync" ]]; then
                echo "  📅 Last agent sync: $last_sync"
            else
                echo "  📅 Last agent sync: Never (or log cleared)"
            fi
        fi

        # Show current sync status
        if [[ -e "$DJAY_PATH/$LIBRARY_FILE" && -e "$ICLOUD_DJAY_PATH/$LIBRARY_FILE" ]]; then
            upload_status=$(check-sync-needed "$DJAY_PATH" "$ICLOUD_DJAY_PATH" "up")
            download_status=$(check-sync-needed "$ICLOUD_DJAY_PATH" "$DJAY_PATH" "down")

            if [[ "$upload_status" == "needed" ]]; then
                echo "  �� Sync status: ${_y}Sync required${_0}"
            elif [[ "$download_status" == "needed" ]]; then
                echo "  🔄 Sync status: ${_y}Sync required${_0}"
            else
                echo "  🔄 Sync status: ${_g}Synchronized${_0}"
            fi
        fi
    else
        echo -e "${_y}⚠️ Automatic sync is DISABLED${_0}"
        echo "  💡 Run '${_c}$0 setup-auto${_0}' to enable"
    fi
    echo ""
}

# Function to show recent log entries
function show-recent-logs() {
    if [[ -f "$LOG_FILE" ]]; then
        echo -e "${_m}📝 Recent djay Sync Log Entries${_0}"
        echo "📄 Log file: $LOG_FILE"
        echo ""
        tail -20 "$LOG_FILE"
    else
        echo -e "${_y}⚠️ No log file found at $LOG_FILE${_0}\n"
    fi
}

# Main script function
function djay-icloud-sync-main() {
    echo -e "\n${_w}🎧 DJAY PRO iCLOUD SYNC:${_0}\n"

      log-message "djay Pro iCloud Sync Started"
      echo -e "\n"


    # Check iCloud Drive
    if ! check-icloud-drive; then
        return 1
    fi

    # Create iCloud directory if needed
    create-icloud-djay-dir

    # Sync both directions
    sync-to-icloud
    sync-from-icloud

    echo -e "${_g}✅ djay Pro iCloud Sync Completed${_0}\n"
    log-message "djay Pro iCloud synced"
}

# Command line interface (only runs when script is EXECUTED, never when sourced).
#
# NOTE: the previous guard was
#   [[ "$ZSH_EVAL_CONTEXT" == "toplevel"* ]] || [[ "${BASH_SOURCE[0]}" == "$0" ]]
# and both halves were wrong in zsh:
#   - $ZSH_EVAL_CONTEXT ALWAYS starts with "toplevel" — it is a colon-separated
#     stack, e.g. "toplevel:file" when sourced from a script, "toplevel" when
#     executed. `toplevel*` therefore matches every case.
#   - $BASH_SOURCE does not exist in zsh, so that half is always false.
# The net effect was a CLI dispatcher that fired while being *sourced*: with an
# empty $1 it defaults to "sync" and would start a real iCloud sync at shell
# startup. It only stayed dormant because an interactive shell happens to
# produce a context of "file:file:..." rather than "toplevel:...".
#
# ${zsh_eval_context[-1]} is the correct test. It is "file" whenever this file is
# being sourced, at any depth; when it is being run it is the invocation kind —
# "toplevel" for `zsh script.zsh`, "cmdarg" for `zsh -c`. Testing `!= file`
# therefore means exactly "not being sourced", and covers both run styles.
# Read it before any $( ), which would push another context level.
if [[ "${zsh_eval_context[-1]}" != file ]]; then
    # Parse command line arguments
    case "${1:-sync}" in
        "sync")
            djay-icloud-sync-main
            ;;
        "up")
            check-icloud-drive && create-icloud-djay-dir && sync-to-icloud
            ;;
        "down")
            check-icloud-drive && sync-from-icloud
            ;;
        "status")
            show-status
            ;;
        "auto")
            djay-icloud-sync-main
            ;;
        "agent-start")
            setup-automatic-sync
            ;;
        "agent-stop")
            stop-automatic-sync
            ;;
        "agent-status")
            check-automatic-sync
            ;;
        "logs")
            show-recent-logs
            ;;
        "debug")
            debug-timestamps
            ;;
        "export-ios")
            # Export the djay library directory to iCloud Drive for iOS import
            IOS_EXPORT_DIR="$ICLOUD_DJAY_PATH/ios-transfer"
            mkdir -p "$IOS_EXPORT_DIR"

            if [[ -d "$DJAY_PATH/$LIBRARY_FILE" ]]; then
                # Copy the entire directory recursively
                cp -Rv "$DJAY_PATH/$LIBRARY_FILE" "$IOS_EXPORT_DIR/"
                echo -e "\n${_g}✅ Exported djay Media Library for iOS!${_0}"
                echo -e "${_c}Next steps on your iPhone:${_0}"
                echo -e "1. Open the Files app."
                echo -e "2. Go to iCloud Drive > djay > ios-transfer."
                echo -e "3. Tap and hold the djay Media Library.djayMediaLibrary folder, then tap Copy."
                echo -e "4. Navigate to On My iPhone > djay > User Data."
                echo -e "5. Tap and hold, then tap Paste. If prompted, choose Replace."
                echo -e "6. Relaunch djay Pro on your iPhone."
                echo -e "\n${_y}Note: Playlists and cues will be included, but you may need to relink audio files if they are not on your device.${_0}"
            else
                echo -e "\n${_r}❌ djay Media Library not found at: $DJAY_PATH/$LIBRARY_FILE${_0}"
                echo -e "${_y}Please ensure djay Pro is installed and has been run at least once.${_0}"
            fi
            ;;
        "auto-export-ios")
            # Automatically export to ios-transfer during sync operations
            IOS_EXPORT_DIR="$ICLOUD_DJAY_PATH/ios-transfer"
            mkdir -p "$IOS_EXPORT_DIR"

            if [[ -d "$DJAY_PATH/$LIBRARY_FILE" ]]; then
                # Copy the entire directory recursively
                cp -Rv "$DJAY_PATH/$LIBRARY_FILE" "$IOS_EXPORT_DIR/"
                echo -e "\n${_g}✅ Auto-exported djay Media Library for iOS!${_0}"
                echo -e "${_c}Available in iCloud Drive > djay > ios-transfer${_0}"
                log-message "Auto-exported djay library to ios-transfer"
            else
                echo -e "\n${_r}❌ djay Media Library not found at: $DJAY_PATH/$LIBRARY_FILE${_0}"
                echo -e "${_y}Please ensure djay Pro is installed and has been run at least once.${_0}"
            fi
            ;;
        "help")
            echo -e "${_m}🎧 djay Pro iCloud Sync - Help${_0}\n"
            echo "Usage: $0 [command]"
            echo ""
            echo -e "${_g}Commands:${_0}"
            echo "  sync        - Sync both directions"
            echo "  up          - Sync local files to iCloud"
            echo "  down        - Sync iCloud files to local"
            echo "  status      - Show sync status"
            echo "  export-ios  - Manual export for iPhone (one-time)"
            echo "  auto-export-ios - Auto-export for iPhone (during sync)"
            echo "  agent-start - Setup automatic sync every 15 minutes"
            echo "  agent-stop  - Stop and remove automatic sync"
            echo "  agent-status - Check if automatic sync is enabled and its status"
            echo "  logs        - Show recent log entries"
            echo "  help        - Show this help message"
            echo ""
            echo -e "${_c}Examples:${_0}"
            echo "  $0 sync        # Sync both directions"
            echo "  $0 status      # Check current sync status"
            echo "  $0 agent-start # Enable automatic sync"
            echo "  $0 logs        # View recent activity"
            echo ""
            ;;
        *)
            echo -e "${_r}❌ Invalid command: $1${_0}\n"
            echo "Usage: $0 [sync|up|down|status|agent-start|agent-stop|agent-status|logs|help]"
            echo -e "${_g}Commands:${_0}"
            echo "  sync        - Sync both directions"
            echo "  up          - Sync local files to iCloud"
            echo "  down        - Sync iCloud files to local"
            echo "  status      - Show sync status"
            echo "  agent-start - Setup automatic sync every 15 minutes"
            echo "  agent-stop  - Stop and remove automatic sync"
            echo "  agent-status - Check if automatic sync is enabled and its status"
            echo "  logs        - Show recent log entries"
            echo "  help        - Show detailed help"
            echo ""
            exit 1
            ;;
    esac
fi
