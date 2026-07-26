# ============================================================================ #
# NOTE: HOME-LINUX - Personal Linux desktop
#
# This is the reference non-macOS desktop profile: if something here needs a
# macOS-only tool, it belongs in a macOS profile instead.
# ============================================================================ #

export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/$ZENV"
export NVM="true"

# ============================================================================ #
# NOTE: MANIFEST
# ============================================================================ #

ZENV_PRESET=full
ZENV_MODULES=()
ZENV_FEATURES=(hardware dev)

zenv-load

# ============================================================================ #
# NOTE: PROFILE-SPECIFIC
# ============================================================================ #

# DIRCOLORS
[[ -d "$HOME/.dircolors" ]] &&
  eval "$(dircolors "$HOME/.dircolors/dircolors-solarized-master/dircolors.ansi-dark")"

# UNIVERSAL
alias python="python3"
alias dls="cd $HOME/Downloads && l"
alias www="cd /var/www && l"

# UNIVERSAL - DEV
REPOS="${LINUX_REPOS:-$HOME/dev_projects}"
alias proj="cd $REPOS && l"

# UNIVERSAL - DEV ALIAS TO **CURRENT** REPO
alias dev="konsole --tabs-from-file $HOME/bin/konsole-tabs.sh"

# FIX FOR KDE PLASMA DISPLAY BUG
function kde-restart-plasma() {
  killall plasmashell
  kstart5 plasmashell
}

alias kde-restart=kde-restart-plasma
alias kde=kde-restart-plasma
