# TODO: UPDATE SYSTEM .zshrc TO USE THIS CODE

# Profiling
zmodload zsh/zprof

ZSH_DISABLE_COMPFIX=true

# Load history configuration first
source ${ZDOTDIR:-~}/.zshrc-config/lib/history.zsh

# Initialize completion system
autoload -Uz compinit
compinit

# Antidote plugins
source ${ZDOTDIR:-~}/.antidote/antidote.zsh
antidote bundle <${ZDOTDIR:-~}/.zshrc-config/.zsh_plugins.zsh >${ZDOTDIR:-~}/.zshrc-config/.zsh_plugins.generated.zsh

# DEPRECATED:
# source ${ZDOTDIR:-~}/.zshrc-config/.zsh_plugins.generated.zsh

# NEW: Load generated plugins based on OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    source ${ZDOTDIR:-~}/.zshrc-config/.zsh_plugins.generated.linux.zsh
else
    source ${ZDOTDIR:-~}/.zshrc-config/.zsh_plugins.generated.macos.zsh
fi

# Main configuration
source "$HOME/.zshrc-config/main.zsh"
