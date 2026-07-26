# ============================================================================ #
# NOTE: HOME-MACOS - Personal Mac, full interactive terminal
# ============================================================================ #

export ZSHRC_ROOT="$HOME/.zshrc-config"
export ZENV_PATH="$ZSHRC_ROOT/profiles/$ZENV"
export NVM="true"

export GRAPHIFY_PYTHON_PINNED="$HOME/.local/pipx/venvs/graphifyy/bin/python"

# ============================================================================ #
# NOTE: MANIFEST
# ============================================================================ #

ZENV_PRESET=full
ZENV_MODULES=(llms macos ghostty)
ZENV_FEATURES=(backups aliases dev)
ZENV_OPT_IN=(music/backup-dj-crate music/djay_icloud_sync)

zenv-load

# ============================================================================ #
# NOTE: PROFILE-SPECIFIC
#
# Everything below needs functions the manifest just defined, so it has to come
# after `zenv-load` — `macos-brew-shellenv` comes from the `macos` module and
# `update-ghostty-config` from `ghostty`.
# ============================================================================ #

# Dynamic brew prefix (Apple Silicon vs Intel) — lib/macos/macos.brew.zsh
macos-brew-shellenv

# Keeps the installed ghostty config in sync with the tracked one. No-ops (and
# spawns nothing) unless the tracked file is actually newer.
update-ghostty-config

# Docker cleanup helpers. Lives under scripts/ rather than extras/, so it is
# sourced directly instead of via ZENV_OPT_IN.
source "$ZSHRC_ROOT/scripts/docker-cleanup.zsh"

# ============================================================================ #
# NOTE: NOTES
#
# - LaunchAgent status for the djay backup/sync jobs is no longer checked on
#   every shell (it cost two `launchctl list` shell-outs and could load services
#   behind your back). To check them:
#     source "$ZSHRC_ROOT/extras/music/djay-services.zsh" && djay-services-check
# - Machine health (firewall, tool presence): run `zdoctor`.
# - PM2 under launchd, iTerm2 shell integration and the Loupedeck path fixup all
#   used to sit here commented out; they are in git history if ever needed.
# ============================================================================ #
