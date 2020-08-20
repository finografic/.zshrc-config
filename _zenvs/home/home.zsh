# SPECIFIC
export ZSHRC_ROOT="$HOME/.zshrc-config"
export NVM="true"
export IDE="code-insiders"
export EDITOR="$(which $IDE)"
# code () { sudo "/usr/local/bin/jmate" "$@"; }
code () { sudo $IDE "$@"; }

# DIRCOLORS
[ -d "${HOME}/.dircolors" ] && eval `dircolors ${HOME}/.dircolors/dircolors-solarized-master/dircolors.ansi-dark`;

# UNIVERSAL
PROJECTS="$HOME/dev_projects"
alias dev="cd $PROJECTS && l"
alias www="cd /var/www && l"
alias dls="cd $HOME/Downloads && l"
