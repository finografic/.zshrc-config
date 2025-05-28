# ============================================================= #
# NOTE: 1. PRE-INIT

# More detailed profiling
zmodload zsh/zprof

ZSH_DISABLE_COMPFIX=true

# Load history configuration first
source ${ZDOTDIR:-~}/.zshrc-config/lib/history.zsh

# Initialize completion system
autoload -Uz compinit
compinit

# ============================================================= #
# NOTE: 2. CHECK ANTIDOTE

# Check if antidote is installed, if not, clone it
if [[ ! -d ${ZDOTDIR:-~}/.antidote ]]; then
  echo "Installing antidote..."
  git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote
fi

# ============================================================= #
# NOTE: 3. INIT ANTIDOTE + PLUGINS

# Antidote plugins
source ${ZDOTDIR:-~}/.antidote/antidote.zsh
antidote bundle <${ZDOTDIR:-~}/.zshrc-config/plugins/.zsh_plugins.zsh >${ZDOTDIR:-~}/.zshrc-config/plugins/.zsh_plugins.generated.zsh
source ~/.zshrc-config/plugins/.zsh_plugins.generated.zsh

# ============================================================= #
# NOTE: 4. PROMPT p10k

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================= #
# NOTE: 5. MY ZSHRC CONFIG !!

source "$HOME/.zshrc-config/main.zsh"
