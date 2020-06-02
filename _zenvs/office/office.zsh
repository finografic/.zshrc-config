# SPECIFIC
export ZSH_CONFIG="$HOME/.zshrc-config"
export NVM="true"
export EDITOR_PREFERRED==/usr/bin/code
code () { /usr/share/code/code "$@"; }

# DIRCOLORS
[ -d "${HOME}/.dircolors" ] && eval `dircolors ${HOME}/.dircolors/dircolors-solarized-master/dircolors.ansi-dark`;

# SYSTEM
KEYBOARD_LAYOUT="us";
KEYBOARD_LAYOUT_EXT="es";
cd /media/justin/HD1TB_p1/ 2> /dev/null
cd /media/justin/HD1TB_p2/ 2> /dev/null

# UNIVERSAL
PROJECTS="$HOME/dev_projects"
alias dev="cd $PROJECTS && l"
alias www="cd /var/www && l"

# LOCAL: DEV
alias da2="cd $PROJECTS/da2 && l";
alias cv="cd $PROJECTS/cv && l"
alias rock="cd $PROJECTS/devilbox/data/www/rock01baby && l"
alias jod="cd $PROJECTS/devilbox/data/www/JODHPUR && l"
alias oh="cd $PROJECTS/app-test/ && l"
alias app="cd $PROJECTS/app-axios/ && l"
alias imatch="cd $PROJECTS/app-imatchination/ && l"
alias jst="cd $PROJECTS/js-learning/src/ && l"
alias green="cd $PROJECTS/greenPower/ && l"
alias cratez="cd $PROJECTS/cratez/ && l"
alias pilot="cd $PROJECTS/auto-pilot/ && l"
alias esm="cd $PROJECTS/starter-esm/ && l"
# REMOTE: A2 HOSTING
# alias a2="ssh -p 7822 67.209.azs115.154 -l ubuntu"
alias a2="ssh -R 52698:localhost:52698 REDACTED-IP -p 7822 -l ubuntu"

# DEPRECATED !
repos() {
    # msg err "PLEASE USE ALIAS 'dev'" # use my MSG FUNCTION
    # MOVED !!
    cd "$HOME/dev_repos" && l
}



# DEVILBOX
devil() {
    PWD=`pwd`
    # START UP DEVILBOX
    if [[ $@ == "ini" || $@ == "init" ]] then
        cd $PROJECTS/devilbox && l
        service apache2 stop
        service mysql stop
        sudo docker-compose up httpd php mysql
        # sudo docker-compose up httpd php # mysql
        # ENTER MAIN DOCKER CONTAINER (PHP)
        elif [[ $@ == "cli" ]] then
        cd $PROJECTS/devilbox && l
        ./shell.sh
        # DEFAULT: CD + LIST
    else
        msg warn "OPTIONAL ARGS" # use my MSG FUNCTION
        echo "${_0}${_w}ini, init ${_y}- start up devilbox${_0}"
        echo "${_w}cli       ${_y}- enter main docker container (php)${_0}"
        echo "\n${_0}"
        cd $PROJECTS/devilbox && l
    fi
}

# LOCAL-ONLY SYS ALIASES
alias sys="systemsettings5" # K/UBUNTU ONLY

DISPLAY_MAIN="eDP-1-1"
DISPLAY_EXT="HDMI-1-1"
export BRIGHTNESS=1.4
