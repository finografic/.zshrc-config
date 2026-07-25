#!/bin/zsh

# Installs optional third-party CLI tools this config can use if present:
# fastfetch, neofetch, bat, eza, fzf, rclone, and a Nerd Font.
# Run manually per machine: scripts/setup/install-tools.zsh
# Never invoked automatically from the shell-start load path.

source "${ZSHRC_ROOT:-$HOME/.zshrc-config}/lib/colors.zsh"

function install-tools() {
  local os
  os="$(uname -s)"

  if [[ "$os" == "Darwin" ]]; then
    if ! command -v brew >/dev/null; then
      print "${_r}Homebrew not found — install it first: https://brew.sh${_0}"
      return 1
    fi
    print "${_c}Installing via Homebrew...${_0}"
    brew install fastfetch bat eza fzf rclone font-symbols-only-nerd-font
    return
  fi

  if command -v apt >/dev/null; then
    print "${_c}Installing via apt...${_0}"
    sudo apt update
    sudo apt install -y fastfetch bat eza fzf rclone
  elif command -v pacman >/dev/null; then
    print "${_c}Installing via pacman...${_0}"
    sudo pacman -S --needed fastfetch bat eza fzf rclone
  else
    print "${_r}No supported package manager found (brew/apt/pacman).${_0}"
    print "Install fastfetch, bat, eza, fzf, and rclone manually."
    return 1
  fi

  print "${_y}Nerd Font install is manual on Linux — grab one from:${_0}"
  print "  https://www.nerdfonts.com/font-downloads"
}

install-tools
