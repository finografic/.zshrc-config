# ============================================================================ #
# NOTE: CODEX - Minimal config for Codex agent shells (fast startup)
#
# Early exit from main.zsh — skips splash, widgets, hardware detection.
# Target: essential dev tools only, <200ms startup.
# ============================================================================ #

export ZENV='codex'
export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/$ZENV"
export LANG="en_US.UTF-8"
export EDITOR="nvim"
export VISUAL="nvim"
export OS_NAME="${OS_NAME:-macOS}"
export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
export GRAPHIFY_PYTHON_PINNED="${GRAPHIFY_PYTHON_PINNED:-$HOME/.local/pipx/venvs/graphifyy/bin/python}"
export NODE_OPTIONS="$NODE_OPTIONS --max_old_space_size=4096"

# nvm + pnpm + lib/node.zsh + .nvmrc autoload are all handled by the `node`
# module in the manifest below — this used to be hand-rolled here.
export NVM="true"

# ============================================================================ #
# NOTE: MANIFEST
#
# Agent shells get no git/dev UX layer: `git` and `dev` define a large surface
# of aliases and functions an agent will never invoke interactively, and every
# one of them is another thing that can surprise a non-interactive caller.
# ============================================================================ #

ZENV_PRESET=none
ZENV_MODULES=(colors node)
ZENV_FEATURES=(dev)

zenv-load

# ============================================================================ #
# NOTE: PROFILE-SPECIFIC
# ============================================================================ #

if command -v node >/dev/null 2>&1; then
  PATH_NODE="${NPM_GLOBALS:-$HOME/.nvm/versions/node/$(node --version)/bin}"
else
  PATH_NODE=""
fi
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/opt/homebrew/bin:$PATH_NODE:$PNPM_HOME:$PATH"

# Keep Codex shells quiet and predictable.
export PROMPT='%~ %# '
