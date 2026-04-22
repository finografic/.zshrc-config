#!/bin/zsh

# ============================================================================ #
# Docker Container Environment Configuration
# ============================================================================ #
# This profile is automatically loaded when running inside Docker containers
# It provides a lightweight, container-friendly shell setup using the host's
# mounted zshrc-config directory
# ============================================================================ #

export ZSHRC_ENV="docker-dev"
export ZSHRC_PLATFORM="linux"
export LANG="en_US.UTF-8"
export EDITOR="nvim"
export VISUAL="nvim"

# SPECIFIC =================================================================== #

export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/$ZENV"
export NVM="true"

# TODO: LEAVE DISABLED ??
# Skip hardware detection in containers
# export SKIP_HARDWARE_DETECT=1

# TODO: LEAVE DISABLED ??
# Skip resource-intensive features
# export SKIP_NVM_AUTOLOAD=1
# export SKIP_FANCY_PROMPTS=0  # Keep minimal prompt

# ============================================================================ #
# PATH Configuration
# ============================================================================ #

# Use container's native binaries, not host macOS binaries
# Add common Linux paths
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/linuxbrew/.linuxbrew/bin:$PATH"

# Add user bin if exists
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# Don't load host macOS binary directories
# export PATH="$ZSHRC_ROOT/tools/bin-$(uname -m):$PATH"  # SKIP - these are macOS binaries

# ============================================================================ #
# Core Libraries (Container-Safe)
# ============================================================================ #

# Common utilities (safe for containers)
source "$ZSHRC_ROOT/lib/utils.zsh"

# Git configuration (very useful in dev containers)
source "$ZSHRC_ROOT/lib/git/index.zsh"
[[ -f "$ZSHRC_ROOT/lib/git.stashes.zsh" ]] && source "$ZSHRC_ROOT/lib/git.stashes.zsh"

# Development tools
source "$ZSHRC_ROOT/lib/dev.zsh"

# Common aliases (container-friendly)
source "$ZSHRC_ROOT/lib/aliases.common.zsh"

# History configuration
source "$ZSHRC_ROOT/core/history.zsh"

# ============================================================================ #
# Container-Specific Aliases
# ============================================================================ #

# INCLUDES: DEV ZENV-SPECIFIC
# source "$ZENV_PATH/$ZENV.paths.zsh"
source "$ZENV_PATH/$ZENV.aliases.zsh"
source "$ZENV_PATH/$ZENV.dev.zsh"

# ============================================================================ #
# Optional: FZF (if available in container)
# ============================================================================ #

if command -v fzf >/dev/null 2>&1; then
  source "$ZSHRC_ROOT/lib/fzf.zsh" 2>/dev/null || true
fi

# ============================================================================ #
# Optional: Node Version Manager (skip by default for speed)
# ============================================================================ #

# Uncomment if you need NVM in containers
if [[ -z "$SKIP_NVM_AUTOLOAD" ]]; then
  source "$ZSHRC_ROOT/lib/nvm.zsh" 2>/dev/null || true
fi

# ============================================================================ #
# Docker-Specific Environment Variables
# ============================================================================ #

# Indicate we're in a container
export IN_DOCKER=1
export DOCKER_CONTAINER=1

# Disable interactive prompts for apt, npm, etc.
export DEBIAN_FRONTEND=noninteractive
export NPM_CONFIG_LOGLEVEL=warn

# ============================================================================ #
# Banner (optional - comment out if too verbose)
# ============================================================================ #

source "$ZSHRC_ROOT/_zenvs/docker-dev/docker-dev.banner.zsh"

# ============================================================================ #
# Cleanup
# ============================================================================ #

# Remove duplicate PATH entries
if command -v flatten_PATH >/dev/null 2>&1; then
  flatten_PATH
fi

# ============================================================================ #
# Simple Prompt (fallback if none set)
# ============================================================================ #

if [[ -z "$PROMPT" ]]; then
  PROMPT='%F{cyan}🐳%f %F{green}%n@%m%f:%F{blue}%~%f %# '
fi

# ============================================================================ #
# Welcome Message
# ============================================================================ #

echo -e "${_g}✓${_0} Docker container environment loaded"
echo -e "${_y}💡${_0} Working directory: ${_c}$(pwd)${_0}"

if [[ -d /workspace ]]; then
  echo -e "${_y}💡${_0} Workspace mounted at: ${_c}/workspace${_0}"
fi

echo ""
