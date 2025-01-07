# Profiling
zmodload zsh/zprof

ZSH_DISABLE_COMPFIX=true

# Load history configuration first
source ${ZDOTDIR:-~}/.zshrc-config/lib/history.zsh

# Initialize completion system
autoload -Uz compinit
compinit

# Check if antidote is installed, if not, clone it
if [[ ! -d ${ZDOTDIR:-~}/.antidote ]]; then
  echo "Installing antidote..."
  git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote
fi

# Antidote plugins
source ${ZDOTDIR:-~}/.antidote/antidote.zsh
antidote bundle <${ZDOTDIR:-~}/.zshrc-config/.zsh_plugins.zsh >${ZDOTDIR:-~}/.zshrc-config/.zsh_plugins.generated.zsh

# Load generated plugins based on OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  source ${ZDOTDIR:-~}/.zshrc-config/.zsh_plugins.generated.linux.zsh
else
  source ${ZDOTDIR:-~}/.zshrc-config/.zsh_plugins.generated.macos.zsh
fi

# Main configuration
source "$HOME/.zshrc-config/main.zsh"
