# SPECIFIC
export ZSH_CONFIG="$HOME/.zshrc-config"
export NVM="true"
export EDITOR="$(which code)"
# code () { /usr/share/code/code "$@"; }

# DIRCOLORS
[ -d "${HOME}/.dircolors" ] && eval `dircolors ${HOME}/.dircolors/dircolors-solarized-master/dircolors.ansi-dark`;

# UNIVERSAL
PROJECTS="$HOME/dev_projects"
alias dev="cd $PROJECTS && l"
alias www="cd /var/www && l"
