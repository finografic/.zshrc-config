#!/usr/bin/env zsh
# ============================================================================ #
# INSTALL-ZSHRC-CONFIG-DEPENDENCIES
# ============================================================================ #

# Installs core tools required by this zshrc-config repo: Homebrew, Antidote,
# Powerlevel10k, Meslo Nerd Font, fzf. Run on a fresh Mac setup.
# Usage: zsh scripts/install-zshrc-config-dependencies.zsh
# ============================================================================ #

set -e

echo "🚀 Installing zshrc-config dependencies..."
echo ""

# ============================================================================ #
# 1. HOMEBREW
# ============================================================================ #

if command -v brew &>/dev/null; then
  echo "✅ Homebrew already installed"
  echo "   Version: $(brew --version | head -n1)"
else
  echo "📦 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ $(uname -m) == 'arm64' ]]; then
    echo "🔧 Configuring Homebrew for Apple Silicon..."
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "🔧 Configuring Homebrew for Intel..."
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  echo "✅ Homebrew installed successfully"
fi
echo ""

# ============================================================================ #
# 2. ANTIDOTE
# ============================================================================ #

if brew list antidote &>/dev/null; then
  echo "✅ Antidote already installed"
  echo "   Version: $(brew info antidote | head -n1)"
else
  echo "📦 Installing Antidote..."
  brew install antidote
  echo "✅ Antidote installed successfully"
fi
echo ""

# ============================================================================ #
# 3. POWERLEVEL10K
# ============================================================================ #

if brew list powerlevel10k &>/dev/null; then
  echo "✅ Powerlevel10k already installed"
else
  echo "📦 Installing Powerlevel10k..."
  brew install powerlevel10k
  echo "✅ Powerlevel10k installed successfully"
fi

echo ""
echo "🔤 Installing Meslo Nerd Font for Powerlevel10k..."
if [[ -f "/Library/Fonts/MesloLGS NF Regular.ttf" ]] || [[ -f "$HOME/Library/Fonts/MesloLGS NF Regular.ttf" ]]; then
  echo "✅ Meslo Nerd Font already installed"
else
  echo "📥 Downloading Meslo Nerd Font..."
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  curl -fLo "MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
  curl -fLo "MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
  curl -fLo "MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
  curl -fLo "MesloLGS NF Bold Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
  mkdir -p "$HOME/Library/Fonts"
  mv *.ttf "$HOME/Library/Fonts/"
  cd - >/dev/null
  rm -rf "$TEMP_DIR"
  echo "✅ Meslo Nerd Font installed"
  echo "⚠️  Set terminal font to 'MesloLGS NF' in Terminal/iTerm2 preferences"
fi
echo ""

# ============================================================================ #
# 4. FZF
# ============================================================================ #

if brew list fzf &>/dev/null; then
  echo "✅ fzf already installed"
  echo "   Version: $(brew info fzf | head -n1)"
else
  echo "📦 Installing fzf..."
  brew install fzf
  echo "✅ fzf installed successfully"
fi

echo ""
echo "🔧 Setting up fzf shell integrations..."
if [[ -f ~/.fzf.zsh ]]; then
  echo "✅ fzf shell integrations already configured"
else
  if [[ -f "$(brew --prefix)/opt/fzf/install" ]]; then
    $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
    echo "✅ fzf shell integrations installed"
  fi
fi

echo ""
echo "============================================================="
echo "✨ Installation Complete!"
echo "============================================================="
echo ""
echo "Installed: Homebrew, Antidote, Powerlevel10k, Meslo Nerd Font, fzf"
echo ""
echo "📝 Next: exec zsh, set font to 'MesloLGS NF', run 'p10k configure'"
echo "🎉 Happy hacking!"
