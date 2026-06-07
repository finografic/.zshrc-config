# SPECIFIC
export STORAGE_ROOT="/storage/emulated/0/termux" # ANDROID ONLY !!
export SSH_CONFIG="$STORAGE_ROOT/.zshrc-config"
export NVM="false"

# EDITOR + IDE OVERRIDES (set originally in main.zsh)
export EDITOR="vi"
export IDE="false"
function edit() { "$EDITOR $@"; }
function code() { "$IDE $@"; }

STORAGE="/storage/emulated/0/termux"
alias x="cd $STORAGE"

# UNIVERSAL
REPOS="$HOME/dev_projects"
alias dev="cd $REPOS && l"
alias www="cd /var/www && l"

# LOCAL: DEV
alias .="cd $HOME && l"
# alias config="" ;
alias pilot="cd $STORAGE/auto-pilot &&  l"

# DEPRECATED !
function repos() {
  # msg err "PLEASE USE ALIAS 'dev'" # use my MSG FUNCTION
  # MOVED !!
  cd "$HOME/dev_repos" && l
}
