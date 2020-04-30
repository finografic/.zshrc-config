# DEVILBOX
devil() {
    PWD=`pwd`
    # START UP DEVILBOX
    if [[ $@ == "ini" || $@ == "init" ]] then
        cd $PROJECTS/devilbox && l
        service apache2 stop
        service mysql stop
        sudo docker-compose up httpd php mysql
        # sudo docker-compose up httpd php # mysql
        # ENTER MAIN DOCKER CONTAINER (PHP)
        elif [[ $@ == "cli" ]] then
        cd $PROJECTS/devilbox && l
        ./shell.sh
        # DEFAULT: CD + LIST
    else
        msg warn "OPTIONAL ARGS" # use my MSG FUNCTION
        echo "${_0}${_w}ini, init ${_y}- start up devilbox${_0}"
        echo "${_w}cli       ${_y}- enter main docker container (php)${_0}"
        echo "\n${_0}"
        cd $PROJECTS/devilbox && l
    fi
}
