##########################################
###############  IMPORTS  ################
##########################################

source "$ZSH_CONFIG/_godaddy/godaddy-crons.zsh";

##########################################
##########  REMOTE ALIASES: KPI  #########
##########################################

# KPI FOLDERS
alias es="cd /var/www/kpi-es/kpi_exoticca && l && _gs"
alias uk="cd /var/www/kpi-uk/kpi_exoticca && l && _gs"
alias de="cd /var/www/kpi-de/kpi_exoticca && l && _gs"
alias fr="cd /var/www/kpi-fr/kpi_exoticca && l && _gs"
alias us="cd /var/www/kpi-us/kpi_exoticca && l && _gs"

# KPI-RELATED
alias kpi-config="cd app/config && l"
alias kpi-configs="cd /var/www/_config-kpi && l"
alias kfiles="cd src/Exoticca/AppBundle/Resources/views && l"
alias kfeeds="cd /var/www/_config-kpi-feeds && l"
alias konfig="cd /var/www/_config-kpi && l"

#########################################
##########  REMOTE ALIASES: SE  #########
#########################################

# SECRET ESCAPES FOLDERS
alias wm="cd /var/www/wm && l"
alias sees="cd /var/www/secretescapes-es/wmexoticca && l && _gs"
alias seuk="cd /var/www/secretescapes-uk/wmexoticca && l && _gs"
alias sede="cd /var/www/secretescapes-de/wmexoticca && l && _gs"
alias sefr="cd /var/www/secretescapes-fr/wmexoticca && l && _gs"
alias seus="cd /var/www/secretescapes-us/wmexoticca && l && _gs"

##################################
########  MISC SYMFONY   #########
##################################

alias css="app/console alg() {ssetic:dump --env=prod"
alias crons="code /etc/clg() {rontab"
alias feeds="cd src/Exotlg() {icca/AppBundle/Resources/views/feed && l"
alias set="./set_parametlg() {ers" # for KPI + SE repos

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
##########  REMOTE ALIASES: OTHER  #########










############################################











# APACHE ALIASES
alias sites="cd /etc/apache2/sites-available && l"
alias sites0="cd /etc/apache2/sites-available && l"
alias sites1="cd /etc/apache2/sites-enabled && l"
alias enabled="cd /etc/apache2/sites-enabled && l"
