#!/bin/zsh

set rtp+=/opt/homebrew/opt/fzf

# Setup fzf
# ------------------------------------------------------------------------------

# V2 - MacStudio M1
if [[ ! "$PATH" == */opt/homebrew/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/opt/homebrew/bin/fzf"
fi

# Auto-completion
# ------------------------------------------------------------------------------
[[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------------------------------------------------------------------------
source "$HOME/.fzf/shell/key-bindings.zsh"
