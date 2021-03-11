#########################################
###########  PATHS - ANDROID ############
#########################################

# SYS PATHS
export PATH=$PATH:$NPM_GLOBALS

# GLOBALIZE IMPORTANT BINARIES (now included in repo)
export PATH=$PATH:$ZSHRC_ROOT/bin/pfetch
export PATH=$PATH:$ZSHRC_ROOT/bin/lsof

# REMOVE DUPLICATES FROM PATH
function flatten_PATH(){
  export PATH=$(printf %s "$PATH" | awk -vRS=: '!a[$0]++' | paste -s -d:);
}

flatten_PATH;
