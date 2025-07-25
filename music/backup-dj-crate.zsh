#!/bin/zsh

set -euo pipefail

# Function to strip ANSI color codes
strip_colors() {
  sed 's/\x1b\[[0-9;]*m//g'
}

backup_music() {
  local FOLDER_NAME="_DJ-CRATE"
  local SOURCE="/Volumes/SSD.MUSIC/${FOLDER_NAME}"
  local DEST="/Volumes/timemachine-music/${FOLDER_NAME} backups"
  local LATEST="${DEST}/latest"
  local DATE=$(date +%Y-%m-%d_%H-%M-%S)
  local BACKUP="${DEST}/${DATE}"
  local LOG="${DEST}/backup.log"

  # Ensure source exists
  if [ ! -d "${SOURCE}" ]; then
    msg="Source volume not mounted: ${SOURCE}"
    echo "$msg" | tee >(strip_colors >> "${LOG}")
    return 1
  fi

  # Ensure destination exists and set up initial icon
  if [ ! -d "${DEST}" ]; then
    mkdir -p "${DEST}"
    # Copy icon from script directory to destination and set it
    if [ -f "./Icon?-_DJ-BAG" ]; then
      cp -a "./Icon?-_DJ-BAG" "${DEST}/Icon?"
      SetFile -a C "${DEST}"
    fi
  fi

  # Start logging
  msg="${_c}Starting backup at $(date)...${_0}\n"
  echo -e "$msg" | tee >(strip_colors >> "${LOG}")

  # Create new backup using hard links to previous backup for unchanged files
  rsync -av --delete \
    -E \
    --link-dest="${LATEST}" \
    "${SOURCE}/" \
    "${BACKUP}" 2>&1 | tee >(strip_colors >> "${LOG}")

  # Update 'latest' symlink and set icons
  if [ $? -eq 0 ]; then
    rm -f "${LATEST}"
    ln -s "${BACKUP}" "${LATEST}"

    # Copy and set icon for the new backup directory
    if [ -f "./Icon?" ]; then
      cp -a "./Icon?" "${BACKUP}/Icon?"
      SetFile -a C "${BACKUP}"
    fi

    msg="\n${_g}✅ Backup completed successfully at $(date)${_0}\n"
    echo -e "$msg" | tee >(strip_colors >> "${LOG}")
  else
    msg="\n${_r}❌ Backup failed at $(date)!${_0}\n"
    echo -e "$msg" | tee >(strip_colors >> "${LOG}")
    return 1
  fi

  # Cleanup old backups (keep last 30 days)
  find "${DEST}" -maxdepth 1 -type d -mtime +30 -name "20*" -exec rm -rf {} \;
}

# Run the backup
# backup_music

# <!-- ~/Library/LaunchAgents/com.user.dj-crate-backup.plist -->
# <?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
# <dict>
#     <key>Label</key>
#     <string>com.user.dj-crate-backup.plist</string>
#     <key>ProgramArguments</key>
#     <array>
#         <string>/bin/zsh</string>
#         <string>/Users/REDACTED/.zshrc-config/music/backup-dj-crate.zsh</string>
#     </array>
#     <key>StartCalendarInterval</key>
#     <dict>
#         <key>Hour</key>
#         <integer>4</integer>
#         <key>Minute</key>
#         <integer>0</integer>
#         <key>Weekday</key>
#         <integer>1</integer>
#     </dict>
#     <key>StandardOutPath</key>
#     <string>/tmp/musicbackup.log</string>
#     <key>StandardErrorPath</key>
#     <string>/tmp/musicbackup.err</string>
# </dict>
# </plist>

# 1.
# Save as ~/music/backup-dj-crate.zsh
# chmod +x ~/music/backup-dj-crate.zsh

# 2.
# Save plist to ~/Library/LaunchAgents/com.user.dj-crate-backup.plist
# launchctl load ~/Library/LaunchAgents/com.user.dj-crate-backup.plist

# 3.
# ~/music/backup-dj-crate.zsh
