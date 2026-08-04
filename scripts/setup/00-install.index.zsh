#!/bin/zsh

# Orchestrates a fresh-machine install by running every numbered
# scripts/setup/NN-install-*.zsh script in this directory, in order.
# Run manually: zsh ~/.zshrc-config/scripts/setup/00-install.index.zsh
# Never invoked automatically from the shell-start load path.

source "${ZSHRC_ROOT:-$HOME/.zshrc-config}/lib/colors.zsh"

function install-index() {
  local self_dir script

  self_dir="${0:A:h}"

  print "${_C}Installing zshrc-config dependencies...${_0}"
  print ""

  for script in "$self_dir"/[0-9][0-9]-install-*.zsh; do
    [[ -f "$script" ]] || continue
    print "${_c}── ${script:t} ──${_0}"
    zsh "$script" || {
      print "${_r}✗ ${script:t} failed${_0}"
      return 1
    }
    print ""
  done

  print "${_G}✨ All installs complete.${_0}"
  print "Next: exec zsh, set terminal font to 'MesloLGS NF', run 'p10k configure'"
}

install-index
