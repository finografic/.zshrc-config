export CONTAINER_HOME="/workspace"

# CD NAVIGATION
# export alias 1="cd ../ && l"
# export alias 2="cd ../../ && l"
# export alias 3="cd ../../../ && l"
# export alias 4="cd ../../../../ && l"
# export alias 5="cd ../../../../../ && l"

unalias l 2>/dev/null
function l() {
  ls -lAh "$@"  # Add --color if desired and supported in container
}

alias _="cd /$WORKSPACE_ROOT/ && l"

# AWS
alias _aws="aws sso login"

# Exit export aliases
alias q='exit'
alias x='exit'

# Quick access to workspace (if mounted)
alias work="cd $CONTAINER_HOME"
alias ws="cd $CONTAINER_HOME"

# CONTAINER REPOS
alias gac="cd $CONTAINER_HOME/s1_gac_ui && l"
# export alias soa="cd $CONTAINER_HOME/sage_one_advanced && l"
alias sop="cd $CONTAINER_HOME/sop && l"

# Container info
alias container-info='echo -e "Container: $(hostname)\nArch: ${OS_ARCH}\nOS: ${OS_NAME}\nConfig: ${ZSHRC_ROOT}"'

function soa() {
 cd $CONTAINER_HOME/sage_one_advanced && l
}

function _start() {
  cd $CONTAINER_HOME/sage_one_advanced && l

  if [[ "$2" != "" ]]; then
    ./script/docker/start.sh "$1" "$2"
  elif [[ "$1" != "" ]]; then
    ./script/docker/start.sh "$1"
  else
  # DEFAULT MESSAGE
    echo "\n${_y}⚠️   INVALID ARGS${_0}\n"
  fi
}
