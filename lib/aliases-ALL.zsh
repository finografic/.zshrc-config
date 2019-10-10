#############################################
############ FUNCTIONS + ALIASES ############
#############################################

# ZSH CONFIG
export FZF_DEFAULT_COMMAND='fd --type f --ignore-file .ignore'

function config() {
  #  TEMP: SAVE CURRENT PATH && CD TO CUSTOM ZSH CONFIG PATH
  PWD_ORIG=$PWD ;
  cd ${HOME}/.zshrc-config;
  # --preview BROKEN !! :()
  # code $(fzf --reverse --preview '[[ $(file --mime {}) =~ binary ]] &&
  #                echo {} is a binary file ||
  #                (rougify {} || 
  #                 lnav {} || 
  #                 cat {}) 2> /dev/null | head -500');
  code $(fzf --reverse);
  cd $PWD_ORIG;
}

# TERMINAL MESSAGE: function msg(type, "string")
msg() { 

  # DEFINE + GET MESSAGE TYPE
  declare -A TYPES=( 
    [info]=$_c 
    [success]=$_g 
    [warning]=$_y  
    [warn]=$_y 
    [danger]=$_r  
    [error]=$_r  
    [err]=$_r  
  )
  _type=${TYPES[$1]}

  # DETERMINE LENGTH OF MESSAGE IN CHARS
  FULL_LENGTH=70 
  STRING_LENGTH=$(expr length $2 + 4) 

  # SUFFIX (REMAINING CHARACTERS OUT OF 80)
  let SUFFIX_LENGTH=$FULL_LENGTH-$STRING_LENGTH
  SUFFIX_STRING="${_type}"
  for ((i=1;i<=$SUFFIX_LENGTH;i++));
  do 
    SUFFIX_STRING+="="
  done

  # FULL MESSAGE OUTPUT
  MSG="\n${_type}== ${_w}${2} ${SUFFIX_STRING}\n"
  echo $MSG;

}

alias reset=". ${HOME}/.zshrc"
alias update_cache=". ${HOME}/.zshrc; npm cache verify"
alias cdz="cd ${HOME}/.zshrc-config && l"
alias os="cd ${HOME}/OS_Setup && l"

#########################################
############  FILE LISTINGS  ############
#########################################

# LIST SYSTEM PATHS
alias path="tr ':' '\n' <<< '$PATH'"
alias PATH="tr ':' '\n' <<< '$PATH'"

# ENHANCED FOLDER LISTINGS
alias llh="ls -ld .?*" # list hidden
alias ll="ls -la --color -h --group-directories-first" # list hidden
# alias l="ll -la --color -h --group-directories-first" # list hidden
# alias l="k -Ah" # list hidden
# alias l='k -Ah' # list hidden

# subl $(dirname $(gem which colorls))/yaml
alias lc="colorls -lA --sort-dirs --git-status --report && echo \n" # RUBY GEM ls w/ icons :D
# alias l2="exa --long --all --group-directories-first --accessed --time-style=long-iso --git" # NEW ALT LS COLOR
# COLORLS: CHANGE ICONS HERE: subl $(dirname $(gem which colorls))/yaml

# LIST PERMISSIONS -- HOW TO ADD COLOR ??
alias lp="stat -c '%A  %a  %U:%G  ___  %n' *"    # SIMPLE
# alias lp="stat -c '%A %a  %U:%G  %F %s -- %n' *"  # with TYPE and SIZE

function listing() {
  k -Ah
  # lc
  if [ -d .git ]
  then
  # own .git
   _gs
  fi
}

function listing_exa() {
  exa --long --all --group-directories-first --accessed --time-style=long-iso --git
  # lc
  if [ -d .git ]
  then
  # own .git
   _gs
  fi
}

function lr() {
  # SORT BY DATE ASC
  # USEFUL FOR CHECKING LAST MODIFIED
  # TODO - ADD x num days VARIABLE
  k -rAth
}

