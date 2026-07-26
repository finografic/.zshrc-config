# ============================================================================ #
# NOTE: OFFICE-MACOS - Work Mac. Intentionally neutral: this is a template
# demonstrating the pattern, not a real workplace setup.
# TODO: populate per employer.
# ============================================================================ #

export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/profiles/${ZENV}"
export NVM="true"

# ============================================================================ #
# NOTE: MANIFEST
# ============================================================================ #

ZENV_PRESET=full
ZENV_MODULES=(macos ghostty)
ZENV_FEATURES=(aliases dev)

zenv-load

# ============================================================================ #
# NOTE: PROFILE-SPECIFIC (needs functions the manifest just defined)
# ============================================================================ #

# Dynamic brew prefix (Apple Silicon vs Intel) — lib/macos/macos.brew.zsh
macos-brew-shellenv

# NOTE: UPDATE GHOSTTY CONFIG
update-ghostty-config

# ============================================================================ #

# Git identity is a one-time machine-setup step, not a shell-start step.
# Run scripts/setup/configure-git-identity.zsh once per machine instead.

# Machine health (firewall state, tool presence): run `zdoctor` on demand —
# lib/doctor.zsh. LaunchAgent status for opt-in extras (if any):
#   source "$ZSHRC_ROOT/extras/music/djay-services.zsh" && djay-services-check
