#############################################
############ FUNCTIONS + ALIASES ############
#############################################

alias reset=". ${HOME}/.zshrc"
alias update_cache=". ${HOME}/.zshrc; npm cache verify"
alias cdz="cd ${ZSHRC_ROOT} && l"
alias os="cd ${HOME}/os-setup && l"
alias ai="sudo apt install -y $1"
alias npmls="npm ls -g --depth=0"

#########################################
############  FILE LISTINGS  ############
#########################################

# LIST SYSTEM PATHS
alias path="tr ':' '\n' <<< '$PATH'"
alias PATH="tr ':' '\n' <<< '$PATH'"

# ENHANCED FOLDER LISTINGS
alias llh="ls -ld .?*" # list hidden
alias ll="ls -la --color -h --group-directories-first" #

# subl $(dirname $(gem which colorls))/yaml
alias lc="colorls -lA --sort-dirs --git-status --report && echo \n" # RUBY GEM ls w/ icons :D

# LIST PERMISSIONS -- HOW TO ADD COLOR ??
alias lp="stat -c '%A  %a  %U:%G  ___  %n' *"    # SIMPLE

function listing() {
  k -Ah $1
  [ -d .git ] && git status;
}

function listing_exa() {
  # exa --long --all --group-directories-first --accessed --time-style=long-iso --git $1
  EXA_IGNORES=".DS_Store|Icon*|.directory";
  exa --long --all --ignore-glob="${EXA_IGNORES}" --group-directories-first --accessed --time-style=long-iso --git $1
  [ -d .git ] && git status;
}

function lr() {
  k -rAth
}

# DEFAULT MAIN DIRECTORY LISTERS
alias l1="listing"
alias l2="listing_exa"
alias l="listing_exa"
# alias ls="eval `dircolors -b ${HOME}/.dircolors` && ls -Alh --color" # list hidden

# ???
alias lr="find $(pwd) -mtime -1 -ls -maxdepth 1"

# CD NAVIGATION
alias -1="cd ../ && l"
alias -2="cd ../../ && l"
alias -3="cd ../../../ && l"
alias -4="cd ../../../../ && l"
alias -5="cd ../../../../../ && l"

# TREE LISTING
alias t="exa --tree --group-directories-first --level 2"
alias t2="tree --dirsfirst -L 2"

########################################
############  FOLDER FAVES  ############
########################################

# FOLDER FAVORITES
alias home="cd ~"
alias www="cd /var/www/ && l"
# alias test="cd /var/www/html/test && l"








