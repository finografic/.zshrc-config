PROJECTS="$HOME/dev_projects"

###############################
############  NPM  ############
###############################

run() {
  # requires "ntl" node package installed globally
  echo "\n";
  ntl --info --size 20;
}

# ALIASES THAT TAKE PARAMETERS
versions() {
  npm info "$1" versions
}

# NPM - GET PACKAGE VERSION
v() {
  CURRENT_VERSION=$($1 --version);
  LATEST_VERSION=$(latest-version $1);
  if [[ $CURRENT_VERSION < $LATEST_VERSION ]] then
    echo "\e[0mNewer version of \e[1m\e[36m$1\e[1m\e[0m available:";
    echo "\e[33m$CURRENT_VERSION\e[0m\e[37m --> \e[32m\e[1m$LATEST_VERSION";
  else
    echo "\e[1mCurrent version of \e[1m\e[36m$1\e[0m is up to date.";
    echo "\e[32m\e[1m$CURRENT_VERSION";
  fi
}

latest() {
  latest-version $1;
}

update() {

  # GET VERSIONS
  CURRENT_VERSION=$($1 --version);
  LATEST_VERSION=$(latest-version $1);

  # OUTPUT INFO
  if [[ $CURRENT_VERSION < $LATEST_VERSION ]] then
    echo "\e[0mNewer version of \e[1m\e[36m$1\e[1m\e[0m available:";
    echo "\e[33m$CURRENT_VERSION\e[0m\e[37m --> \e[32m\e[1m$LATEST_VERSION";
  else
    echo "\e[0mCurrent version of \e[1m\e[36m$1\e[0m is latest version.";
    echo "\e[32m\e[1m$CURRENT_VERSION";
  fi

  # UPDATE ??
  if [[ $CURRENT_VERSION < $LATEST_VERSION ]] then
    echo "\n\e[0mUpdating global package \e[1m\e[36m$1\e[1m\e[0m ...\n";
    npm i -g $1@$LATEST_VERSION;
  fi
}

###############################
############  NODE  ###########
###############################

alias kn='killall -9 node'




##################################
##########  GIT REMOTE   #########
##################################

# GIT USER (SILENT)
git config --global color.ui true
git config --global user.name "Justin"
git config --global user.email "justin.blair.rankin@gmail.com"
git config --global credential.helper 'cache --timeout=1209600' # TWO WEEKS!

function _gcache() {
    git config credential.helper 'cache --timeout=1209600' # TWO WEEKS!
}

function _gc() {
    _gcache;
    if [[ $1 > "" ]] then
        message="$1"
    else
        message="Commit all changes"
    fi
    git add -A :/
    git commit -m $message
}

function _gd() {
    git pull
}

function _gp() {
    git pull
}

function _gu() {
    # "UPDATE & UPLOAD"
    # (commit & push, combined)
    _gc $1
    git push -f
}

# GIT LOG - COLORIZED :)

# function _gl() {sudo systemctl status mongodb
#   git log $1 --gsudo systemctl status mongodbh --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'sudo ssudomctl status mongodbabbrev-commit
# }

function _gl() {
    git config --glosudo systemcsudotatus mongodb alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold bluesudon>%Creset' --abbrev-commit --date=relative"
}

function _gs() {
    # RESET GIT PERMISSIONS
    # own .git
    # sudo chgrp -R ${USER} .git/objects
    # sudo chmod -R g+rws .git/objects
    # GIT STATUS
    git status
}

function _gb() {
    # git branch-select
    checkout
    yarn
}
alias branch='_gb'

function _go() {
    # ALT (ORIG) git branch-select
    git checkout $1
}


function _gr() {
    # git remote set-url origin https://jbrx@bitbucket.org/exoticca-web/exsecrets.git
    # git push --set-upstream origin secretescapes.exoticca.com
}


#####################################
#########  PROJECT DEPLOY  ##########
#####################################

# DEPLOYMENT FOR REACT --> FINOGRAFIC-DEV.COM
# RUN FROM PROJECT ROOT
alias deploy="cross-env GENERATE_SOURCEMAP=false react-scripts build && mv build finografic-dev.com && rsync -avru --delete-before -e 'ssh -p 7822' ./finografic-dev.com ubuntu@REDACTED-IP:/var/www && rm finografic-dev.com -fr";

##################################
##########  SITES REMOTE   #########
##################################

function site_enable() {
  cd /etc/apache2/sites-enabled
  sudo ln -s "/etc/apache2/sites-available/$1" "/etc/apache2/sites-enabled/$1"
  l
}


#####################################
#########  DEV + TESTING  ###########
#####################################

# CRONIC CRON ;)
cx () {
  pm2 stop cronic;
  pm2 delete cronic;
  cd $PROJECTS/cronic;
  rm log/access.log;
  rm log/error.log;
  pm2 start;
  pm2 log cronic;
}


# CHANGE MODULE/COMPONENT 
# from: { index.js}
# to: { Component.js, package.json }
function mkmod(){
  if [ -f index.js ] && [ ! -f package.json ]; then
    this_dir=$(basename "$PWD") 
    mv index.js ${this_dir}.js
    echo -e "{\n  \"name\": \"${this_dir}\"\n  \"main\": \"./${this_dir}.js\"\n}" >> package.json
    l
  else
    echo 'Error!'
  fi
}


