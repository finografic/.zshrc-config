################################################
########## FINAL INI + RESET MESSAGE   #########
################################################
# NOTE: PATH deduplication done at end of main.zsh via build-path.mjs

# ========================================================================= #
# SPLASH SCREEN - CUSTOM WIDGETS

source "$ZSHRC_ROOT/lib/widgets.zsh"

show_tmutil_snapshots
show_custom_launch_agents
# show_docker_containers
show_ports

# SPLASH SCREEN BANNER + OS / SYS INFO..
show_splash_neofetch

show_splash_sys_banner
show_splash_sys_banner_footer_info

# VERSIONS: OS, NodeJS, npm... etc
show_os_version_and_sys_info

