#!/bin/zsh

# Setup fzf - macOS
# ------------------------------------------------------------------------------
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if [ $OS_NAME = 'macOS' ]; then
  # V1 - MacStudio M1
  if [[ ! "$PATH" == */opt/homebrew/* ]]; then
  set rtp+=/opt/homebrew/opt/fzf
  fi
  # V2 - MacStudio M1
  if [[ ! "$PATH" == */opt/homebrew/bin* ]]; then
    export PATH="${PATH:+${PATH}:}/opt/homebrew/bin/fzf"
  fi
fi

# Setup fzf - Linux
# ------------------------------------------------------------------------------

if [ $OS_NAME = 'Linux' ]; then
  # MISSING INSTALLS..
  [ ! -d "~/.fzf" ] && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
  # MISSING INSTALLS..
  [[ ! "$(which lnav)" ]] && apt get lnav
fi

# Auto-completion
# ------------------------------------------------------------------------------
[[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------------------------------------------------------------------------
source "$HOME/.fzf/shell/key-bindings.zsh"


plugins=(... zsh-fzf-history-search)
