echo $_grey
echo "Cleaning Downloads..."
echo $_0

# IMPORTANT - DISABLE ZSH GLOB MATCH ERROR OUTPUT
setopt no_nomatch

# IGNORE THESE CACHES
declare -a FOLDERS_TO_CLEAN=(
  $HOME/Downloads/**/*.mp4.mp4
  $HOME/dwhelper/**/*.mp4.mp4
)

for file in "${FOLDERS_TO_CLEAN[@]}"; do
  $(mv $file "$(echo $file | sed -E 's/.mp4.mp4/.mp4/')" 2>/dev/null)
done

# FIREFOX CLEAN
# setopt extendedglob - CAUTION !!

PATH_FIREFOX_STORAGE="$HOME/Library/Application Support/Firefox/Profiles/3qn4h86i.dev-edition-default/storage/default"
PATH_FIREFOX_STORAGE_TEMP="$PATH_FIREFOX_STORAGE/__TEMP"

# BACKUP APP CONFIGS LOCATED IN $HOME/.config ================================ #

# IGNORE THESE CACHES
declare -a cleanIgnores=(
  "https+++mail.google.com"
  "https+++calendar.google.com"
  "https+++drive.google.com"
  "https+++www.youtube.com"
  "https+++www.bing.com"
)

[[ ! -d "$PATH_FIREFOX_STORAGE_TEMP" ]] && $(mkdir "$PATH_FIREFOX_STORAGE_TEMP" 2>/dev/null)

for ignored in "${cleanIgnores[@]}"; do
  [[ -d "$PATH_FIREFOX_STORAGE/$ignored" ]] && $(mv "$PATH_FIREFOX_STORAGE/$ignored" "$PATH_FIREFOX_STORAGE_TEMP" 2>/dev/null)
done

$(rm -fr "$PATH_FIREFOX_STORAGE"/https+++* 2>/dev/null)

# RETURN IGNORED
$(mv "$PATH_FIREFOX_STORAGE_TEMP"/* "$PATH_FIREFOX_STORAGE" 2>/dev/null)
$(rm -fr "$PATH_FIREFOX_STORAGE_TEMP" 2>/dev/null)

# IMPORTANT - RE-ENABLE ZSH GLOB MATCH ERROR OUTPUT
setopt nomatch
