# SPECIFIC
export ZSHRC_ROOT="$HOME/.zshrc-config"
export NVM="true"
export IDE="code-insiders"
export EDITOR="$(which $IDE)"
code () { "$EDITOR $@"; }

# DIRCOLORS
[ -d "${HOME}/.dircolors" ] && eval `dircolors ${HOME}/.dircolors/dircolors-solarized-master/dircolors.ansi-dark`;

# LOCAL-ONLY SYS ALIASES
alias sys="systemsettings5" # KUBUNTU ONLY

# UNIVERSAL
alias dls="cd $HOME/Downloads && l"
alias www="cd /var/www && l"

# UNIVERSAL - DEV
PROJECTS="$HOME/dev_projects"
alias proj="cd $PROJECTS && l"

# UNIVERSAL - DEV ALIAS TO **CURRENT** PROJECT
alias dev="echo 'CHOOSE AN ALIAS!'"

# GET CURRENT ENVIRONMENT - ADDITIONAL CONFIGS
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.hardware.zsh";
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.dev.zsh";