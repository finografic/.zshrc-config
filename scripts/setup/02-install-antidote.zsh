#!/bin/zsh

# Installs Antidote (this config's zsh plugin manager).
# Run manually: scripts/setup/02-install-antidote.zsh (or via 00-install.index.zsh)
# Never invoked automatically from the shell-start load path.

source "${ZSHRC_ROOT:-$HOME/.zshrc-config}/lib/colors.zsh"

function install-antidote() {
  if brew list antidote &>/dev/null; then
    print "${_g}✅ Antidote already installed${_0}"
    return 0
  fi

  if ! command -v brew >/dev/null; then
    print "${_r}Homebrew not found — install it first (scripts/setup/01-install-homebrew.zsh)${_0}"
    return 1
  fi

  print "${_c}Installing Antidote...${_0}"
  brew install antidote
  print "${_g}✅ Antidote installed${_0}"
}

install-antidote
