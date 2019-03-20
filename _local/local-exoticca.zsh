##################################
########  SYMFONY CACHE  #########
##################################

# PATH-SPECIFIC FUNCTIONS
PWD=`pwd`

# COMPOSER CACHE CLEAR
cc () {
  if [[ $PWD = *'kpi'* ]] then
    /var/www/kpi_exoticca/set_parameters
    PROJECT=/var/www/kpi_exoticca
  elif [[ $PWD = *'wmexoticca'* ]] then
    /var/www/wmexoticca/set-parameters
    PROJECT=/var/www//wmexoticca
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

# KPI COMMANDS
kpi () {

  if [[ $PWD = *'kpi_exoticca'* ]] then
    PROJECT=/var/www//kpi_exoticca
  # KPI CMDS ##########################
    if [[ $@ = 'app' ]] then
      cd ${PROJECT}/src/Exoticca/AppBundle && l && _gs
    elif [[ $@ = 'config' ]] then
      cd ${PROJECT}/app/config && l
    elif [[ $@ = 'views' ]] then
      cd ${PROJECT}/src/Exoticca/AppBundle/Resources/views && l
    elif [[ $@ = 'feeds' ]] then
      cd ${PROJECT}/src/Exoticca/AppBundle/Resources/views/feed && l
    elif [[ $@ = 'css' ]] then
      ${PROJECT}/app/console assetic:dump --env=prod
    elif [[ $@ = 'params' ]] then
      cd /var/www/_parameters-kpi && l && _gs
    elif [[ $@ = 'cc' ]] then
      # /var/www/kpi_exoticca/set_parameters
      # CLEAR CACHE
      sudo php ${PROJECT}/app/console cache:clear --env=prod;
      sudo chown -R www-data:${USER} ${PROJECT}/app/cache;
      sudo chmod -R 775  ${PROJECT}/app/cache;
      # RESET GIT PERMISSIONS
      sudo chgrp -R ${USER} ${PROJECT}/.git/objects
      sudo chmod -R g+rws ${PROJECT}/.git/objects
      # COMMIT cc (REGENERATED parameters.yml FILE
      git commit -m 'parameters.yml regenerated' app/config/parameters.yml
  ###################################### 
  else
    cd /var/www/kpi_exoticca && l && _gs
    # set_parameters
    # PROJECT=/var/www/kpi_exoticca
  fi

}

