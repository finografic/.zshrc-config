###########################################
###### A2 SPECIFIC - MOVE TO FILE  ########
###########################################

alias cv="cd $HOME/repos/cv && l"

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
