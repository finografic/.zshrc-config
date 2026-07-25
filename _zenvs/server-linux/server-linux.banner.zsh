# BANNER - hostname + distro + uptime is more useful than a figlet on a box
# you SSH into.

local distro="Linux"
if [[ -r /etc/os-release ]]; then
  distro="$(source /etc/os-release; print -- "$PRETTY_NAME")"
fi

print "${_g}SERVER${_0}  ${_c}::${_0} $(hostname)  ${_c}::${_0} ${distro}  ${_c}::${_0} up $(uptime -p 2>/dev/null || uptime)"
