###########################################
###### AWS SPECIFIC - MOVE TO FILE  #######
###########################################

# NGINX
alias sites0='cd /etc/nginx/sites-available && l'
alias sites1='cd /etc/nginx/sites-enabled && l'

# PROJECTS
alias restex='cd /var/www/api.com/restex/src && l'
alias sefr='cd /var/www/secretescapes.exoticca.fr && l'
alias seus='cd /var/www/secretescapes.exoticca.travel && l'
alias sevc='cd /var/www/verychic.exoticca.fr && l'

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

function pm2-restex(){
  # KILL OLD
  pm2 stop api-restex --silent
  pm2 delete api-restex --silent
  # KILL NODE
  kn
  # BUILD NEW
  cd /var/www/api.com/restex
  pm2 start
  pm2 log api-restex
}

# NVM for AWS
nvm alias default v8.10.0
nvm use v8.10.0 
