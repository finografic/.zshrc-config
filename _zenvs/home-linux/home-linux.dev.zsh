# PLAYGROUND + SANDBOX
alias play="cd $REPOS/___PLAYGROUND___ && l"

# REPOS
# alias da2="cd $REPOS/da2 && l"
alias cv="cd $REPOS/cv && l"
alias oh="cd $REPOS/app-test/ && l"
alias app="cd $REPOS/app-axios/ && l"
# alias imatch="cd $REPOS/app-imatchination/ && l"
alias jst="cd $REPOS/js-learning/src/ && l"
alias cratez="cd $REPOS/cratez/ && l"
alias pilot="cd $REPOS/auto-pilot/ && l"
alias esm="cd $REPOS/starter-esm/ && l"
alias apps="cd $HOME/.local/share/applications/ && l"

# REMOTE: A2 HOSTING
alias a2="ssh -R 52698:localhost:52698 REDACTED-IP -p 7822 -l REDACTED-CODENAME"

# DEVILBOX
function devil() {
  PWD=$(pwd)
  # START UP DEVILBOX
  if [[ $@ == "ini" || $@ == "init" ]]; then
    cd $REPOS/devilbox && l
    # ORIGNAL
    service apache2 stop
    service mysql stop
    # GO, UP !!
    docker-compose up httpd php mysql
  # ENTER MAIN DOCKER CONTAINER (PHP)
  elif [[ $@ == "cli" ]]; then
    cd $REPOS/devilbox && l
    ./shell.sh
  # DEFAULT: CD + LIST
  elif [[ $@ == "stop" || $@ == "clean" ]]; then
    # NEW
    docker-compose down
    docker system prune
    docker network prune
  else
    msg warn "OPTIONAL ARGS" # use my MSG FUNCTION
    echo "${_0}${_w}ini, init ${_y}- start up devilbox${_0}"
    echo "${_w}cli       ${_y}- enter main docker container (php)${_0}"
    echo "\n${_0}"
    cd $REPOS/devilbox && l
  fi
}

git config --global color.ui true
git config --global user.name "Justin"
git config --global user.email "justin.blair.rankin@gmail.com"
git config --global credential.helper 'cache --timeout=1209600' # TWO WEEKS!
