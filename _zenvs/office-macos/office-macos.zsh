# SPECIFIC ===================================================== #
export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/_zenvs/${ZENV}"
export NVM="true"

# ============================================================================ #

# Dynamic brew path detection (shared: lib/macos/macos.brew.zsh)
macos-brew-shellenv

# ============================================================================ #

# INCLUDES: DEFAULTS
source "$ZSHRC_ROOT/lib/git.zsh"

# INCLUDES: DEV ZENV-SPECIFIC
source "$ZENV_PATH/$ZENV.aliases.zsh"
source "$ZENV_PATH/$ZENV.dev.zsh"

# ============================================================================ #

# NOTE: UPDATE GHOSTTY CONFIG
update-ghostty-config

# ============================================================================ #

# Git identity is a one-time machine-setup step, not a shell-start step.
# Run scripts/setup/configure-git-identity.zsh once per machine instead.

# Machine health (firewall state, tool presence): run `zdoctor` on demand —
# lib/doctor.zsh. LaunchAgent status for opt-in extras (if any):
#   source "$ZSHRC_ROOT/extras/music/djay-services.zsh" && djay-services-check
