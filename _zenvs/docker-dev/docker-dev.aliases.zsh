export CONTAINER_HOME="/workspace"

# CD NAVIGATION
# export alias 1="cd ../ && l"
# export alias 2="cd ../../ && l"
# export alias 3="cd ../../../ && l"
# export alias 4="cd ../../../../ && l"
# export alias 5="cd ../../../../../ && l"

export alias _="cd /$WORKSPACE_ROOT/ && l"

# AWS
export alias _aws="aws sso login"

# Exit export aliases
export alias q='exit'
export alias x='exit'

# Quick access to workspace (if mounted)
export alias work="cd $CONTAINER_HOME"
export alias ws="cd $CONTAINER_HOME"

# CONTAINER REPOS
export alias gac="cd $CONTAINER_HOME/s1_gac_ui && l"
# export alias soa="cd $CONTAINER_HOME/sage_one_advanced && l"
export alias sop="cd $CONTAINER_HOME/sop && l"

# Container info
export alias container-info='echo -e "Container: $(hostname)\nArch: ${OS_ARCH}\nOS: ${OS_NAME}\nConfig: ${ZSHRC_ROOT}"'

soa() {
 cd $CONTAINER_HOME/sage_one_advanced && l
}
