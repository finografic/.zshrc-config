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

# IMPORTANT - RE-ENABLE ZSH GLOB MATCH ERROR OUTPUT
setopt nomatch
