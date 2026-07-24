# SSH-SPECIFIC:
alias logout="~."
alias lo="~."

# ENHANCED FOLDER LISTINGS
alias llh="ls -ld .?*"                                 # list hidden
alias ll="ls -la --color -h --group-directories-first" #

# LIST PERMISSIONS -- HOW TO ADD COLOR ??
alias lp="stat -c '%A  %a  %U:%G  ___  %n' *" # SIMPLE

# MAIN DIRECTORY LISTER FOR THIS ENV
alias l="listing"
# alias ls="eval `dircolors -b ${HOME}/.dircolors` && ls -Alh --color" # list hidden

# ???
alias lr1="find $(pwd) -mtime -1 -ls -maxdepth 1"
alias lr2="k -rAth"

# NEW (2024-05)
alias vh="cd /usr/local/lsws/conf/vhosts/ && l"
alias lsws="cd /usr/local/lsws && l"
alias ws="cd /usr/local/lsws && l"

alias example="cd /usr/local/lsws/Example && l"

# APNAES USER:
alias api="cd /usr/local/lsws/api && l"
alias admin="cd /usr/local/lsws/Example && l"
alias adminV1="cd /usr/local/lsws/Example/apnaes-web && l"
# alias lsws="cd /usr/local/lsws && l"
# alias ws="cd /usr/local/lsws && l"
