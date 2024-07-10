#######################################
###########  PATHS - MACOS ############
#######################################

# SYS PATHS
export PATH="/opt/homebrew/binnpm:/opt/local/bin:/opt/local/sbin:$PATH"
export PATH=$PATH:$HOME/bin:/usr/local/bin
export PATH=$PATH:$NPM_GLOBALS

# GLOBALIZE IMPORTANT BINARIES (now included in repo)
export PATH=$PATH:$ZSHRC_ROOT/bin
# export PATH=$PATH:$ZSHRC_ROOT/node_modules/

# SSH PATH
export SSH_KEY_PATH="~/.ssh/id_ed25519"

# MISC PROGRAMS + CONFIGS
export PATH=$PATH:$HOME/.vimpkg/bin # VIM EXTENSIONS !!

# ESSENTIALS
export PATH=$PATH:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin
export PATH=$PATH:$(which curl)

# PYTHON
export PATH=$PATH:$(which python3)

# MISC PATHS (ANY DUPLICATES, REMOVED BELOW)
export PATH=$PATH:$HOME/.nvm/versions/node/$NODE_CURRENT_VERSION/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/lib/node_modules:$HOME/bin:/snap/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$HOME/bin/caddy:$HOME/.fzf/bin:$HOME/.vimpkg/bin

# MISC PATHS (ANY DUPLICATES, REMOVED BELOW)
export PATH=$PATH:$HOME/.nvm/versions/node/$NODE_CURRENT_VERSION/bin:/ts-node
export PATH=$PATH:$HOME/.nvm/versions/node/$NODE_CURRENT_VERSION/lib/nodemodules/pm2/node_modules/.bin/ts-node
