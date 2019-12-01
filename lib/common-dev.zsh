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



#####################################
#########  PROJECT DEPLOY  ##########
#####################################

# DEPLOYMENT FOR REACT --> FINOGRAFIC-DEV.COM
# RUN FROM PROJECT ROOT
alias deploy="cross-env GENERATE_SOURCEMAP=false react-scripts build && mv build finografic-dev.com && rsync -avru --delete-before -e 'ssh -p 7822' ./finografic-dev.com ubuntu@REDACTED-IP:/var/www && rm finografic-dev.com -fr";



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
