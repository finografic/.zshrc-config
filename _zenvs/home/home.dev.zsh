# PLAYGROUND + SANDBOX
alias play="cd $PROJECTS/___PLAYGROUND___ && l"

# PROJECTS
# alias da2="cd $PROJECTS/da2 && l"
alias cv="cd $PROJECTS/cv && l"
alias cv2="cd $PROJECTS/___CV2-DEV___/cv-justin-rankin && l"
alias rock="cd $PROJECTS/devilbox-rock01baby/data/www/rock01baby && l"
alias gbd="cd $PROJECTS/devilbox/data/www/girlsbitedogs && l"
alias gbda="cd $PROJECTS/admin.girlsbitedogs.com && l"
# alias jod="cd $PROJECTS/devilbox/data/www/JODHPUR && l"
alias oh="cd $PROJECTS/app-test/ && l"
alias app="cd $PROJECTS/app-axios/ && l"
# alias imatch="cd $PROJECTS/app-imatchination/ && l"
alias jst="cd $PROJECTS/js-learning/src/ && l"
# alias green="cd $PROJECTS/greenPower/ && l"
alias cratez="cd $PROJECTS/cratez/ && l"
alias pilot="cd $PROJECTS/auto-pilot/ && l"
alias esm="cd $PROJECTS/starter-esm/ && l"
alias apps="cd $HOME/.local/share/applications/ && l"

# REMOTE: A2 HOSTING
alias a2="ssh -R 52698:localhost:52698 REDACTED-IP -p 7822 -l REDACTED-CODENAME"
alias a2rock="ssh -R 52698:localhost:52698 REDACTED-IP -p 7822 -l REDACTED-CODENAME"

# DEVILBOX
devil() {
    PWD=`pwd`
    # START UP DEVILBOX
    if [[ $@ == "ini" || $@ == "init" ]] then
        cd $PROJECTS/devilbox && l
        # ORIGNAL
        service apache2 stop
        service mysql stop
        # GO, UP !!
        docker-compose up httpd php mysql
        # ENTER MAIN DOCKER CONTAINER (PHP)
        elif [[ $@ == "cli" ]] then
        cd $PROJECTS/devilbox && l
        ./shell.sh
        # DEFAULT: CD + LIST
        elif [[ $@ == "stop" || $@ == "clean" ]] then
        # NEW
        docker-compose down
        docker system prune
        docker network prune
    else
        msg warn "OPTIONAL ARGS" # use my MSG FUNCTION
        echo "${_0}${_w}ini, init ${_y}- start up devilbox${_0}"
        echo "${_w}cli       ${_y}- enter main docker container (php)${_0}"
        echo "\n${_0}"
        cd $PROJECTS/devilbox && l
    fi
}

git config --global color.ui true
git config --global user.name "Justin"
git config --global user.email "justin.blair.rankin@gmail.com"
git config --global credential.helper 'cache --timeout=1209600' # TWO WEEKS!
