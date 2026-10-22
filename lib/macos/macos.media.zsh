source "$ZSHRC_ROOT/lib/colors.zsh"

# IMAGES
function convert-heic() {
  for f in *.heic; do
    echo "Working on file $f"
    heif-convert $f $f.jpg
  done
}

# VIDEO
function video-speed-v1() {
  if [[ -z "$2" ]]; then
    print -P "%F${_y}⚠ speed value is required, no changes made%f"
    return 1
  fi
  local speed="$2"
  ffmpeg -i "$1" -vf "setpts=PTS/${speed},fps=30" -an \
    -c:v libx264 -crf 28 -preset slow -movflags +faststart \
    "${1%.*}-x${speed}.mp4"
}

function video-speed() {
  if [[ -z "$2" ]]; then
    print -P "%F{yellow}⚠ speed value is required, no changes made%f"
    return 1
  fi
  local speed="$2"
  ffmpeg -i "$1" -vf "setpts=PTS/${speed},fps=30" -an \
    -c:v libx264 -crf 20 -preset slow -tune animation \
    -pix_fmt yuv420p -movflags +faststart \
    "${1%.*}-x${speed}.mp4"
}
