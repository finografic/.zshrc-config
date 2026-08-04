#!/bin/zsh

# Installs fzf. Shell integration (key bindings + completion) is handled by
# lib/fzf.zsh via 'source <(fzf --zsh)' — no separate setup needed here.
# Run manually: scripts/setup/04-install-fzf.zsh (or via 00-install.index.zsh)
# Never invoked automatically from the shell-start load path.

source "${ZSHRC_ROOT:-$HOME/.zshrc-config}/lib/colors.zsh"

function install-fzf() {
  local os
  os="$(uname -s)"

  if command -v fzf >/dev/null; then
    print "${_g}✅ fzf already installed${_0} ($(fzf --version))"
    return 0
  fi

  if [[ "$os" == "Darwin" ]]; then
    if ! command -v brew >/dev/null; then
      print "${_r}Homebrew not found — install it first (scripts/setup/01-install-homebrew.zsh)${_0}"
      return 1
    fi
    print "${_c}Installing fzf via Homebrew...${_0}"
    brew install fzf
  elif command -v apt >/dev/null; then
    print "${_c}Installing fzf via apt...${_0}"
    sudo apt update
    sudo apt install -y fzf
  elif command -v pacman >/dev/null; then
    print "${_c}Installing fzf via pacman...${_0}"
    sudo pacman -S --needed fzf
  else
    print "${_r}No supported package manager found (brew/apt/pacman).${_0}"
    print "Install fzf manually: https://github.com/junegunn/fzf#installation"
    return 1
  fi

  print "${_g}✅ fzf installed${_0}"
}

install-fzf
