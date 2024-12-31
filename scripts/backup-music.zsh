#!/bin/zsh

backup_music() {
  local FOLDER_NAME="_DJ BAG"
  local SOURCE="/Volumes/SSD.MUSIC/${FOLDER_NAME}"
  local DEST="/Volumes/timemachine-music/${FOLDER_NAME} backups"
  local LATEST="${DEST}/latest"
  local DATE=$(date +%Y-%m-%d_%H-%M-%S)
  local BACKUP="${DEST}/${DATE}"
  local LOG="${DEST}/backup.log"

  # Ensure source exists
  if [ ! -d "${SOURCE}" ]; then
    echo "Source volume not mounted: ${SOURCE}" | tee -a "${LOG}"
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
  echo "${_c}Starting backup at $(date)...${_0}\n" | tee -a "${LOG}"

  # Create new backup using hard links to previous backup for unchanged files
  rsync -av --delete \
    -E \
    --link-dest="${LATEST}" \
    "${SOURCE}/" \
    "${BACKUP}" 2>&1 | tee -a "${LOG}"

  # Update 'latest' symlink and set icons
  if [ $? -eq 0 ]; then
    rm -f "${LATEST}"
    ln -s "${BACKUP}" "${LATEST}"

    # Copy and set icon for the new backup directory
    if [ -f "./Icon?" ]; then
      cp -a "./Icon?" "${BACKUP}/Icon?"
      SetFile -a C "${BACKUP}"
    fi

    # echo "\n\033[32m✅ Backup completed successfully\033[0m\n" | tee -a "${LOG}"
    echo "\n${_g}✅ Backup completed successfully${_0}\n" | tee -a "${LOG}"
  else
    # echo "\n\033[31m❌ Backup failed!\033[0m\n" | tee -a "${LOG}"
    echo "\n${_r}❌ Backup failed!${_0}\n" | tee -a "${LOG}"
    return 1
  fi

  # Cleanup old backups (keep last 30 days)
  find "${DEST}" -maxdepth 1 -type d -mtime +30 -name "20*" -exec rm -rf {} \;
}

# Run the backup
backup_music

# <!-- ~/Library/LaunchAgents/com.user.musicbackup.plist -->
# <?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
# <dict>
#     <key>Label</key>
#     <string>com.user.musicbackup</string>
#     <key>ProgramArguments</key>
#     <array>
#         <string>/bin/zsh</string>
#         <string>/Users/REDACTED/.zshrc-config/scripts/backup-music.zsh</string>
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
# Save as ~/scripts/backup-music.zsh
# chmod +x ~/scripts/backup-music.zsh

# 2.
# Save plist to ~/Library/LaunchAgents/com.user.musicbackup.plist
# launchctl load ~/Library/LaunchAgents/com.user.musicbackup.plist

# 3.
# ~/scripts/backup-music.zsh
