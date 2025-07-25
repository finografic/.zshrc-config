#!/bin/zsh

# djay Pro Git-based Sync Script
# This script uses git to sync djay Pro files between Macs
# Handles binary file conflicts by always using the newer version

# Source colors
source ~/.zshrc-config/lib/colors.zsh

# Configuration
DJAY_PATH="$HOME/Music/djay"
LIBRARY_FILE="djay Media Library.djayMediaLibrary"
GIT_REPO="$HOME/Documents/djay_sync_repo"
LOG_FILE="$HOME/Documents/djay_git_sync.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to initialize git repository
init_git_repo() {
    if [[ ! -d "$GIT_REPO" ]]; then
        log_message "Initializing git repository at $GIT_REPO"
        echo -e "${_m}🔧 Initializing git repository...${_0}"
        mkdir -p "$GIT_REPO"
        cd "$GIT_REPO"
        git init
        echo "*.djayMediaLibrary binary" > .gitattributes
        echo "*.log" >> .gitignore
        echo "*.tmp" >> .gitignore
        git add .gitattributes .gitignore
        git commit -m "Initial commit: Add gitattributes and gitignore"
        log_message "Git repository initialized"
        echo -e "${_g}✅ Git repository initialized at $GIT_REPO${_0}\n"
    fi
}

# Function to copy files to git repo
copy_to_git_repo() {
    log_message "Copying djay files to git repository"
    echo -e "${_m}📁 Copying djay files to git repository...${_0}"

    # Create djay directory in git repo
    mkdir -p "$GIT_REPO/djay"

    # Copy library file/directory
    if [[ -e "$DJAY_PATH/$LIBRARY_FILE" ]]; then
        cp -R "$DJAY_PATH/$LIBRARY_FILE" "$GIT_REPO/djay/"
        log_message "Library file copied to git repo"
        echo -e "${_g}✅ Library file copied to git repo${_0}"
    else
        log_message "WARNING: Library file not found at source"
        echo -e "${_y}⚠️  Library file not found at source${_0}"
    fi

    # Copy other folders
    for folder in "Key Bindings" "MIDI Mappings"; do
        if [[ -d "$DJAY_PATH/$folder" ]]; then
            cp -R "$DJAY_PATH/$folder" "$GIT_REPO/djay/"
            log_message "Folder '$folder' copied to git repo"
            echo -e "${_g}✅ $folder copied to git repo${_0}"
        fi
    done
    echo ""
}

# Function to commit changes
commit_changes() {
    cd "$GIT_REPO"

    # Check if there are changes
    if git diff --quiet && git diff --cached --quiet; then
        log_message "No changes to commit"
        echo -e "${_c}ℹ️  No changes to commit${_0}\n"
        return 0
    fi

    # Add all files
    git add .
    echo -e "${_m}📝 Adding files to git...${_0}"

    # Get file modification time for commit message
    if [[ -e "djay/$LIBRARY_FILE" ]]; then
        mod_time=$(stat -f "%m" "djay/$LIBRARY_FILE")
        commit_msg="Update djay library - $(date -r $mod_time '+%Y-%m-%d %H:%M:%S')"
    else
        commit_msg="Update djay files - $(date '+%Y-%m-%d %H:%M:%S')"
    fi

    # Commit
    if git commit -m "$commit_msg"; then
        log_message "Changes committed: $commit_msg"
        echo -e "${_g}✅ Changes committed: $commit_msg${_0}\n"
    else
        log_message "ERROR: Failed to commit changes"
        echo -e "${_r}❌ Failed to commit changes${_0}\n"
        return 1
    fi
}

# Function to handle git conflicts (always use newer)
resolve_conflicts() {
    cd "$GIT_REPO"

    # Check for conflicts
    if git ls-files -u | grep -q "$LIBRARY_FILE"; then
        log_message "Conflict detected in library file. Resolving by using newer version..."
        echo -e "${_y}⚠️  Conflict detected in library file${_0}"
        echo -e "${_m}🔄 Resolving by using newer version...${_0}"

        # Get modification times
        local_time=$(stat -f "%m" "djay/$LIBRARY_FILE")
        remote_time=$(stat -f "%m" "djay/$LIBRARY_FILE.REMOTE")

        if [[ $local_time -gt $remote_time ]]; then
            log_message "Using local version (newer)"
            echo -e "${_c}📤 Using local version (newer)${_0}"
            git checkout --ours "djay/$LIBRARY_FILE"
        else
            log_message "Using remote version (newer)"
            echo -e "${_c}📥 Using remote version (newer)${_0}"
            git checkout --theirs "djay/$LIBRARY_FILE"
        fi

        # Mark as resolved
        git add "djay/$LIBRARY_FILE"
        git commit -m "Resolve conflict: Use newer library file"
        log_message "Conflict resolved"
        echo -e "${_g}✅ Conflict resolved${_0}\n"
    fi
}

