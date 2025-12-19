#!/usr/bin/env zsh

# ============================================================= #
# Essential Tools Installation Script for New Mac
# ============================================================= #

set -e  # Exit on error

echo "🚀 Starting installation of essential tools..."
echo ""

# ============================================================= #
# 1. HOMEBREW
# ============================================================= #

if command -v brew &> /dev/null; then
    echo "✅ Homebrew already installed"
    echo "   Version: $(brew --version | head -n1)"
else
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Detect architecture and add to PATH
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

# ============================================================= #
# 2. ANTIDOTE
# ============================================================= #

if brew list antidote &> /dev/null; then
    echo "✅ Antidote already installed"
    echo "   Version: $(brew info antidote | head -n1)"
else
    echo "📦 Installing Antidote..."
    brew install antidote
    echo "✅ Antidote installed successfully"
fi

echo ""

# ============================================================= #
# 3. POWERLEVEL10K
# ============================================================= #

if brew list powerlevel10k &> /dev/null; then
    echo "✅ Powerlevel10k already installed"
else
    echo "📦 Installing Powerlevel10k..."
    brew install powerlevel10k
    echo "✅ Powerlevel10k installed successfully"
fi

# Install Meslo Nerd Font (recommended for p10k)
echo ""
echo "🔤 Installing Meslo Nerd Font for Powerlevel10k..."

if [[ -d "/Library/Fonts/MesloLGS NF Regular.ttf" ]] || [[ -d "$HOME/Library/Fonts/MesloLGS NF Regular.ttf" ]]; then
    echo "✅ Meslo Nerd Font already installed"
else
    echo "📥 Downloading Meslo Nerd Font..."

    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    # Download fonts
    curl -fLo "MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    curl -fLo "MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    curl -fLo "MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    curl -fLo "MesloLGS NF Bold Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

    # Install fonts
    mkdir -p "$HOME/Library/Fonts"
    mv *.ttf "$HOME/Library/Fonts/"

    # Clean up
    cd - > /dev/null
    rm -rf "$TEMP_DIR"

    echo "✅ Meslo Nerd Font installed"
    echo "⚠️  IMPORTANT: Set your terminal font to 'MesloLGS NF' in Terminal/iTerm2 preferences"
fi

echo ""

# ============================================================= #
# 4. FZF
# ============================================================= #

if brew list fzf &> /dev/null; then
    echo "✅ fzf already installed"
    echo "   Version: $(brew info fzf | head -n1)"
else
    echo "📦 Installing fzf..."
    brew install fzf
    echo "✅ fzf installed successfully"
fi

# Install fzf shell integrations
echo ""
echo "🔧 Setting up fzf shell integrations..."

if [[ -f ~/.fzf.zsh ]]; then
    echo "✅ fzf shell integrations already configured"
else
    # Run fzf install script
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
echo "Installed:"
echo "  • Homebrew"
echo "  • Antidote (zsh plugin manager)"
echo "  • Powerlevel10k (zsh theme)"
echo "  • Meslo Nerd Font"
echo "  • fzf (fuzzy finder)"
echo ""
echo "📝 Next Steps:"
echo "  1. Restart your terminal or run: exec zsh"
echo "  2. Set terminal font to 'MesloLGS NF' (size 12-14 recommended)"
echo "  3. Run 'p10k configure' to customize your prompt"
echo "  4. Your .zshrc config should load automatically"
echo ""
echo "🎉 Happy hacking!"
