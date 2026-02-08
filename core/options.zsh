#!/bin/zsh
# ============================================================================ #
# NOTE: CORE OPTIONS - Zsh settings, completion, keybindings
# ============================================================================ #

# COLOR ============================
# Use modern completion system
[ "$(dircolors -b 2>/dev/null)" ] && eval "$(dircolors -b)"

# Essential completion settings..
zstyle ':completion:*' menu select=2
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ZSH SETTINGS ============================

# Load keybindings (history is loaded in bootstrap/00-profiling.zsh)
source "$ZSHRC_ROOT/core/keybindings.zsh"

# ANTIDOTE SETTINGS ============================

# VERY CORE FEATURES !!
setopt autocd
# Enable autocd - allows changing directories without typing 'cd':
# - Type a directory path directly: ~/Documents
# - Drag & drop folders from Finder/Explorer
# - Use .. to go up a directory

setopt auto_pushd        # Push the current directory visited on the stack
setopt pushd_ignore_dups # Do not store duplicates in the stack
setopt pushd_minus       # Exchanges meanings of +/- when used with a number to specify a directory in the stack
