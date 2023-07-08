export PROJECTS="$HOME/repos"

# UNIVERSAL - DEV ALIAS TO **CURRENT** PROJECT
alias dev="echo 'CHOOSE AN ALIAS!'"

# PROJECTS
PROJECTS="$HOME/repos"
alias repos="cd $PROJECTS && l"
alias misc="cd $HOME/repos-misc && l"
alias apps="cd $HOME/repos-apps && l"
alias my="cd $HOME/repos-my && l"

alias api="cd $HOME/repos-apnaes/apnaes-api && l"
alias web="cd $HOME/repos-apnaes/apnaes-web-admin && l"
alias admin="cd $HOME/repos-apnaes/apnaes-web-admin && l"

alias loupe="cd $HOME/.local/share/Loupedeck && ls -lAh"
alias luup="cd $HOME/.local/share/Loupedeck && ls -lAh"

alias chat="cd $HOME/repos-apnaes/feathers-chat-ts && l"
alias api2="cd $HOME/repos-apnaes/apnaes-api-ts-V2 && l"

# REMOTE: A2 HOSTING
alias a2="ssh -R 52698:localhost:52698 REDACTED-IP -p 7822 -l REDACTED-CODENAME"

# COMMANDS

function repos() {
  # msg err "PLEASE USE ALIAS 'dev'" # use my MSG FUNCTION
  # MOVED !!
  cd "$PROJECTS" && l;
}

# NOTE: OVERRIDES COMMON git commit WITH ADD + COMMENT...
function _gc() {
  # _gcache; # TODO: NEEDED / USEFUL ??
  if [[ $1 > "" ]]; then
      message="$1"
      # git add -A :/ # NOTE: REMOVED FOR SAFETY
      git add . && git commit -m "$message"
  else
    # NOTE: DON'T USE FOR OFFICE - DO NOTHING HERE !!
    # message="Commit all changes"
    echo "\n${_y}⚠️   NO COMMIT MESSAGE SUPPLIED\n";
  fi
}

function npmi() {
  if [[ -n "$@" ]]; then
    # ARGS PASSED: INSTALL PACKAGES AND UPDATE package-lock.json
    git update-index --no-assume-unchanged -- package-lock.json
    npm install $@;
    git status;
  else
    # NO ARGS: INSTALL DEFAULT PACKAGES TEMP IGNORE package-lock.json
    npm install;
    git update-index --assume-unchanged -- package-lock.json;
    git status;
  fi;
}
