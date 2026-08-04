#!/bin/zsh

# Installs Neovim and symlinks this repo's tracked config (configs/nvim)
# into ~/.config/nvim.
# Run manually: scripts/setup/06-install-nvim.zsh (or via 00-install.index.zsh)
# Never invoked automatically from the shell-start load path.

source "${ZSHRC_ROOT:-$HOME/.zshrc-config}/lib/colors.zsh"

function install-nvim() {
  local zshrc_root config_src config_dest os

  zshrc_root="${ZSHRC_ROOT:-$HOME/.zshrc-config}"
  config_src="$zshrc_root/configs/nvim"
  config_dest="$HOME/.config/nvim"
  os="$(uname -s)"

  if command -v nvim >/dev/null; then
    print "${_g}✅ Neovim already installed${_0} ($(nvim --version | head -n1))"
  elif [[ "$os" == "Darwin" ]]; then
    if ! command -v brew >/dev/null; then
      print "${_r}Homebrew not found — install it first (scripts/setup/01-install-homebrew.zsh)${_0}"
      return 1
    fi
    print "${_c}Installing Neovim via Homebrew...${_0}"
    brew install neovim
  elif command -v apt >/dev/null; then
    print "${_c}Installing Neovim via apt...${_0}"
    sudo apt update
    sudo apt install -y neovim
  elif command -v pacman >/dev/null; then
    print "${_c}Installing Neovim via pacman...${_0}"
    sudo pacman -S --needed neovim
  else
    print "${_r}No supported package manager found (brew/apt/pacman).${_0}"
    print "Install Neovim manually: https://github.com/neovim/neovim/blob/master/INSTALL.md"
    return 1
  fi

  if [[ -L "$config_dest" && "$(readlink "$config_dest")" == "$config_src" ]]; then
    print "${_g}✅ ~/.config/nvim already symlinked to $config_src${_0}"
    return 0
  fi

  if [[ -e "$config_dest" ]]; then
    print "${_r}~/.config/nvim already exists and isn't the expected symlink — leaving it alone.${_0}"
    print "Move it aside, then re-run this script to symlink $config_src"
    return 1
  fi

  mkdir -p "$HOME/.config"
  ln -s "$config_src" "$config_dest"
  print "${_g}✅ Symlinked${_0} $config_dest -> $config_src"
}

install-nvim
