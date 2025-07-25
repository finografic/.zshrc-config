#!/bin/zsh

export ZSH_DISABLE_COMPFIX=true
export ZSHRC_ROOT=$HOME/.zshrc-config

# ============================================================================ #

# 1. Environment detection (needed by everything)
source "$ZSHRC_ROOT/main-get-env.zsh"

# 2. PLUGINS ================================================================= #

source "$ZSHRC_ROOT/.zsh_plugins.zsh"

# 3. THEME + PROMPT ========================================================== #

export ZENV=$(determine_environment)
# TODO: TESTING DEFAULT THEME
# export ZSH_THEME="gallois-custom" # Using consistent theme across environments
# source "$ZSHRC_ROOT/themes/prompt.zsh"
source "$ZSHRC_ROOT/themes/default.theme.zsh"
source "$ZSHRC_ROOT/themes/themes.functions.zsh"

# 4. Core Zsh configuration (should be available everywhere) ================= #

source "$ZSHRC_ROOT/main-zsh-config.zsh"

# 5. Locale settings (fundamental) =========================================== #

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

# 6. VSCode check - exit to minimal config if needed ========================= #

if [ "$TERM_PROGRAM" = "vscode" ]; then
  # source "$ZSHRC_ROOT/_zenvs/vscode/vscode.V2.zsh"
  source "$ZSHRC_ROOT/_zenvs/vscode/vscode.zsh"
  return 0
fi

# 5. Full environment setup continues...
source "$ZSHRC_ROOT/lib/fzf.zsh"
# source "$ZSHRC_ROOT/lib/nvm.zsh"
source "$ZSHRC_ROOT/main-vendor.zsh" # pnpm and other package managers

# ============================================================================ #

# LOCALE (DEFAULT, MAY BE OVERWRITTEN BY ENV)
# Editors and IDEs
export EDITOR="nvim"
export VISUAL="nvim" # Some programs check this instead of EDITOR
export IDE="code"    # or "code-insiders" if you prefer

# Editor function (simplified)
edit() { $EDITOR "$@"; }

# VSCode aliases (macOS specific)
if [ "$OS_NAME" = "macOS" ]; then
  alias code="/Applications/Visual\ Studio\ Code.app/Contents/MacOS/Electron"
  # alias code-insiders="/Applications/Visual\ Studio\ Code\ -\ Insiders.app/Contents/MacOS/Electron"
fi

# ========================================================================== #
#  DEFAULT FULL SETUP (*not* in VSCode) ==================================== #
# ========================================================================== #

# START/RESTART: CLEAR CLI + SPINNER
clear
echo "\n"
node "$ZSHRC_ROOT/lib/spinner.js"

# CORE
source "$ZSHRC_ROOT/lib/colors.zsh"
# source "$ZSHRC_ROOT/lib/paths.$OS_NAME_LOWER.zsh"
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/bin:$PATH

# COMMON
source "$ZSHRC_ROOT/lib/utils.zsh"
source "$ZSHRC_ROOT/lib/utils.disk.zsh"
source "$ZSHRC_ROOT/lib/common.zsh"
source "$ZSHRC_ROOT/lib/dev.zsh"

# DJAY PRO SYNC SCRIPTS
source "$ZSHRC_ROOT/music/djay_icloud_sync.zsh"

# DOCKER CLEANUP SCRIPT
source "$ZSHRC_ROOT/scripts/docker-cleanup.zsh"

source "$ZSHRC_ROOT/_zenvs/$ZENV/$ZENV.zsh"
source "$ZSHRC_ROOT/lib/nvm.zsh"

# FINALIZATION OUTPUT
source "$ZSHRC_ROOT/main-fin.zsh"

# REMOVE DUPLICATES FROM PATH ================================================ #

flatten_PATH
