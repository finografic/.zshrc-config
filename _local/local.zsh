# UNIVERSAL 
PROJECTS="$HOME/dev_projects"
alias dev="cd $PROJECTS && l"
alias www="cd /var/www && l"

# LOCAL: DEV
alias da2="cd $PROJECTS/da2 && l";
alias cv="cd $PROJECTS/cv && l"
alias rock="cd $PROJECTS/devilbox/data/www/rock01baby && l"
alias oh="cd $PROJECTS/app-test/ && l"
alias app="cd $PROJECTS/app-axios/ && l"
alias imatch="cd $PROJECTS/app-imatchination/ && l"
alias jst="cd $PROJECTS/js-learning/src/ && l"
alias green="cd $PROJECTS/greenPower/ && l"

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

DISP_INT="eDP-1-1"
DISP_EXT="HDMI-1-1"
export BRIGHTNESS=1.4

# DISPLAY: INTERNAL / LAPTOP
xrandr --output ${DISP_INT} --gamma 1.0:1.0:1.0
xrandr --output ${DISP_INT} --brightness $BRIGHTNESS
# DISPLAY: EXTERNAL / HDMI
xrandr --output ${DISP_EXT} --gamma 0.9:0.9:0.9
xrandr --output ${DISP_EXT} --brightness 1.0

# SET BRIGHTNESS: HDMI-1
bright() { 
  xrandr --output ${DISP_INT} --brightness $@;
}

brightx() { 
  xrandr --output ${DISP_EXT} --brightness $@;
}
