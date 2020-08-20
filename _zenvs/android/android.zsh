# SPECIFIC
export STORAGE_ROOT="/storage/emulated/0/termux" # ANDROID ONLY !!
export SSH_CONFIG="$STORAGE_ROOT/.zshrc-config"
export NVM="false"
export IDE="false"
export EDITOR="vi"
code () { "$EDITOR $@"; }

STORAGE="/storage/emulated/0/termux"
alias x="cd $STORAGE"

# UNIVERSAL
PROJECTS="$HOME/dev_projects"
alias dev="cd $PROJECTS && l"
alias www="cd /var/www && l"

# LOCAL: DEV
alias .="cd $HOME && l" ;
# alias config="" ;
alias pilot="cd $STORAGE/auto-pilot &&  l" ;

# DEPRECATED !
repos() {
  # msg err "PLEASE USE ALIAS 'dev'" # use my MSG FUNCTION
  # MOVED !!
  cd "$HOME/dev_repos" && l
}
