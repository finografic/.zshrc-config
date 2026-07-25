#!/bin/zsh

# Source colors (for standalone execution via launchctl)
source ~/.zshrc-config/lib/colors.zsh

# Set locale to handle special characters
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Function to strip ANSI color codes
function djay-strip-colors() {
  sed 's/\x1b\[[0-9;]*m//g'
}

function djay-backup-music() {
  # Set locale for proper character encoding
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8

  local FOLDER_NAME="_DJ-CRATE"
  local SOURCE="/Volumes/SSD.MUSIC/${FOLDER_NAME}"
  local DEST="/Volumes/timemachine-music/${FOLDER_NAME} backups"
  local LATEST="${DEST}/latest"
  local DATE=$(date +%Y-%m-%d_%H-%M-%S)
  local BACKUP="${DEST}/${DATE}"
  local LOGS_DIR="${DEST}/logs"
  local LOG="${LOGS_DIR}/backup-$(date +%Y-%m-%d-%Hh%M).log"

  # Ensure source exists
  if [ ! -d "${SOURCE}" ]; then
    msg="Source volume not mounted: ${SOURCE}"
    echo "$msg" | tee >(djay-strip-colors >> "${LOG}")
    return 1
  fi

  # Ensure destination and logs directory exist
  if [ ! -d "${DEST}" ]; then
    mkdir -p "${DEST}"
    mkdir -p "${LOGS_DIR}"
    # Copy icon from script directory to destination and set it
    if [ -f "./Icon?" ]; then
      cp -a "./Icon?" "${DEST}/Icon?"
      SetFile -a C "${DEST}"
    fi
  fi

  # Create logs directory if it doesn't exist
  mkdir -p "${LOGS_DIR}"

  # Start backup
  msg="\n${_m}🎵 Starting backup of ${FOLDER_NAME} at $(date)${_0}\n"
  echo -e "$msg" | tee >(djay-strip-colors >> "${LOG}")

  # Create new backup using cp for better character handling
  mkdir -p "${BACKUP}"

  # Use find and cp to handle special characters better
  find "${SOURCE}" -type f -print0 | while IFS= read -r -d '' file; do
    rel_path="${file#$SOURCE/}"
    dest_file="${BACKUP}/${rel_path}"
    dest_dir=$(dirname "$dest_file")

    # Create destination directory
    mkdir -p "$dest_dir"

    # Check if we can hard link from previous backup
    if [[ -n "${LATEST}" && -L "${LATEST}" ]]; then
      prev_file="${LATEST}/${rel_path}"
      if [[ -f "$prev_file" ]]; then
        # Try to hard link first
        if ln "$prev_file" "$dest_file" 2>/dev/null; then
          echo "Hard linked: $rel_path" | tee >(djay-strip-colors >> "${LOG}")
          continue
        fi
      fi
    fi

    # Copy the file
    if cp "$file" "$dest_file" 2>/dev/null; then
      echo "Copied: $rel_path" | tee >(djay-strip-colors >> "${LOG}")
    else
      echo "Failed to copy: $rel_path" | tee >(djay-strip-colors >> "${LOG}")
    fi
  done

  local copy_exit_code=$?

  # Update 'latest' symlink and set icons
  if [ $copy_exit_code -eq 0 ]; then
    # Remove old symlink if it exists
    rm -f "${LATEST}"
    # Create new symlink to the backup we just created
    ln -s "${BACKUP}" "${LATEST}"

    # Copy and set icon for the new backup directory
    if [ -f "./Icon?" ]; then
      cp -a "./Icon?" "${BACKUP}/Icon?"
      SetFile -a C "${BACKUP}"
    fi

    # Apply custom icons to all subdirectories that have Icon? files
    echo -e "\n${_m}🎨 Applying custom folder icons...${_0}"
    find "${BACKUP}" -name "Icon?" -type f | while read -r icon_file; do
      parent_dir=$(dirname "$icon_file")
      parent_name=$(basename "$parent_dir")
      if SetFile -a C "$parent_dir" 2>/dev/null; then
        echo -e "  ${_g}✅ Applied icon to: $parent_name${_0}"
      fi
    done

    msg="\n${_g}✅ Backup completed successfully at $(date)${_0}\n"
    echo -e "$msg" | tee >(djay-strip-colors >> "${LOG}")
  else
    msg="\n${_r}❌ Backup failed at $(date)!${_0}\n"
    echo -e "$msg" | tee >(djay-strip-colors >> "${LOG}")
    return 1
  fi

  # Cleanup old backups (keep last 30 days)
  find "${DEST}" -maxdepth 1 -type d -mtime +30 -name "20*" -exec rm -rf {} \;
}

# Run the backup
# djay-backup-music

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
#         <string>__HOME__/.zshrc-config/extras/music/backup-dj-crate.zsh</string>
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
