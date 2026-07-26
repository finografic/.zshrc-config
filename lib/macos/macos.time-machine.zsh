# ============================================================================ #
# NOTE: TIME MACHINE MONITOR
# Live dashboard for Time Machine backup status, NVMe I/O (disk6), and
# thermal state. Refreshes every 10s until interrupted with Ctrl+C.
# Usage: tm-monitor
# ============================================================================ #

source "$ZSHRC_ROOT/lib/colors.zsh"

function tm-monitor() {
  while true; do
    clear
    echo -e "${_c}=== Time Machine Status ===${_0}"
    tmutil status
    echo ""

    echo -e "${_y}=== NVMe Drive Activity (disk6) ===${_0}"
    iostat -d 1 1 disk6 | tail -n +3
    echo ""

    echo -e "${_m}=== System Thermal State ===${_0}"
    pmset -g thermlog | tail -5
    echo ""

    echo -e "${_g}Press Ctrl+C to stop monitoring${_0}"
    echo -e "${_w}Next update in 10 seconds...${_0}"
    sleep 10
  done
}
