# SPECIFIC ===================================================== #
export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/$ZENV"
export NVM="true"
# ============================================================================ #

# EDITOR + IDE OVERRIDES (set originally in main.zsh)
export EDITOR="vim"
export IDE="false"
function edit() { "$EDITOR" "$@"; }
function code() { jmate "$@"; }

source "$ZSHRC_ROOT/lib/paths.zsh"
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.aliases.zsh"
source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.dev.zsh"
source "$ZSHRC_ROOT/lib/git.zsh"

# OpenLiteSpeed module — only sourced when actually present on this box.
LSWS_ROOT="${LSWS_ROOT:-/usr/local/lsws}"
[[ -d "$LSWS_ROOT" ]] && source "$ZSHRC_ROOT/_zenvs/${ZENV}/${ZENV}.lsws.zsh"
