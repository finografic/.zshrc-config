#!/bin/zsh

# Installs Homebrew (macOS package manager this config relies on).
# Run manually: scripts/setup/01-install-homebrew.zsh (or via 00-install.index.zsh)
# Never invoked automatically from the shell-start load path.

source "${ZSHRC_ROOT:-$HOME/.zshrc-config}/lib/colors.zsh"

function install-homebrew() {
  if command -v brew >/dev/null; then
    print "${_g}✅ Homebrew already installed${_0} ($(brew --version | head -n1))"
    return 0
  fi

  print "${_c}Installing Homebrew...${_0}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ "$(uname -m)" == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >>~/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  print "${_g}✅ Homebrew installed${_0}"
}

install-homebrew
