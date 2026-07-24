export REPOS="$HOME/repos"

# UNIVERSAL - DEV ALIAS TO **CURRENT** REPO
alias dev="echo 'CHOOSE AN ALIAS!'"

# REPOS
REPOS="$HOME/repos"
alias repos="cd $REPOS && l"
alias misc="cd $HOME/repos-misc && l"
alias apps="cd $HOME/repos-apps && l"

# COMMANDS
function repos() {
  # MOVED !!
  cd "$REPOS" && l
}

@my() {
  cd "$HOME/repos-my" && l
}


