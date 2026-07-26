# ============================================================================ #
# NOTE: ANDROID - Termux
#
# No nvm here: Termux ships its own node build and nvm's prebuilt binaries are
# not compatible.
# ============================================================================ #

export ZSHRC_ROOT="${ZSHRC_ROOT:-$HOME/.zshrc-config}"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/$ZENV"
export NVM="false"

# STORAGE_ROOT / PATH_ZSHRC are set by apply-environment-env (core/env.zsh).
export STORAGE_ROOT="${STORAGE_ROOT:-/storage/emulated/0/termux}"
export SSH_CONFIG="$STORAGE_ROOT/.zshrc-config"

# EDITOR + IDE OVERRIDES (set originally in main.zsh)
export EDITOR="vi"
export IDE="false"
function edit() { "$EDITOR" "$@"; }

# ============================================================================ #
# NOTE: MANIFEST
# ============================================================================ #

ZENV_PRESET=container
ZENV_MODULES=(paths)
ZENV_FEATURES=()

zenv-load

# ============================================================================ #
# NOTE: PROFILE-SPECIFIC
# ============================================================================ #

alias x="cd $STORAGE_ROOT && l"

REPOS="${ANDROID_REPOS:-$HOME/dev_projects}"
alias dev="cd $REPOS && l"
alias www="cd /var/www && l"
alias pilot="cd $STORAGE_ROOT/auto-pilot && l"

function repos() {
  cd "$REPOS" && l
}
