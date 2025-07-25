#!/bin/bash

# djay Pro Git-based Sync Script
# This script uses git to sync djay Pro files between Macs
# Handles binary file conflicts by always using the newer version

# Configuration
DJAY_PATH="$HOME/Music/djay"
LIBRARY_FILE="djay Media Library.djayMediaLibrary"
GIT_REPO="$HOME/Documents/djay_sync_repo"
LOG_FILE="$HOME/Documents/djay_git_sync.log"

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

# Function to initialize git repository
init_git_repo() {
    if [ ! -d "$GIT_REPO" ]; then
        log_message "Initializing git repository at $GIT_REPO"
        mkdir -p "$GIT_REPO"
        cd "$GIT_REPO"
        git init
        echo "*.djayMediaLibrary binary" > .gitattributes
        echo "*.log" >> .gitignore
        echo "*.tmp" >> .gitignore
        git add .gitattributes .gitignore
        git commit -m "Initial commit: Add gitattributes and gitignore"
        log_message "Git repository initialized"
    fi
}

# Function to copy files to git repo
copy_to_git_repo() {
    log_message "Copying djay files to git repository"

    # Create djay directory in git repo
    mkdir -p "$GIT_REPO/djay"

    # Copy library file/directory
    if [ -e "$DJAY_PATH/$LIBRARY_FILE" ]; then
        cp -R "$DJAY_PATH/$LIBRARY_FILE" "$GIT_REPO/djay/"
        log_message "Library file copied to git repo"
    else
        log_message "WARNING: Library file not found at source"
    fi

    # Copy other folders
    for folder in "Key Bindings" "MIDI Mappings"; do
        if [ -d "$DJAY_PATH/$folder" ]; then
            cp -R "$DJAY_PATH/$folder" "$GIT_REPO/djay/"
            log_message "Folder '$folder' copied to git repo"
        fi
    done
}

# Function to commit changes
commit_changes() {
    cd "$GIT_REPO"

    # Check if there are changes
    if git diff --quiet && git diff --cached --quiet; then
        log_message "No changes to commit"
        return 0
    fi

    # Add all files
    git add .

    # Get file modification time for commit message
    if [ -e "djay/$LIBRARY_FILE" ]; then
        mod_time=$(stat -f "%m" "djay/$LIBRARY_FILE")
        commit_msg="Update djay library - $(date -r $mod_time '+%Y-%m-%d %H:%M:%S')"
    else
        commit_msg="Update djay files - $(date '+%Y-%m-%d %H:%M:%S')"
    fi

    # Commit
    if git commit -m "$commit_msg"; then
        log_message "Changes committed: $commit_msg"
    else
        log_message "ERROR: Failed to commit changes"
        return 1
    fi
}

# Function to handle git conflicts (always use newer)
resolve_conflicts() {
    cd "$GIT_REPO"

    # Check for conflicts
    if git ls-files -u | grep -q "$LIBRARY_FILE"; then
        log_message "Conflict detected in library file. Resolving by using newer version..."

        # Get modification times
        local_time=$(stat -f "%m" "djay/$LIBRARY_FILE")
        remote_time=$(stat -f "%m" "djay/$LIBRARY_FILE.REMOTE")

        if [ $local_time -gt $remote_time ]; then
            log_message "Using local version (newer)"
            git checkout --ours "djay/$LIBRARY_FILE"
        else
            log_message "Using remote version (newer)"
            git checkout --theirs "djay/$LIBRARY_FILE"
        fi

        # Mark as resolved
        git add "djay/$LIBRARY_FILE"
        git commit -m "Resolve conflict: Use newer library file"
        log_message "Conflict resolved"
    fi
}

# Function to sync with remote (if configured)
sync_with_remote() {
    cd "$GIT_REPO"

    # Check if remote is configured
    if git remote -v | grep -q origin; then
        log_message "Syncing with remote repository..."

        # Pull changes
        if git pull origin main 2>&1 | tee -a "$LOG_FILE"; then
            log_message "Successfully pulled from remote"
        else
            log_message "WARNING: Pull failed, attempting to resolve conflicts"
            resolve_conflicts
        fi

        # Push changes
        if git push origin main 2>&1 | tee -a "$LOG_FILE"; then
            log_message "Successfully pushed to remote"
        else
            log_message "WARNING: Push failed"
        fi
    else
        log_message "No remote repository configured. Use 'git remote add origin <url>' to add one."
    fi
}

# Function to restore files from git repo
restore_from_git_repo() {
    log_message "Restoring djay files from git repository"

    # Check if djay is running
    if pgrep -x "djay" > /dev/null; then
        log_message "WARNING: djay Pro is running. Please quit djay Pro before restoring."
        echo -e "${YELLOW}Please quit djay Pro and run this script again.${NC}"
        return 1
    fi

    # Backup current files
    if [ -d "$DJAY_PATH" ]; then
        backup_dir="$HOME/Documents/djay_backup_$(date '+%Y%m%d_%H%M%S')"
        cp -R "$DJAY_PATH" "$backup_dir"
        log_message "Backup created at $backup_dir"
    fi

    # Restore from git repo
    if [ -e "$GIT_REPO/djay/$LIBRARY_FILE" ]; then
        mkdir -p "$DJAY_PATH"
        cp -R "$GIT_REPO/djay/$LIBRARY_FILE" "$DJAY_PATH/"
        log_message "Library file restored"
    fi

    # Restore other folders
    for folder in "Key Bindings" "MIDI Mappings"; do
        if [ -d "$GIT_REPO/djay/$folder" ]; then
            cp -R "$GIT_REPO/djay/$folder" "$DJAY_PATH/"
            log_message "Folder '$folder' restored"
        fi
    done
}

# Main script
main() {
    log_message "=== djay Pro Git Sync Started ==="

    # Check if djay directory exists
    if [ ! -d "$DJAY_PATH" ]; then
        log_message "ERROR: djay directory not found at $DJAY_PATH"
        echo -e "${RED}djay directory not found. Please check the path.${NC}"
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
    echo -e "${GREEN}Current git repository status:${NC}"
    cd "$GIT_REPO"
    git status --short

    log_message "=== djay Pro Git Sync Completed ==="
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
    *)
        echo "Usage: $0 [sync|restore|init|status]"
        echo "  sync    - Sync current djay files to git repo"
        echo "  restore - Restore djay files from git repo"
        echo "  init    - Initialize git repository"
        echo "  status  - Show git repository status"
        exit 1
        ;;
esac
