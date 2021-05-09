# NEW! UPDATE oh-my-zsh // TODO: RUN ONCE/WEEK
omz update &>/dev/null
export ZSH=$HOME/.oh-my-zsh

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 (DEFAULT) lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=2000
SAVEHIST=2000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

[ "$(dircolors -b  2> /dev/null)" ] && eval "$(dircolors -b)";
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

################################
###########  THEMES  ###########
################################

# NEW!! - ZSH_THEME SET BY main.zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# ZSH_THEME="robbyrussell"
# ZSH_THEME="af-magic"
# ZSH_THEME="fino-time" # buggy
# ZSH_THEME="obraun"  # TOO LONG, BUT GREAT !
# ZSH_THEME="sporty_256" # NO FULL PATH :(
# ZSH_THEME="pure"
# ZSH_THEME="dpoggi"
# ZSH_THEME="powerlevel9k/powerlevel9k"
# ZSH_THEME="agnoster"
# ZSH_THEME="fino-time"
# ZSH_THEME=""

# RANDOM
# ZSH_THEME=random # RANDOM :) !!

## OTHER FAVE THEMES
# ZSH_THEME="muse"
# ZSH_THEME="gallois"
# ZSH_THEME="xiong-chiamiov-plus"
# ZSH_THEME="michelebologna"
# ZSH_THEME="spaceship"

# POWERLEVEL THEME
# ZSH_THEME="powerlevel10k" # CONFIG WIZARD: $ p10k configure
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# OUTPUT THEME (by path)
# print $RANDOM_THEME

######################################
###########  ZSH SETTINGS  ###########
######################################

source $ZSH/oh-my-zsh.sh
# source "${HOME}/.zgen/zgen.zsh"
[[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh # GENERIC COLORIZER
export UPDATE_ZSH_DAYS=7
CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="false"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="dd/mm/yyyy"
# ZSH_CUSTOM=/path/to/$HOME/.zgen/init.zshnew-custom-folder

# Compilation flags
export ARCHFLAGS="-arch x86_64"

################################
##########  PLUGINS  ###########
################################

plugins=(
  brew
  docker
  docker-compose
  emoji
  fd
  fzf
  git
  git-extras
  git-prompt
  github
  grc
  k
  node
  npm
  npx
  nvm
  osx
  tig
  urltools
  rsync
  sudo
  vim-interaction
  vscode
  yarn
  zsh-completions
  zsh-history-substring-search
  zsh-nvm
  zsh-autosuggestions
  zsh-syntax-highlighting
  z
);

source $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
