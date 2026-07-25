# ============================================================================ #
# NOTE: MACOS BREW - shared Homebrew prefix detection
#
# Apple Silicon (/opt/homebrew) vs Intel (/usr/local). This used to be
# copy-pasted between home-macos.zsh and office-macos.zsh; one function now.
# ============================================================================ #

function macos-brew-shellenv() {
	if [[ -x /opt/homebrew/bin/brew ]]; then
		eval "$(/opt/homebrew/bin/brew shellenv)"
	elif [[ -x /usr/local/bin/brew ]]; then
		eval "$(/usr/local/bin/brew shellenv)"
	else
		print "Warning: Homebrew not found in /opt/homebrew/bin/brew or /usr/local/bin/brew" >&2
		return 1
	fi
}
