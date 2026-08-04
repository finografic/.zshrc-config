#!/bin/zsh

# Installs Powerlevel10k and the Meslo Nerd Font it requires.
# Run manually: scripts/setup/03-install-powerlevel10k.zsh (or via 00-install.index.zsh)
# Never invoked automatically from the shell-start load path.

source "${ZSHRC_ROOT:-$HOME/.zshrc-config}/lib/colors.zsh"

function install-powerlevel10k() {
  if brew list powerlevel10k &>/dev/null; then
    print "${_g}✅ Powerlevel10k already installed${_0}"
  else
    if ! command -v brew >/dev/null; then
      print "${_r}Homebrew not found — install it first (scripts/setup/01-install-homebrew.zsh)${_0}"
      return 1
    fi
    print "${_c}Installing Powerlevel10k...${_0}"
    brew install powerlevel10k
    print "${_g}✅ Powerlevel10k installed${_0}"
  fi

  if [[ -f "/Library/Fonts/MesloLGS NF Regular.ttf" || -f "$HOME/Library/Fonts/MesloLGS NF Regular.ttf" ]]; then
    print "${_g}✅ Meslo Nerd Font already installed${_0}"
    return 0
  fi

  print "${_c}Downloading Meslo Nerd Font...${_0}"
  local tmp_dir
  tmp_dir=$(mktemp -d)
  (
    cd "$tmp_dir"
    curl -fLo "MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    curl -fLo "MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    curl -fLo "MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    curl -fLo "MesloLGS NF Bold Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
    mkdir -p "$HOME/Library/Fonts"
    mv *.ttf "$HOME/Library/Fonts/"
  )
  rm -rf "$tmp_dir"
  print "${_g}✅ Meslo Nerd Font installed${_0}"
  print "${_y}⚠️  Set terminal font to 'MesloLGS NF' in Terminal/iTerm2 preferences${_0}"
}

install-powerlevel10k
