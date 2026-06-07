# ============================================================================ #
# FINAL INI + RESET MESSAGE
# ============================================================================ #

# NOTE: PATH deduplication done at end of main.zsh via build-path.mjs

# ============================================================================ #
# SPLASH SCREEN - CUSTOM WIDGETS
# ============================================================================ #

source "$ZSHRC_ROOT/lib/widgets.zsh"

show-tmutil-snapshots
show-custom-launch-agents
# show-docker-containers
show-ports

# SPLASH SCREEN BANNER + OS / SYS INFO..
show-splash-neofetch

show-splash-sys-banner
show-splash-sys-banner-footer-info

# VERSIONS: OS, NodeJS, npm... etc
show-os-version-and-sys-info

