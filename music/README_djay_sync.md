# djay Pro Playlist Sync Solutions

This repository contains three different solutions for syncing djay Pro playlists between multiple Macs, since the app's built-in iCloud sync doesn't work for playlists.

## Problem

- djay Pro supports iCloud sync but **doesn't sync playlists**
- The main database file `djay Media Library.djayMediaLibrary` contains all playlist data
- This is a binary file, so git merge conflicts are problematic
- Need a solution that always uses the newer version when conflicts occur

## Solutions

### 1. **iCloud Drive Sync** (`djay_icloud_sync.sh`) - **RECOMMENDED**

**Best for:** Most users who want simple, reliable sync using existing iCloud Drive.

**How it works:**
- Uses the existing iCloud Drive structure (as seen in your screenshots)
- Compares file timestamps to determine which version is newer
- Always overwrites with the newer version
- Creates automatic backups before overwriting

**Setup:**

```bash
# Make script executable
chmod +x djay_icloud_sync.sh

# Check current status
./djay_icloud_sync.sh status

# Initial sync
./djay_icloud_sync.sh sync

# Setup automatic sync every 5 minutes
./djay_icloud_sync.sh setup-auto
```

**Usage:**

```bash
./djay_icloud_sync.sh [command]
# Commands:
#   sync        - Sync both directions
#   to-icloud   - Sync local files to iCloud
#   from-icloud - Sync iCloud files to local
#   status      - Show sync status
#   setup-auto  - Setup automatic sync every 5 minutes
```

### 2. **Git-based Sync** (`djay_git_sync.sh`)

**Best for:** Users who want version control and can handle git setup.

**How it works:**
- Uses git for version control
- Handles binary file conflicts by always using newer version
- Provides full history of changes
- Can use GitHub, GitLab, or any git remote

**Setup:**

```bash
# Make script executable
chmod +x djay_git_sync.sh

# Initialize git repository
./djay_git_sync.sh init

# Add remote repository (replace with your repo URL)
cd ~/Documents/djay_sync_repo
git remote add origin https://github.com/yourusername/djay-sync.git

# Initial sync
./djay_git_sync.sh sync
```

**Usage:**

```bash
./djay_git_sync.sh [command]
# Commands:
#   sync    - Sync current djay files to git repo
#   restore - Restore djay files from git repo
#   init    - Initialize git repository
#   status  - Show git repository status
```

### 3. **Basic File Sync** (`djay_sync.sh`)

**Best for:** Users who want manual control or need to sync between specific Macs.

**How it works:**
- Simple file copying with timestamp comparison
- Requires manual setup of source/destination paths
- Good for one-time syncs or specific scenarios

**Setup:**

```bash
# Make script executable
chmod +x djay_sync.sh

# Edit the script to configure source/destination paths
# Then run:
./djay_sync.sh
```

## File Structure

```
~/Music/djay/
├── djay Media Library.djayMediaLibrary  # Main database (contains playlists)
├── Key Bindings/                        # Custom keyboard shortcuts
└── MIDI Mappings/                       # MIDI controller mappings
```

## Important Notes

### Before Running Any Script

1. **Always quit djay Pro** before syncing
2. **Make sure you have backups** of your current library
3. **Test on one Mac first** before syncing to multiple machines

### Conflict Resolution

- All scripts use **timestamp-based conflict resolution**
- The **newer file always wins**
- **Automatic backups** are created before overwriting

### iCloud Drive Structure

Based on your screenshots, the iCloud Drive structure is:

```
~/Library/Mobile Documents/com~apple~CloudDocs/djay/
├── djay Media Library.djayMediaLibrary
├── Key Bindings/
└── MIDI Mappings/
```

## Troubleshooting

### Common Issues

1. **"djay Pro is running" error:**
   - Quit djay Pro completely before running scripts

2. **"iCloud Drive not found" error:**
   - Enable iCloud Drive in System Preferences > Apple ID > iCloud

3. **"Permission denied" error:**
   - Make sure scripts are executable: `chmod +x *.sh`

4. **Sync not working:**
   - Check logs in `~/Documents/djay_sync.log`
   - Verify file paths are correct
   - Ensure iCloud Drive is syncing properly

### Manual Reset (if needed)

```bash
# Reset iCloud state for djay Pro (from the forum post you shared)
defaults write com.algoriddim.djay-iphone-free CMCResetCloudKitState -bool true
```

## Recommendations

1. **Start with iCloud Drive sync** - it's the simplest and uses your existing iCloud setup
2. **Test thoroughly** on one Mac before syncing to multiple machines
3. **Set up automatic sync** to keep files in sync without manual intervention
4. **Monitor the logs** to ensure sync is working properly

## Support

If you encounter issues:
1. Check the log files in `~/Documents/`
2. Verify djay Pro is completely quit
3. Ensure iCloud Drive is working properly
4. Test with a small library first

## License

These scripts are provided as-is for personal use. Always backup your data before using any sync solution.
