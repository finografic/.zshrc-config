# ============================================================================ #
# NOTE: DOCTOR - `zdoctor` machine health check (definitions only)
#
# Checks the MACHINE: missing tools, insecure state, service health. Distinct
# from `zconf doctor`, which lints the REPO.
#
# Everything here used to run inline at profile load. It is now on demand.
# ============================================================================ #

source "$ZSHRC_ROOT/lib/colors.zsh"

function zdoctor() {
	print "${_c}zdoctor${_0} — checking this machine\n"

	zdoctor-tools
	[[ "$OS_NAME" == "macOS" ]] && zdoctor-macos-firewall

	print "\n${_grey}done${_0}"
}

# Reports which optional CLI tools are present. Absence is informational, not an
# error — the config degrades gracefully without any of these.
function zdoctor-tools() {
	print "${_c}tools${_0}"

	local -a wanted=(git zsh fzf fastfetch neofetch bat eza rclone node pnpm gh)
	local tool
	for tool in "${wanted[@]}"; do
		if command -v "$tool" >/dev/null; then
			print "  ${_g}✓${_0} $tool"
		else
			print "  ${_grey}·${_0} ${_grey}$tool (not installed)${_0}"
		fi
	done
}

# Warns when the macOS application firewall is off.
function zdoctor-macos-firewall() {
	print "\n${_c}firewall${_0}"

	local fw=/usr/libexec/ApplicationFirewall/socketfilterfw
	if [[ ! -x "$fw" ]]; then
		print "  ${_grey}· socketfilterfw not available${_0}"
		return 0
	fi

	if "$fw" --getglobalstate 2>/dev/null | grep -qi "enabled"; then
		print "  ${_g}✓${_0} enabled"
	else
		print "  ${_y}⚠${_0}  disabled — System Settings → Network → Firewall"
	fi
}
