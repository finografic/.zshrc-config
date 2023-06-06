export PROJECTS="$HOME/repos"

# UNIVERSAL - DEV ALIAS TO **CURRENT** PROJECT
alias dev="echo 'CHOOSE AN ALIAS!'"

# PROJECTS
PROJECTS="$HOME/repos"
alias repos="cd $PROJECTS && l"
alias misc="cd $HOME/repos-misc && l"
alias apps="cd $HOME/repos-apps && l"
alias my="cd $HOME/repos-my && l"

# COMMANDS

# JEST - UNIT TESTING ALIAS !!!
# from: { index.js}
# to: { Component.js, package.json }
function j() {
  if [[ "$1" > "" ]] then
      jest "$1" --watch -t "$2";
  else
      npm run test:coverage -- --maxWorkers=4
  fi
}

function repos() {
  # msg err "PLEASE USE ALIAS 'dev'" # use my MSG FUNCTION
  # MOVED !!
  cd "$PROJECTS" && l;
}
