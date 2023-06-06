#######################################
###########  PATHS - MACOS ############
#######################################

# SYS PATHS
export PATH="/opt/homebrew/bin:/opt/local/bin:/opt/local/sbin:$PATH"
export PATH=$PATH:$HOME/bin:/usr/local/bin
export PATH=$PATH:$NPM_GLOBALS

# GLOBALIZE IMPORTANT BINARIES (now included in repo)
export PATH=$PATH:$ZSHRC_ROOT/bin
# export PATH=$PATH:$ZSHRC_ROOT/node_modules/

# SSH PATH
export SSH_KEY_PATH="~/.ssh/id_ed25519"

# MISC PROGRAMS + CONFIGS
export PATH=$PATH:$HOME/.eslintrc # NECESSARY ??
export PATH=$PATH:$HOME/.vimpkg/bin # VIM EXTENSIONS !!

# ESSENTIALS
export PATH=$PATH:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin
export PATH=$PATH:$(which curl)

# MISC PATHS (ANY DUPLICATES, REMOVED BELOW)
export PATH=$PATH:$HOME/.nvm/versions/node/$NODE_CURRENT_VERSION/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/lib/node_modules:$HOME/bin:/snap/bin:$HOME/.eslintrc:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$HOME/bin/caddy:$HOME/.fzf/bin:$HOME/.vimpkg/bin

# REMOVE DUPLICATES FROM PATH
# TODO: "awk -vRS=:" OPTION NOT WORKING ON MAC
function flatten_PATH(){
  export PATH=$(printf %s "$PATH" | awk -vRS=: '!a[$0]++' | paste -s -d:);
}

# flatten_PATH; # DISABLED FOR DEBUGGING
