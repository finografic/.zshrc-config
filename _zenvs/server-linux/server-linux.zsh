# ============================================================================ #
# NOTE: SERVER-LINUX - Remote Linux box, reached over SSH
# ============================================================================ #

export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/$ZENV"
export NVM="true"

# EDITOR + IDE OVERRIDES (set originally in main.zsh)
export EDITOR="vim"
export IDE="false"
function edit() { "$EDITOR" "$@"; }
function code() { jmate "$@"; }

# ============================================================================ #
# NOTE: MANIFEST
# ============================================================================ #

ZENV_PRESET=full
ZENV_MODULES=()
ZENV_FEATURES=(aliases dev)

zenv-load

# ============================================================================ #
# NOTE: PROFILE-SPECIFIC
# ============================================================================ #

# OpenLiteSpeed module — only sourced when actually present on this box, so the
# profile still works on a plain Linux server with no LSWS installed.
LSWS_ROOT="${LSWS_ROOT:-/usr/local/lsws}"
[[ -d "$LSWS_ROOT" ]] && source "$ZENV_PATH/${ZENV}.lsws.zsh"
