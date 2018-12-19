#########################################
##########  UNIVERSAL ALIASES  ##########
#########################################

# ZSH CONFIG
# alias config="sudo ${HOME}/.npm-global/bin/rmate ${HOME}/.zshrc"
# alias config="sudo /usr/local/bin/rmate ${HOME}/.zshrc"

function config() {

  #   local dir=$(
  #   [ $# = 1 ] && [ -d "$1" ] && cd "$1"
  #   while true; do
  #     find "$PWD" -mindepth 1 -maxdepth 1 -type d
  #     echo "$PWD"
  #     [ $PWD = / ] && break
  #     cd ..
  #   done | fzf --tiebreak=end --height 50% --reverse --preview 'tree -C {} | head -200'
  # ) && cd "$dir"

  # OPEN MAIN/PARENT.zshrc FILE BY DEFAULT
  # sudo /usr/local/bin/rmate ${HOME}/.zshrc;
  # sudo $EDITOR_PREFERRED ${HOME}/.zshrc;
  # $EDITOR ${HOME}/.zshrc;

  #  TEMP: SAVE CURRENT PATH && CD TO CUSTOM ZSH CONFIG PATH
  PWD_ORIG=$PWD ;
  cd ${HOME}/__zshrc__/;
  # /usr/local/bin/rmate $(fzf --reverse --preview '[[ $(file --mime {}) =~ binary ]] &&
  #                echo {} is a binary file ||
  #                (rougify {} || 
  #                 lnav {} || 
  #                 cat {}) 2> /dev/null | head -500');
  $EDITOR $(fzf --reverse --preview '[[ $(file --mime {}) =~ binary ]] &&
                 echo {} is a binary file ||
                 (rougify {} || 
                  lnav {} || 
                  cat {}) 2> /dev/null | head -500');
  # GO BACK TO ORIGINAL FOLDER
  cd $PWD_ORIG;

}

function config_BAK() {
  sudo /usr/local/bin/rmate ${HOME}/.zshrc
  for f in ${HOME}/__zshrc__/*.zshrc; do
      # do some stuff here with "$f"
      # remember to quote it or spaces may misbehave
       sudo /usr/local/bin/rmate ${f}
  done
}


alias reset=". ${HOME}/.zshrc"
alias update=". ${HOME}/.zshrc; npm cache verify"
alias zc="cd ${HOME}/__zshrc__ && l"

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
alias lc='colorls -lA --sd' # RUBY GEM ls w/ icons :D
# COLORLS: CHANGE ICONS HERE: subl $(dirname $(gem which colorls))/yaml

# alias l="k -Ah"
function lk() {
  k -Ah
  # lc
  if [ -d .git ]
  then
  own .git
   _gs
  fi
}


alias l="lk"
alias ls="eval `dircolors -b ${HOME}/.dircolors` && ls -Alh --color" # list hidden
alias -1="cd ../ && l"
alias -2="cd ../../ && l"
alias -3="cd ../../../ && l"
alias -4="cd ../../../../ && l"
alias -5="cd ../../../../../ && l"

# TREE LISTING
alias t="tree -d"
alias ta="tree"

# FOLDER FAVORITES
alias home="cd ~"
alias www="cd /var/www/ && l"
# alias test="cd /var/www/html/test && l"

# MISC COM
alias ip="echo '\n\e[37mLocal IP addess: \e[0;35m$IP\n'"
# alias ports="sudo lsof -i -P -n | grep LISTEN"
# alias ports="echo '\n\e[0m\e[36m'; sudo netstat -plnte; echo '\n';"
alias ports1="echo '\n\e[96m'; sudo grc netstat -ltnp; echo '\n\e[0m'";
alias ports2="echo '\n\e[96m'; grc netstat -plnt; echo '\n\e[0m'";
alias ports="ports2";

#####################################
############  FUNCTIONS  ############
#####################################

run() {
  # requires "ntl" node package installed globally
  echo "\n";
  ntl --info --size 20;
}

# ALIASES THAT TAKE PARAMETERS
versions() {
  npm info "$1" versions
}

v() {
  npm info "$1" versions
}

#####################################
##########  FILE UTILS  #############
#####################################

# TAR
tz() {
  sudo tar -xzf $1 # COMPRESS
} 

tuz() {
  sudo tar xf $1 # DECOMPRESS 
} 

# FILE FIND
f () { 
  sudo find . -type f -name "*$@*"
}

# FILE/FOLDER PERMISSIONS
own () {
  sudo chown -R $USER:$USER $1
}
mown () {
  sudo chown -R mongodb:mongodb $1
}

#####################################
##############  LOGS  ###############
#####################################

lg() {
  if [[ $1 > "" ]] then
    sudo multitail -n 500 $1
  else
    sudo lnav /var/log/syslog
  fi
}

# alias logs="tailc app/logs/prod.log"
alias alogs="sudo lnav /var/log/apache2/access.log"
alias elogs="sudo lnav /var/log/apache2/error.log"

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
      /(ERROR|CRIT)/ {print "\033[1;31m" $0 "\033[0m"}
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

##################################
############  MONGODB   ##########
##################################

# OLD / ORIG
# alias mstart="sudo systemctl start mongodb"
# alias mstop="sudo systemctl stop mongodb"
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

##################################
##########  GIT REMOTE   #########
##################################

# GIT USER (SILENT)
git config --global color.ui true
git config --global user.name "Justin"
git config --global user.email "REDACTED-EMAIL"
# ssh-keygen -t rsa -b 4096 -C "REDACTED-EMAIL"

function _gc() {
  if [[ $1 > "" ]] then
    message="$1"
  else
    message="Commit all changes"
  fi
  git add -A :/
  git commit -m $message
}

function _gd() {
  git add -A :/
  git commit -m "Commit all changes before pull."
  git push
}

function _gu() {
  git add -A :/
  git commit -m "Commit all changes before push."
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
  own .git
  chgrp -R ${USER} .git/objects
  chmod -R g+rws .git/objects
  # GIT STATUS
  git status
}


function _gb() {
  git branch-select
}
