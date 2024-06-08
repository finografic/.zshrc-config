# SSH-SPECIFIC:
alias logout="~."
alias lo="~."

# ENHANCED FOLDER LISTINGS
alias llh="ls -ld .?*" # list hidden
alias ll="ls -la --color -h --group-directories-first" #

# LIST PERMISSIONS -- HOW TO ADD COLOR ??
alias lp="stat -c '%A  %a  %U:%G  ___  %n' *"    # SIMPLE

# MAIN DIRECTORY LISTER FOR THIS ENV
alias l="listing"
# alias ls="eval `dircolors -b ${HOME}/.dircolors` && ls -Alh --color" # list hidden

# ???
alias lr1="find $(pwd) -mtime -1 -ls -maxdepth 1"
alias lr2="k -rAth"

# NEW (2024-05)
alias bat="batcat"

# NEW (2024-05)
alias vh="cd /usr/local/lsws/conf/vhosts/ && l"
alias lsws="cd /usr/local/lsws && l"
alias ws="cd /usr/local/lsws && l"

alias example="cd /usr/local/lsws/Example && l"

# LOGS...
LSWS_LOGS_PATH="/usr/local/lsws/logs"
# alias logs="lnav /usr/local/lsws/admin/logs/access.log"
# alias errs="lnav /usr/local/lsws/admin/logs/error.log"
# alias access="sudo ${LSWS_LOGS_PATH}/access.log"
alias access="sudo /usr/local/lsws/api/logs/access.log"
alias errs="sudo ${LSWS_LOGS_PATH}/error.log"
alias logs="sudo ${LSWS_LOGS_PATH}/stderr.log"


# APNAES USER:
alias api2="cd /home/apnaes/api/html && l"
# alias lsws="cd /usr/local/lsws && l"
# alias ws="cd /usr/local/lsws && l"
