# SPECIFIC ===================================================== #
export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/$ZENV"
export NVM="true"
# ============================================================== #

# EDITOR + IDE OVERRIDES (set originally in main.zsh)
export EDITOR="vim"
export IDE="false"
edit () { "$EDITOR $@"; }
code () { eval "$(which jmate) $@"; }

# DIRCOLORS
[ -d "${HOME}/.dircolors" ] && eval `dircolors ${HOME}/.dircolors/dircolors-solarized-master/dircolors.ansi-dark`;

# TODO: HARDWARE (OR MOST?) SHOULD BE ENV-SPECIFIC
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.hardware.zsh";
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.paths.zsh";
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.aliases.zsh";
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.dev.zsh";
