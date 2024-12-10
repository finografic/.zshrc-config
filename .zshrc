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
source ${ZDOTDIR:-~}/.zshrc-config/.zsh_plugins.generated.zsh

# Main configuration
source "$HOME/.zshrc-config/main.zsh"
