# ============================================================================ #
# NOTE: DOCKER-DEV - Generic Linux container
#
# Auto-selected by `is-container` (core/detect.zsh). Lightweight, no host
# assumptions: uses the container's own binaries, never the mounted macOS ones.
# ============================================================================ #

export ZSHRC_ENV="docker-dev"
export ZSHRC_PLATFORM="linux"
export LANG="en_US.UTF-8"
export EDITOR="nvim"
export VISUAL="nvim"

export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/profiles/$ZENV"

# nvm is opt-out in containers: many images pin their own node.
export NVM="${NVM:-true}"
[[ -n "$SKIP_NVM_AUTOLOAD" ]] && export NVM="false"

# ============================================================================ #
# NOTE: PATH
#
# Container-native paths only. core/history.zsh is already sourced by
# bootstrap/00-profiling.zsh, so this profile does not repeat it.
# ============================================================================ #

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/linuxbrew/.linuxbrew/bin:$PATH"
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# ============================================================================ #
# NOTE: MANIFEST
# ============================================================================ #

ZENV_PRESET=container
ZENV_FEATURES=(aliases dev)

# fzf is genuinely optional in a container image.
ZENV_MODULES=()
command -v fzf >/dev/null 2>&1 && ZENV_MODULES+=(fzf)

zenv-load

# ============================================================================ #
# NOTE: CONTAINER ENVIRONMENT
# ============================================================================ #

export IN_DOCKER=1
export DOCKER_CONTAINER=1

# Non-interactive package managers
export DEBIAN_FRONTEND=noninteractive
export NPM_CONFIG_LOGLEVEL=warn

# Simple prompt (fallback if none set)
if [[ -z "$PROMPT" ]]; then
  PROMPT='%F{cyan}🐳%f %F{green}%n@%m%f:%F{blue}%~%f %# '
fi
