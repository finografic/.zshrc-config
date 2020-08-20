export ZSH=$HOME/.oh-my-zsh

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
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

# Set name of the theme to load. Optionally, if you set this to "random"
# ZSH_THEME="robbyrussell"
# ZSH_THEME="af-magic"
# ZSH_THEME="fino-time" # buggy
# ZSH_THEME="obraun"  # TOO LONG, BUT GREAT !
# ZSH_THEME="sporty_256" # NO FULL PATH :(
# ZSH_THEME="pure"
# ZSH_THEME="dpoggi"
# ZSH_THEME="gallois"
# ZSH_THEME="powerlevel9k/powerlevel9k"
# ZSH_THEME="agnoster"
ZSH_THEME="fino-time"
# ZSH_THEME=""

# RANDOM
# ZSH_THEME=random # RANDOM :) !!

## OTHER THEMES
# ZSH_THEME="muse"
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
source "${HOME}/.zgen/zgen.zsh"
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
  git
  k
  sudo
  zsh-completions
  zsh-syntax-highlighting
)

# plugins+=(zsh-autosuggestions)

if ! zgen saved; then

  zgen oh-my-zsh

  # list of plugins from zsh I use
  # see https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins

  # zgen oh-my-zsh plugins/bower
  # zgen oh-my-zsh plugins/brew
  zgen oh-my-zsh plugins/colored-man
  zgen oh-my-zsh plugins/colored-man-pages
  zgen oh-my-zsh plugins/docker
  zgen oh-my-zsh plugins/emoji
  zgen oh-my-zsh plugins/git
  zgen oh-my-zsh plugins/git-extras
  zgen oh-my-zsh plugins/gitignore
  zgen oh-my-zsh plugins/golang
  zgen oh-my-zsh plugins/node
  zgen oh-my-zsh plugins/npm
  # zgen oh-my-zsh plugins/osx
  zgen oh-my-zsh plugins/pip
  zgen oh-my-zsh plugins/python
  zgen oh-my-zsh plugins/sudo
  zgen oh-my-zsh plugins/command-not-found
  zgen oh-my-zsh plugins/ubuntu
  zgen oh-my-zsh plugins/urltools
  zgen oh-my-zsh plugins/vundle
  zgen oh-my-zsh plugins/web-search
  zgen oh-my-zsh plugins/zsh-history-substring-search
  zgen oh-my-zsh plugins/zsh-syntax-highlighting
  zgen oh-my-zsh plugins/z

  # https://github.com/Tarrasch/zsh-autoenv
  zgen load Tarrasch/zsh-autoenv
  # https://github.com/zsh-users/zsh-completions
  zgen load zsh-users/zsh-completions src

  # ls => k ("git aware" ls)
  zgen load rimraf/k

  # It takes control, so load last
  # zgen oh-my-zsh plugins/tmux

  # NEW TESTING..

  zgen load Tarrasch/zsh-autoenv
  zgen load junegunn/fzf
  zgen load bhilburn/powerlevel9k

  zgen save
fi

source $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
