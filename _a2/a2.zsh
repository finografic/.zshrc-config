###########################################
###### A2 SPECIFIC - MOVE TO FILE  ########
###########################################

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


##################################
########  SYMFONY CACHE  #########
##################################

# PATH-SPECIFIC FUNCTIONS
PWD=`pwd`

# COMPOSER CACHE CLEAR
cc () {

  if [[ $PWD = *'kpi-es'* ]] then
    /var/www/kpi-es/kpi_exoticca/set_parameters
    PROJECT=/var/www/kpi-es/kpi_exoticca
  elif [[ $PWD = *'kpi-uk'* ]] then
    /var/www/kpi-uk/kpi_exoticca/set_parameters
    PROJECT=/var/www/kpi-uk/kpi_exoticca
  elif [[ $PWD = *'kpi-us'* ]] then
    /var/www/kpi-us/kpi_exoticca/set_parameters
    PROJECT=/var/www/kpi-us/kpi_exoticca
  elif [[ $PWD = *'kpi-fr'* ]] then
    /var/www/kpi-fr/kpi_exoticca/set_parameters
    PROJECT=/var/www/kpi-fr/kpi_exoticca
  elif [[ $PWD = *'kpi-de'* ]] then
    /var/www/kpi-de/kpi_exoticca/set_parameters
    PROJECT=/var/www/kpi-de/kpi_exoticca
  elif [[ $PWD = *'kpi-us'* ]] then
    /var/www/kpi-us/kpi_exoticca/set_parameters
    PROJECT=/var/www/kpi-us/kpi_exoticca
  elif [[ $PWD = *'secretescapes-es/wmexoticca'* ]] then
    /var/www/secretescapes-es/wmexoticca/set-parameters
    PROJECT=/var/www/secretescapes-es/wmexoticca
  elif [[ $PWD = *'secretescapes-uk/wmexoticca'* ]] then
    /var/www/secretescapes-uk/wmexoticca/set-parameters
    PROJECT=/var/www/secretescapes-uk/wmexoticca
  elif [[ $PWD = *'secretescapes-fr/wmexoticca'* ]] then
    /var/www/secretescapes-fr/wmexoticca/set-parameters
    PROJECT=/var/www/secretescapes-fr/wmexoticca
  elif [[ $PWD = *'secretescapes-de/wmexoticca'* ]] then
    /var/www/secretescapes-de/wmexoticca/set-parameters
    PROJECT=/var/www/secretescapes-de/wmexoticca
  elif [[ $PWD = *'secretescapes-us/wmexoticca'* ]] then
    /var/www/secretescapes-us/wmexoticca/set-parameters
    PROJECT=/var/www/secretescapes-us/wmexoticca
  else
    echo "Your path is invalid for this function."
  fi

  # CLEAR CACHE
  sudo php ${PROJECT}/app/console cache:clear --env=prod;
  sudo chown -R www-data:${USER} ${PROJECT}/app/cache;
  sudo chmod -R 775  ${PROJECT}/app/cache;
  # RESET GIT PERMISSIONS
  sudo chgrp -R ${USER} ${PROJECT}/.git/objects
  sudo chmod -R g+rws ${PROJECT}/.git/objects
  # COMMIT cc (REGENERATED parameters.yml FILE
  git commit -m 'parameters.yml regenerated' app/config/parameters.yml

}

# CLEAR ALL CACHES
ccall() {
  declare -a locales=("es" "uk" "de" "fr" "us");
  arraylength=${#locales[@]}
  for (( i=1; i<${arraylength}+1; i++ ))
  do
    echo "\n\e[32mClearing CACHE for \e[36mkpi-${locales[i]}\e[37m...\n"
    cd /var/www/kpi-${locales[i]}/kpi_exoticca
    cc
  done
}

############################################
##########  REMOTE ALIASES: OTHER  ########
############################################


# APACHE ALIASES
alias sites="cd /etc/apache2/sites-available && l"
alias sites0="cd /etc/apache2/sites-available && l"
alias sites1="cd /etc/apache2/sites-enabled && l"
alias enabled="cd /etc/apache2/sites-enabled && l"
