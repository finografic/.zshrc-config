###########################################
###### A2 SPECIFIC - MOVE TO FILE  ########
###########################################

# SPECIFIC
export ZSHRC_ROOT="$HOME/.zshrc-config"
export NVM="true"
export IDE="false"
export EDITOR="vim"
code () { eval "$(which jmate) $@"; }

# DIRCOLORS
[ -d "${HOME}/.dircolors" ] && eval `dircolors ${HOME}/.dircolors/dircolors-solarized-master/dircolors.ansi-dark`;

# SSH-SPECIFIC:
alias logout="~."
alias lo="~."

# ENHANCED FOLDER LISTINGS
alias llh="ls -ld .?*" # list hidden
alias ll="ls -la --color -h --group-directories-first" #

# LIST PERMISSIONS -- HOW TO ADD COLOR ??
alias lp="stat -c '%A  %a  %U:%G  ___  %n' *"    # SIMPLE

function listing_ALT() {
  ls -lAh --color $1
  # lc
  if [ -d .git ]
  then
      # own .git
      _gs
  fi
}


function listing() {
  k -Ah $1
  # lc
  if [ -d .git ]
  then
      # own .git
      _gs
  fi
}


function lr() {
    k -rAth
}

# alias l="lk"
alias l1="listing"
alias l2="listing_exa"
alias l="listing"
# alias ls="eval `dircolors -b ${HOME}/.dircolors` && ls -Alh --color" # list hidden

# ???
alias lr1="find $(pwd) -mtime -1 -ls -maxdepth 1"
alias lr2="k -rAth"

# TODO: HARDWARE (OR MOST?) SHOULD BE ENV-SPECIFIC
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.hardware.zsh";
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.dev.zsh";













####################################################


alias cv="cd /var/www/finografic.com && l"

function gyp-fix(){

  if [[ -f package.json ]] then

    # IS PROJECT ROOT
    project_root=$PWD;

    echo "\n\e[36m ---=====\e[37m ncu updating \e[36m=====--- \n"
    ncu && ncu -u
    echo 'current node version: '
    nvm current

    echo "\n\e[36m ---=====\e[37m delete node_modules \e[36m=====--- \n"
    rm $project_root/package-lock.json
    rm $project_root/node_modules -fr

    echo "\n\e[36m ---=====\e[37m reinstall node_modules bases on ncu \e[36m=====--- \n"
    npm i

    echo "\n\e[36m ---=====\e[37m fix gyp modules \e[36m=====--- \n"
    cd $project_root/node_modules/node-gyp && yarn
    cd $project_root/node_modules/node-pre-gyp && yarn

    echo "\n\e[36m ---=====\e[37m final main yarn \e[36m=====--- \n"
    cd $project_root && yarn

  else

    echo 'Not project root!'

  fi

}

##########################################
###############  IMPORTS  ################
##########################################


# TESTING
alias cs="cd $HOME/cronic && l && _gs"



##################################
##############  PM2   ############
##################################

function pm2lg(){
  cd $HOME/logs-crons;
  lnav _crons-daemon.log;
}

function pm2dl(){
  delete $HOME/logs-crons/*
}




############################################
##########  REMOTE ALIASES: OTHER  ########
############################################


# APACHE ALIASES
alias sites="cd /etc/apache2/sites-available && l"
alias sites0="cd /etc/apache2/sites-available && l"
alias sites1="cd /etc/apache2/sites-enabled && l"
alias enabled="cd /etc/apache2/sites-enabled && l"