# alias l="lk"
alias l1="listing"
alias l2="listing_exa"
alias l="listing_exa"
alias ls="eval `dircolors -b ${HOME}/.dircolors` && ls -Alh --color" # list hidden

# ???
alias lr="find $(pwd) -mtime -1 -ls -maxdepth 1"

# CD NAVIGATION
alias -1="cd ../ && l"
alias -2="cd ../../ && l"
alias -3="cd ../../../ && l"
alias -4="cd ../../../../ && l"
alias -5="cd ../../../../../ && l"

# TREE LISTING
alias t="tree -d"
alias t2="exa --long --tree --all --group-directories-first"
alias t3="exa --tree --long --all --group-directories-first --accessed --time-style=long-iso --git"
alias ta="tree"

########################################
############  FOLDER FAVES  ############
########################################

# FOLDER FAVORITES
alias home="cd ~"
alias www="cd /var/www/ && l"
# alias test="cd /var/www/html/test && l"

#####################################
############  UTILITIES  ############
#####################################

# MISC COM
alias ip="echo '\n\e[37mLocal IP addess: \e[0;35m$IP\n'"
# alias ports="sudo lsof -i -P -n | grep LISTEN"
# alias ports="echo '\n\e[0m\e[36m'; sudo netstat -plnte; echo '\n';"
alias ports1="echo '\n\e[96m'; sudo grc netstat -ltnp; echo '\n\e[0m'";
alias ports2="echo '\n\e[96m'; grc netstat -plnt; echo '\n\e[0m'";
alias ports="ports2";

#####################################
##########  FILE UTILS  #############
#####################################

# TAR
tz() {
  sudo tar -xzf $1 # COMPRESS
  # sudo tar zcvf mongodb-BAK-20181221.tar.gz db 
} 

tuz() {
  # DECOMPRESS
  # TODO: USER SELECT FOR *.tar.gz FILES
  echo '\e[32m'
  sudo tar xvpf $1 -C . --checkpoint=.100
  l
} 

# FIND: FILE
f() { 
  # OPTION 1.
  # sudo find . -type f -name "$@"
  # OPTION 2. ** BEST OPTION
  # sudo fd "$@"
  # OPTION 3.
  sudo fd --hidden --color 'auto' "$@"
}

# FIND: APT PACKAGES
# sudo ag -i -g "$@" # --depth 5    

# FIND: FILE CONTENTS
contents() { 
  # OPTION 1.
  # sudo grep -rnw "." -e "$@"
  sudo grep -rnl "." -e "$@"
}

# FILE/FOLDER PERMISSIONS
own() {
  sudo chown -R $USER:$USER $1
}

# OWN USING mongodb USER
mown () {
  sudo chown -R mongodb:mongodb $1
}

# DISK SPACE
space(){
  pydf --human-readable
}

# DISK SPACE
space2(){
  ncdu;
}

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

##################################
##########  GIT REMOTE   #########
##################################

# GIT USER (SILENT)
git config --global color.ui true
git config --global user.name "Justin"
git config --global user.email "justin.blair.rankin@gmail.com"
git config --global credential.helper 'cache --timeout=1209600' # TWO WEEKS!

function _gcache() {
  git config credential.helper 'cache --timeout=1209600'    # TWO WEEKS!
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

function _gl_ALT() {
  git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
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


##################################
##########  SITES REMOTE   #########
##################################

function site_enable() {
  cd /etc/apache2/sites-enabled
  sudo ln -s "/etc/apache2/sites-available/$1" "/etc/apache2/sites-enabled/$1"
  l
}


##################################
#############  MISC  #############
##################################

function newsh() {
  NEW_FILE=$1.sh
  echo "#!/bin/bash" >> $HOME/bin/$NEW_FILE
  chmod +x $HOME/bin/$NEW_FILE
  code $HOME/bin/$NEW_FILE
}



