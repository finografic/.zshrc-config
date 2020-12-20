# SPECIFIC
export ZSHRC_ROOT="$HOME/.zshrc-config"
export NVM="true"
export IDE="code-insiders"
export EDITOR="$(which $IDE)"
# code () { eval "$(which jmate) $@"; }
code () { sudo $IDE "$@"; }

# DIRCOLORS
[ -d "${HOME}/.dircolors" ] && eval `dircolors ${HOME}/.dircolors/dircolors-solarized-master/dircolors.ansi-dark`;

# UNIVERSAL
alias dls="cd $HOME/Downloads && l"
alias www="cd /var/www && l"

# UNIVERSAL - DEV
PROJECTS="$HOME/dev_projects"
alias proj="cd $PROJECTS && l"

# UNIVERSAL - DEV ALIAS TO **CURRENT** PROJECT
alias dev="konsole --tabs-from-file /home/REDACTED/bin/konsole-tabs.sh"

# GET CURRENT ENVIRONMENT - ADDITIONAL CONFIGS

# TODO: HARDWARE (OR MOST?) SHOULD BE ENV-SPECIFIC
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.hardware.zsh";
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.dev.zsh";