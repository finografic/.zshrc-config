################################################
########## FINAL INI + RESET MESSAGE   #########
################################################

# CLEAN PATH
export PATH=$(echo "$PATH" | awk -v RS=':' '!a[$1]++{if(NR>1)printf":";printf $1}')

# TODO: MOVED TO main.zsh
# ENSURE SYYSTEM LANGUAGE IS en_US
# export LANGUAGE=en_US.UTF-8

echo "\n"

# ========================================================================= #
# LIST PORTS
[[ $OS_NAME = 'Linux' && $ZENV != "apnaes" ]] && ports
[ $OS_NAME = 'macOS' ] && ports
[ $OS_NAME = 'Android' ] && $(ports 2>/dev/null)
echo "\n"

# ========================================================================= #
# SPLASH SCREEN - CUSTOM WIDGETS

source "$ZSHRC_ROOT/lib/widgets.zsh"

show_tmutil_snapshots
show_custom_launch_agents
# show_docker_containers

# SPLASH SCREEN BANNER + OS / SYS INFO..
show_splash_neofetch

show_splash_sys_banner
show_splash_sys_banner_footer_info

# VERSIONS: OS, NodeJS, npm... etc
show_os_version_and_sys_info

