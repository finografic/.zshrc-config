export REPOS="$HOME/repos"

# UNIVERSAL - DEV ALIAS TO **CURRENT** REPO
alias dev="echo 'CHOOSE AN ALIAS!'"

# REPOS
REPOS="$HOME/repos"
alias repos="cd $REPOS && l"
alias misc="cd $HOME/repos-misc && l"
alias apps="cd $HOME/repos-apps && l"
alias my="cd $HOME/repos-my && l"

# COMMANDS
function repos() {
  # msg err "PLEASE USE ALIAS 'dev'" # use my MSG FUNCTION
  # MOVED !!
  cd "$REPOS" && l
}
