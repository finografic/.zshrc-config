# ============================================================================ #
# PATHS - LINUX
# ============================================================================ #

# SYS PATHS
export PATH=$PATH:/usr/local/lib/node_modules
export PATH=$PATH:$HOME/bin:/usr/local/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$NPM_GLOBALS

# GLOBALIZE IMPORTANT BINARIES (now included in repo)
export PATH=$PATH:$ZSHRC_ROOT/bin
# export PATH=$PATH:$ZSHRC_ROOT/node_modules/

# SSH PATH
export SSH_KEY_PATH="~/.ssh/rsa_id"

# MISC PROGRAMS + CONFIGS
export PATH=$PATH:/snap/bin
export PATH=$PATH:$HOME/.fzf
export PATH=$PATH:$ZSHRC_ROOT/zupdate

# ESSENTIALS
export PATH=$PATH:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin
# NOTE: `export PATH=$PATH:$(which curl)` used to sit here. It was wrong twice
# over: it spawned `which` on every Linux shell start, and it appended the
# curl BINARY to PATH — PATH holds directories, so the entry could never match
# anything. If `which curl` succeeded, curl's directory was already on PATH.
export PATH=$PATH:$HOME/.cargo/bin

# RUBY SIMPLE
# export PATH=$PATH:$HOME/.rbenv/bin

# CADDY
export PATH=$PATH:$HOME/bin/caddy

# GO PATHS
# export GOROOT=/usr/local/go
# export GOROOT=/usr/bin/go
# export GOROOT=$(which go)
# export GOPATH=$HOME/go
# export PATH=$PATH:$GOPATH/bin:$GOROOT/bin

# NEW: DIRECTLY FROM GOLANG.ORG:
export GOROOT=/usr/local/go/bin
export PATH=$PATH:$GOROOT

# MISC PATHS (ANY DUPLICATES, REMOVED BELOW)
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/lib/node_modules:$HOME/bin:/snap/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$HOME/bin/caddy:$HOME/.fzf/bin:$HOME/.vimpkg/bin
