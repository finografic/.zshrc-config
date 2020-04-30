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

# LOCAL: DEV
alias da2="cd $PROJECTS/da2 && l"
alias cv="cd $PROJECTS/cv && l"
alias cv2="cd $PROJECTS/cv-v2 && l"
alias rock="cd $PROJECTS/devilbox/data/www/rock01baby && l"
# alias jod="cd $PROJECTS/devilbox/data/www/JODHPUR && l"
alias oh="cd $PROJECTS/app-test/ && l"
alias app="cd $PROJECTS/app-axios/ && l"
# alias imatch="cd $PROJECTS/app-imatchination/ && l"
alias jst="cd $PROJECTS/js-learning/src/ && l"
# alias green="cd $PROJECTS/greenPower/ && l"
alias cratez="cd $PROJECTS/cratez/ && l"
alias pilot="cd $PROJECTS/auto-pilot/ && l"
alias esm="cd $PROJECTS/starter-esm/ && l"
alias apps="cd $HOME/.local/share/applications/ && l"

# REMOTE: A2 HOSTING
# alias a2="ssh -p 7822 67.209.azs115.154 -l ubuntu"
alias a2="ssh -R 52698:localhost:52698 REDACTED-IP -p 7822 -l ubuntu"
