# djay Pro iCloud Sync Service

This service automatically syncs djay Pro files between your local machine and iCloud Drive, ensuring your music library, key bindings, and MIDI mappings stay synchronized across devices.

## What it syncs

- **djay Media Library.djayMediaLibrary** - The main music library (a macOS bundle/package)
- **Key Bindings** folder - Custom keyboard shortcuts
- **MIDI Mappings** folder - MIDI controller configurations
- **ios-transfer** folder - For iOS device synchronization

## Recent Fixes & Improvements (July 2025)

### 1. Bundle Timestamp Logic Enhancement

- **Issue**: Bundle timestamps weren't updating consistently during sync operations
- **Fix**: Implemented dual-mode timestamp updating:
  - **Mode 1**: When files are copied → Bundle timestamp matches newest internal file
  - **Mode 2**: When sync occurs but no copying → Bundle timestamp shows sync activity time
- **Result**: Clear distinction between data modification time and sync activity time

### 2. iOS Transfer Folder Integration

- **Issue**: `ios-transfer` folder wasn't included in main sync processes
- **Fix**: Added `ios-transfer` to the sync loop for both directions
- **Result**: iOS transfer folder now syncs automatically with the rest of the djay data

### 3. Service Frequency Optimization

- **Issue**: 5-minute sync interval was too frequent
- **Fix**: Changed from 5 minutes (300 seconds) to 15 minutes (900 seconds)
- **Result**: Reduced system load while maintaining good sync frequency

### 4. Log Location Migration

- **Issue**: Logs were stored in `~/Documents/` outside the repo
- **Fix**: Moved logs to `~/.zshrc-config/music/logs/` within the repo
- **Result**: Better organization and easier access to sync logs

### 5. Git Integration

- **Issue**: Log files could be accidentally committed
- **Fix**: Added `djay_icloud_sync.log` to `.gitignore`
- **Result**: Logs stay local and don't clutter the repository

### 6. Portable Path Configuration

- **Issue**: Hardcoded paths in plist files prevented multi-machine usage
- **Fix**: Used `$HOME` variable expansion for all paths in plist generation
- **Result**: Works seamlessly on different machines with different usernames

### 7. Rsync Detection Fix

- **Issue**: Script incorrectly reported "sync failed" when operations succeeded
- **Fix**: Improved rsync output parsing with proper file transfer indicators
- **Result**: Accurate status reporting and better debugging information

### 8. Enhanced Messaging

- **Issue**: Command output was verbose and unclear
- **Fix**: Streamlined messages to be concise and informative
- **Result**: Clear, actionable feedback for users

## Commands

### Manual Sync

```bash
djay sync          # Sync both directions
djay up            # Upload to iCloud only
djay down          # Download from iCloud only
djay status        # Check sync status
djay logs          # View recent logs
```

### Service Management

```bash
djay agent-start   # Enable automatic sync (every 15 minutes)
djay agent-stop    # Disable automatic sync
djay agent-status  # Check service status
```

### iOS Export

```bash
djay export-ios    # Export library for iOS import
```

## Technical Details

### Bundle/Package Files

The `djay Media Library.djayMediaLibrary` is a **macOS bundle** (also called a package). This is a directory that appears as a single file in Finder. The sync script now properly handles timestamp updates for these bundle files with intelligent logic:

- **When files are copied**: Bundle timestamp reflects the actual data modification time
- **When sync occurs without copying**: Bundle timestamp shows when the sync operation occurred

### Automatic Sync

- **Interval**: Every 15 minutes (900 seconds)
- **Service**: macOS LaunchAgent (`com.user.djay-sync.plist`)
- **Logs**: `~/.zshrc-config/music/logs/djay_icloud_sync.log`
- **Memory**: Minimal footprint, only runs when needed
- **Portable**: Uses `$HOME` variable for cross-machine compatibility

### Backup Protection

When downloading from iCloud, the script automatically creates a backup of your local library before overwriting it. Backups are stored in `~/Documents/` with timestamps.

### Timestamp Logic

The service intelligently manages timestamps to provide meaningful information:

- **Bundle timestamps**: Show either data modification time or sync activity time
- **Folder timestamps**: Always updated to show sync activity
- **Internal file timestamps**: Preserved to show actual data modification time

## Troubleshooting

### Service Not Running

```bash
djay agent-status  # Check if service is enabled
djay agent-start   # Restart the service
```

### Manual Sync Issues

```bash
djay status        # Check file timestamps
djay logs          # View recent activity
```

### Bundle Timestamp Issues

The script now automatically updates bundle timestamps with intelligent logic. If you still see issues:
1. Run `djay sync` manually
2. Check the logs for timestamp update messages
3. Verify the bundle shows appropriate time in Finder

### Cross-Machine Setup

The service automatically adapts to different usernames:
- **Home Mac** (`justin`): Automatically detected
- **Office Mac** (`REDACTED-USERNAME`): Automatically detected
- **Any future machine**: Will work without configuration changes

## File Structure

```
~/.zshrc-config/music/
├── djay_icloud_sync.zsh          # Main sync script
├── logs/
│   └── djay_icloud_sync.log      # Sync activity logs
└── README_djay_sync.md           # This file
```

## iCloud Structure

```
~/Library/Mobile Documents/com~apple~CloudDocs/djay/
├── djay Media Library.djayMediaLibrary/  # Main library bundle
├── Key Bindings/                         # Keyboard shortcuts
├── MIDI Mappings/                        # MIDI configurations
└── ios-transfer/                         # iOS export folder
```

## Performance & Resource Usage

### Memory Footprint

- **Service**: Zero persistent memory (only runs when triggered)
- **Sync operations**: ~2-5 MB RAM during execution
- **Frequency impact**: 15-minute intervals reduce resource usage by 3x compared to 5-minute intervals

### Sync Behavior

- **Smart detection**: Only copies files when they differ
- **Timestamp preservation**: Maintains meaningful timestamps for debugging
- **Efficient operations**: Uses rsync for optimized file transfers
