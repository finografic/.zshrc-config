# SPECIFIC
export STORAGE_ROOT="/storage/emulated/0/termux" # ANDROID ONLY !!
export SSH_CONFIG="$STORAGE_ROOT/.zshrc-config"
export NVM="false"
export EDITOR_PREFERRED==vi
code () { vi "$@"; }

# UNIVERSAL 
PROJECTS="$HOME/dev_projects"
alias dev="cd $PROJECTS && l"
alias www="cd /var/www && l"

# LOCAL: DEV
alias da2="cd $PROJECTS/da2 && l";


# REMOTE: A2 HOSTING
# alias a2="ssh -p 7822 67.209.azs115.154 -l ubuntu"
alias a2="ssh -R 52698:localhost:52698 REDACTED-IP -p 7822 -l ubuntu"

# DEPRECATED !
repos() { 
  # msg err "PLEASE USE ALIAS 'dev'" # use my MSG FUNCTION
  # MOVED !! 
  cd "$HOME/dev_repos" && l
}
