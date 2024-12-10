################################
###########  THEMES  ###########
################################

# Usage: $ switch_theme refined
theme() {
  sed -i '' "s|path:themes/.*\.zsh-theme|path:themes/$1.zsh-theme|" ~/.zshrc-config/.zsh_plugins.zsh
  source ~/.zshrc
}

# Add to your .zshrc
switch_theme() {
  sed -i '' "s|path:themes/.*\.zsh-theme|path:themes/$1.zsh-theme|" ~/.zshrc-config/.zsh_plugins.zsh
  source ~/.zshrc
}
# Usage: switch_theme refined

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
