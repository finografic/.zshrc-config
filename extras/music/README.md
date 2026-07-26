# djay Pro Music Management Scripts

This directory contains scripts and services for managing djay Pro music library synchronization and backups.

## Overview

These scripts handle:

- **iCloud Sync**: Synchronizing djay Pro library between local machine and iCloud Drive
- **Time Machine Backup**: Automated backups of the `_DJ-CRATE` folder to Time Machine
- **Icon Management**: Utilities for maintaining custom folder icons in backups

## Scripts

### djay_icloud_sync.zsh

Main iCloud synchronization service for djay Pro files.

**Features:**

- Bidirectional sync between local and iCloud Drive
- Automatic model detection and timestamp management
- iOS export functionality
- LaunchAgent service for automatic syncing (every 15 minutes)

**Documentation:** See [README_djay_sync.md](./README_djay_sync.md) for detailed documentation.

**Usage:**

```bash
djay sync          # Sync both directions
djay up            # Upload to iCloud
djay down          # Download from iCloud
djay status        # Check sync status
djay agent-start   # Enable automatic sync
```

### backup-dj-crate.zsh

Time Machine backup service for the `_DJ-CRATE` music folder.

**Features:**

- Automated backups to Time Machine volume
- Hard linking for efficient storage
- Automatic cleanup (keeps last 30 days)
- Custom folder icon preservation
- Runs on startup and scheduled (Mon/Thu 4:00 AM)

**Service:** macOS LaunchAgent (`com.user.dj-crate-backup.plist`)

**Function:** `djay_backup_music()`

**Paths:**

- Source: `/Volumes/SSD.MUSIC/_DJ-CRATE`
- Destination: `/Volumes/timemachine-music/_DJ-CRATE backups`

### fix-backup-icons.zsh

Utility script to apply custom folder icons to backup directories.

**Usage:**

```bash
~/.zshrc-config/music/fix-backup-icons.zsh
```

## LaunchAgent Services

### com.user.dj-crate-backup.plist

**Location:** `~/Library/LaunchAgents/com.user.dj-crate-backup.plist`

**Schedule:**

- Runs on system startup/login (`RunAtLoad`)
- Every Monday at 4:00 AM
- Every Thursday at 4:00 AM

**Status:**

```bash
launchctl list | grep com.user.dj-crate-backup
```

### com.user.djay-sync.plist

**Location:** `~/Library/LaunchAgents/com.user.djay-sync.plist`

**Schedule:**

- Runs on system startup/login (`RunAtLoad`)
- Every 15 minutes (`StartInterval: 900`)

**Status:**

```bash
djay agent-status
```

## File Structure

```
~/.zshrc-config/music/
├── README.md                      # This file
├── README_djay_sync.md            # Detailed iCloud sync documentation
├── djay_icloud_sync.zsh           # Main iCloud sync script
├── backup-dj-crate.zsh             # Time Machine backup script
├── fix-backup-icons.zsh           # Icon fixing utility
├── com.user.dj-crate-backup.plist # Backup service plist template
└── logs/
    └── djay_icloud_sync.log       # Sync activity logs
```

## Installation & Setup

### Initial Setup

1. **iCloud Sync:**

   ```bash
   djay agent-start   # Enable automatic sync
   ```

2. **Time Machine Backup:**

   ```bash
   # Copy plist template to LaunchAgents
   cp ~/.zshrc-config/music/com.user.dj-crate-backup.plist \
      ~/Library/LaunchAgents/

   # Load the service
   launchctl load ~/Library/LaunchAgents/com.user.dj-crate-backup.plist
   ```

### Verification

Both services are automatically verified and loaded on terminal startup (via zsh config).

Check status:

```bash
# iCloud sync
djay agent-status

# Time Machine backup
launchctl list | grep com.user.dj-crate-backup
```

## Dependencies

- **macOS**: All scripts are macOS-specific
- **zsh**: Shell scripts require zsh
- **Colors**: Source `~/.zshrc-config/lib/colors.zsh` (automatically sourced)
- **External Tools**:
  - `rsync` - For efficient file syncing
  - `SetFile` - For custom folder icons (macOS Developer Tools)

## Notes

- All functions use `djay_` prefix for consistency
- Scripts are designed to work both standalone (via launchctl) and when sourced from zshrc
- Logs are stored in `logs/` directory and excluded from git
- Plist files in this directory are templates; actual services are in `~/Library/LaunchAgents/`

## Troubleshooting

See [README_djay_sync.md](./README_djay_sync.md) for detailed troubleshooting for the iCloud sync service.

For backup issues:

```bash
# Check if service is loaded
launchctl list | grep com.user.dj-crate-backup

# Check logs
tail -f /tmp/musicbackup.log
tail -f /tmp/musicbackup.err

# Manually run backup
~/.zshrc-config/music/backup-dj-crate.zsh
```

---

_Last Updated: December 2024_
