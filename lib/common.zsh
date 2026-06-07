# ============================================================================ #
# FUNCTIONS + ALIASES
# ============================================================================ #

alias reset=". ${HOME}/.zshrc"
alias update_cache=". ${HOME}/.zshrc; npm cache verify"
alias cdz="cd ${ZSHRC_ROOT} && l"
alias os="cd ${HOME}/os-setup && l"
alias ai="sudo apt install -y $1"
alias npmls="npm ls -g --depth=0"

# ============================================================================ #
# FILE LISTINGS
# ============================================================================ #

# LIST SYSTEM PATHS
alias path="tr ':' '\n' <<< '$PATH'"
alias PATH="tr ':' '\n' <<< '$PATH'"

# CORE
alias ls="ls -lAh"
alias ll="ls -la --color -h --group-directories-first"
alias l="ls -lAh" # TODO: replace with `k`

# ENHANCED FOLDER LISTINGS
alias llh="ls -ld .?*"                                 # list hidden

# subl $(dirname $(gem which colorls))/yaml
alias lc="colorls -lA --sort-dirs --git-status --report && echo \n" # RUBY GEM ls w/ icons :D

# LIST PERMISSIONS -- HOW TO ADD COLOR ??
alias lp="stat -c '%A  %a  %U:%G  ___  %n' *" # SIMPLE

function listing() {
  k -Ah $1
  [ -d .git ] && git status -uno
}

function listing-eza() {
  # eza --long --all --group-directories-first --accessed --time-style=long-iso --git $1
  EZA_IGNORES=".DS_Store|Icon*|.directory"
  eza --long --all --ignore-glob="${EZA_IGNORES}" --group-directories-first --accessed --time-style=long-iso --git $1
  [ -d .git ] && git status -uno
}

function lr() {
  k -rAth
}

# DEFAULT MAIN DIRECTORY LISTERS
alias l1="listing"
alias l2="listing-eza"
alias l="listing-eza"
# alias ls="eval `dircolors -b ${HOME}/.dircolors` && ls -Alh --color" # list hidden

# ???
alias lr="find $(pwd) -mtime -1 -ls -maxdepth 1"

# ============================================================================ #
# NAVIGATION
# ============================================================================ #

# CD NAVIGATION
alias -1="cd ../ && l"
alias -2="cd ../../ && l"
alias -3="cd ../../../ && l"
alias -4="cd ../../../../ && l"
alias -5="cd ../../../../../ && l"

# TREE LISTING
# NOTE: /opt/homebrew/bin/tree
alias t="eza --tree --group-directories-first --level 2"
alias t2="tree --dirsfirst -L 2"
