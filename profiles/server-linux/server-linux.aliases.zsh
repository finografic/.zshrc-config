# NOTE: "logout"/"lo" as an SSH escape sequence (~.) cannot work as a shell
# alias — it has to be typed as a literal keystroke sequence at an SSH
# prompt, not run as a command. Documented here rather than defined:
#   ~.   disconnects a hung SSH session (type it at the start of a line)

# ENHANCED FOLDER LISTINGS
alias llh="ls -ld .?*"                                 # list hidden
alias ll="ls -la --color -h --group-directories-first"

# LIST PERMISSIONS
alias lp="stat -c '%A  %a  %U:%G  ___  %n' *"

# MAIN DIRECTORY LISTER FOR THIS ENV
alias l="listing"

# NOTE: this was an alias baking in $(pwd) at shell-start time (always the
# login directory, never wherever you'd actually cd'd to). Function instead.
function lr1() { find "$PWD" -mtime -1 -ls -maxdepth 1; }
alias lr2="k -rAth"

# LSWS navigation aliases live in server-linux.lsws.zsh (only sourced when
# $LSWS_ROOT exists).
