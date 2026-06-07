# ADD A DOCK SPACER
function spacer() {
  if [[ "$1" == "new" ]]; then
    defaults write com.apple.dock persistent-apps -array-add \
      '{"tile-data"={"file-label"="";};"tile-type"="small-spacer-tile";}'

    killall Dock

    echo "✓ Added spacer"
    return
  fi

  echo "Dock spacers:"
  defaults read com.apple.dock persistent-apps |
    grep -n "small-spacer-tile"
}
