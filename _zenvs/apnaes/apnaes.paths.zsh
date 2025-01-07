#########################################
###########  PATHS - LINUX ##############
#########################################

# SYS PATHS
# GLOBALIZE IMPORTANT BINARIES (now included in repo)
export PATH=$PATH:$ZSHRC_ROOT/bin
# export PATH=$PATH:$ZSHRC_ROOT/node_modules/

# SSH PATH
export SSH_KEY_PATH="~/.ssh/rsa_id"

# MISC PROGRAMS + CONFIGS
export PATH=$PATH:/snap/bin
export PATH=$PATH:$HOME/.vimpkg/bin # VIM EXTENSIONS !!

# ESSENTIALS
export PATH=$PATH:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin
export PATH=$PATH:$(which curl)