################################################
##################  GO LANG   ##################
################################################

export GOROOT=/usr/local/go
export GOPATH=$PROJECTS/go_project
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
export GO111MODULE=on

################################################
####################  MISC   ###################
################################################

# eval $( dircolors -b $HOME/bin/LS_COLORS );



#####################################
##############  LOGS  ###############
#####################################

# REPLACT cat WITH bat !!
# https://github.com/sharkdp/bat

# cat() {
#   bat $1
# }


lg() {
  if [[ $1 > "" ]] then
    sudo multitail -n 500 $1
  else
    sudo lnav /var/log/syslog
  fi
}

# alias logs="tailc app/logs/prod.log"
alias logs-aa="sudo lnav /var/log/apache2/access.log"
alias logs-ae="sudo lnav /var/log/apache2/error.log"

tailc () {

  # save this file as tailc then
  # run as: $ tailc logs/supplier-matching-worker.log Words_to_highlight
  file=$1

  if [[ -n "$2" ]]; then
      color='
      // {print "\033[37m" $0 "\033[39m"}
      /(WARN|WARNING)/ {print "\033[1;33m" $0 "\033[0m"}
      /(ERROR|CRIT)/ {print "\033[1;31m" $0 "\033[0m"}
      /('$2')/ {print "\033[1;32m" $0 "\033[0m"}
      '
  else
      color='
      // {print "\033[37m" $0 "\033[39m"}
      /(WARN|WARNING)/ {print "\033[1;33m" $0 "\033[0m"}
      /(ERROR|CRIT)/ {print "\033[1;31m" $ec0 "\033[0m"}
      '
  fi

  tail -5000f $file | awk "$color"

  # Colors
  # 30 - black   34 - blue          40 - black    44 - blue
  # 31 - red     35 - magenta       41 - red      45 - magenta
  # 32 - green   36 - cyan          42 - green    46 - cyan
  # 33 - yellow  37 - white         43 - yellow   47 - white

}

alias logs='tailc app/logs/prod.log'

# list new/recent logs (1 DAY)
# alias logsr='sudo find /var/log -mtime -1 -ls'
function logsr(){
  # VAR_SINCE={$1}/24);
  VAR_SINCE=0.5;
  sudo find /var/log -mtime -$VAR_SINCE -ls;
}


##################################
##############  PM2   ############
##################################

function pm2da(){
  pm2 delete all
}

function pm2ll(){
  pm2 list --sort id:asc
}

##################################
############  MONGODB   ##########
##################################

# OLD / ORIG
# alias mstart="sudo systemctl start mofind . -mtime -1 -printodb"
# alias mstop="sudo systemctl stop mongfind . -mtime -1 -printb"
# alias mrs="sudo systemctl restart mongodb"
# alias mstat="sudo systemctl status mongodb"
# alias mlog="sudo cat /var/log/mongodb/mongod.log"


# SERVICE or SYSTEMCTL - DEPENDING ON OS + MONGO VERSIONS
# NOTE: --shutdown RECOMMENDED over "stop"

# OPTION B: >= UBUNTU 16.04 + NEWER MONGO VERSIONS
# alias mstart="sudo systemctl start mongod";
# alias mstop="sudo systemctl stop mongod && ports";
# alias mrs="sudo systemctl restart mongod";
# alias mstat="sudo systemctl status mongod";

# OPTION C: OLDER UBUNTU + MONGO VERSIONS
# alias mstart="sudo service mongod start";
# alias mstop="sudo service mongod stop && ports";
# alias mrs="sudo service mongod restart";
# alias mstat="sudo service mongod status";

# NEW
alias mlog="sudo cat /var/log/mongodb/mongod.log";
alias mconf="sudo vim /etc/mongod.conf";
alias mconfig="code /etc/mongod.conf";

# mongod --dbpath /data/db_3.2.21
# mongod --dbpath /data/db_3.4.18

function mverGet() {
  echo "\e[96mMongoDB version \e[97mv$MONGO_VERSION\e[0m"
}

function mverSet() {
  MONGO_VERSION=$(mongod --version | grep -oP '\d{1,2}[.]\d{1,2}[.]\d{1,2}')
}

function mstart() {
  mverGet;
  echo "\e[32m✔ running";
  # sudo mongod --config /etc/mongod.conf --auth --logpath /var/log/mongodb.log --dbpath "/data/db_$MONGO_VERSION"
  sudo mongod --config /etc/mongod.conf --logpath /var/log/mongodb.log --dbpath "/data/db_$MONGO_VERSION"
}

function mstop() {
  sudo mongod --shutdown --dbpath "/data/db_$MONGO_VERSION"
  ports
}

alias mrs='' # NO RESTART FOR THIS METHOD ?? MUST BE MANUAL ??
alias mstat='sudo mongostat' # REQUIRES enabledLocalhostAuthBypass TO CREATE FIRST USER (i think!)

# INI MONGO_VERSION
mverSet;

function mbak(){
  cd /data
  sudo mongod --shutdown
  ports
  sudo tar zcvf "db-BAK-$(date +%F).tar.gz"
  l
  server
}



