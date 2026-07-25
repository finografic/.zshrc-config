# ============================================================================ #
# NOTE: DJAY SERVICES - LaunchAgent status check for the djay backup/sync jobs
#
# Opt-in. Nothing sources this by default. It used to run at profile load on
# both macOS profiles, which meant two `launchctl list` shell-outs — and a
# possible `launchctl load` — on every single shell.
#
# Usage:  source extras/music/djay-services.zsh && djay-services-check [--load]
# ============================================================================ #

source "${ZSHRC_ROOT:-$HOME/.zshrc-config}/lib/colors.zsh"

# Reports whether the djay LaunchAgents are loaded. With --load, loads any that
# are installed but not running.
function djay-services-check() {
	local load=false
	[[ "$1" == "--load" ]] && load=true

	local -A services=(
		[com.user.dj-crate-backup]="$HOME/Library/LaunchAgents/com.user.dj-crate-backup.plist"
		[com.user.djay-sync]="$HOME/Library/LaunchAgents/com.user.djay-sync.plist"
	)

	if ! command -v launchctl >/dev/null; then
		print "${_y}launchctl not available — macOS only${_0}"
		return 1
	fi

	local -a loaded
	loaded=(${(f)"$(launchctl list)"})

	local label plist
	for label plist in ${(kv)services}; do
		if [[ ! -f "$plist" ]]; then
			print "${_grey}${label}: not installed${_0}"
			continue
		fi

		if print -l "${loaded[@]}" | grep -q "$label"; then
			print "${_g}${label}: loaded${_0}"
			continue
		fi

		if [[ "$load" == true ]]; then
			if launchctl load "$plist" 2>/dev/null; then
				print "${_g}${label}: loaded${_0}"
			else
				print "${_r}${label}: failed to load${_0}"
			fi
		else
			print "${_y}${label}: installed but not loaded (run with --load)${_0}"
		fi
	done
}