# Function to sync with remote (if configured)
sync_with_remote() {
    cd "$GIT_REPO"

    # Check if remote is configured
    if git remote -v | grep -q origin; then
        log_message "Syncing with remote repository..."
        echo -e "${_m}🌐 Syncing with remote repository...${_0}"

        # Pull changes
        if git pull origin main 2>&1 | tee -a "$LOG_FILE"; then
            log_message "Successfully pulled from remote"
            echo -e "${_g}✅ Successfully pulled from remote${_0}"
        else
            log_message "WARNING: Pull failed, attempting to resolve conflicts"
            echo -e "${_y}⚠️  Pull failed, attempting to resolve conflicts${_0}"
            resolve_conflicts
        fi

        # Push changes
        if git push origin main 2>&1 | tee -a "$LOG_FILE"; then
            log_message "Successfully pushed to remote"
            echo -e "${_g}✅ Successfully pushed to remote${_0}"
        else
            log_message "WARNING: Push failed"
            echo -e "${_y}⚠️  Push failed${_0}"
        fi
    else
        log_message "No remote repository configured. Use 'git remote add origin <url>' to add one."
        echo -e "${_y}⚠️  No remote repository configured${_0}"
        echo -e "${_c}💡 Use 'git remote add origin <url>' to add one${_0}"
    fi
    echo ""
}

# Function to restore files from git repo
restore_from_git_repo() {
    log_message "Restoring djay files from git repository"
    echo -e "${_m}📥 Restoring djay files from git repository...${_0}"

    # Check if djay is running
    if pgrep -x "djay" > /dev/null; then
        log_message "WARNING: djay Pro is running. Please quit djay Pro before restoring."
        echo -e "\n${_y}⚠️  djay Pro is running${_0}"
        echo "${_y}⚠️  Please quit djay Pro and run this script again${_0}\n"
        return 1
    fi

    # Backup current files
    if [[ -d "$DJAY_PATH" ]]; then
        backup_dir="$HOME/Documents/djay_backup_$(date '+%Y%m%d_%H%M%S')"
        cp -R "$DJAY_PATH" "$backup_dir"
        log_message "Backup created at $backup_dir"
        echo -e "${_c}💾 Backup created at $backup_dir${_0}"
    fi

    # Restore from git repo
    if [[ -e "$GIT_REPO/djay/$LIBRARY_FILE" ]]; then
        mkdir -p "$DJAY_PATH"
        cp -R "$GIT_REPO/djay/$LIBRARY_FILE" "$DJAY_PATH/"
        log_message "Library file restored"
        echo -e "${_g}✅ Library file restored${_0}"
    fi

    # Restore other folders
    for folder in "Key Bindings" "MIDI Mappings"; do
        if [[ -d "$GIT_REPO/djay/$folder" ]]; then
            cp -R "$GIT_REPO/djay/$folder" "$DJAY_PATH/"
            log_message "Folder '$folder' restored"
            echo -e "${_g}✅ $folder restored${_0}"
        fi
    done
    echo ""
}

# Main script
main() {
    log_message "=== djay Pro Git Sync Started ==="
    echo -e "${_m}🎵 djay Pro Git Sync Started${_0}\n"

    # Check if djay directory exists
    if [[ ! -d "$DJAY_PATH" ]]; then
        log_message "ERROR: djay directory not found at $DJAY_PATH"
        echo -e "${_r}❌ djay directory not found at $DJAY_PATH${_0}"
        echo -e "${_y}⚠️  Please check the path${_0}\n"
        exit 1
    fi

    # Initialize git repository
    init_git_repo

    # Copy files to git repo
    copy_to_git_repo

    # Commit changes
    commit_changes

    # Sync with remote (if configured)
    sync_with_remote

    # Show current status
    echo -e "${_g}📊 Current git repository status:${_0}"
    cd "$GIT_REPO"
    git status --short

    log_message "=== djay Pro Git Sync Completed ==="
    echo -e "\n${_g}✅ djay Pro Git Sync Completed${_0}\n"
}

# Parse command line arguments
case "${1:-sync}" in
    "sync")
        main
        ;;
    "restore")
        restore_from_git_repo
        ;;
    "init")
        init_git_repo
        ;;
    "status")
        cd "$GIT_REPO" && git status
        ;;
    "help")
        echo -e "${_m}🎵 djay Pro Git Sync - Help${_0}\n"
        echo "Usage: $0 [command]"
        echo ""
        echo -e "${_g}Commands:${_0}"
        echo "  sync    - Sync current djay files to git repo"
        echo "  restore - Restore djay files from git repo"
        echo "  init    - Initialize git repository"
        echo "  status  - Show git repository status"
        echo "  help    - Show this help message"
        echo ""
        echo -e "${_c}Examples:${_0}"
        echo "  $0 sync    # Sync current djay files to git repo"
        echo "  $0 restore # Restore djay files from git repo"
        echo "  $0 init    # Initialize git repository"
        echo "  $0 status  # Show git repository status"
        echo ""
        ;;
    *)
        echo -e "${_r}❌ Invalid command: $1${_0}\n"
        echo "Usage: $0 [sync|restore|init|status|help]"
        echo -e "${_g}Commands:${_0}"
        echo "  sync    - Sync current djay files to git repo"
        echo "  restore - Restore djay files from git repo"
        echo "  init    - Initialize git repository"
        echo "  status  - Show git repository status"
        echo "  help    - Show detailed help"
        echo ""
        exit 1
        ;;
esac
