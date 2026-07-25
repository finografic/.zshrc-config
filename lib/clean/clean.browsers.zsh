# ============================================================================ #
# NOTE: CLEAN BROWSERS - Prune Firefox site storage (keeps allowlisted origins)
# Usage: clean-browsers
# ============================================================================ #

function clean-browsers() {
	print "${_grey}Cleaning Browsers...${_0}"

	setopt local_options no_nomatch

	# Origins to preserve. Override in .env with FIREFOX_KEEP_ORIGINS=(...).
	local -a clean_ignores
	if (( ${+FIREFOX_KEEP_ORIGINS} )); then
		clean_ignores=("${FIREFOX_KEEP_ORIGINS[@]}")
	else
		clean_ignores=(
			"https+++mail.google.com"
			"https+++calendar.google.com"
			"https+++drive.google.com"
			"https+++www.youtube.com"
		)
	fi

	# The profile directory name is randomly generated per machine, so glob for
	# it rather than hardcoding one.
	local -a profiles=("$HOME/Library/Application Support/Firefox/Profiles"/*/storage/default(N/))

	if (( ${#profiles} == 0 )); then
		print "  no Firefox profile storage found"
		return 0
	fi

	local storage temp ignored
	for storage in "${profiles[@]}"; do
		local -a doomed=("$storage"/https+++*(N/))
		if (( ${#doomed} == 0 )); then
			continue
		fi

		temp="$storage/__TEMP"
		clean-exec mkdir -p "$temp"

		for ignored in "${clean_ignores[@]}"; do
			[[ -d "$storage/$ignored" ]] && clean-exec mv "$storage/$ignored" "$temp"
		done

		# Re-glob: the allowlisted origins have been moved out of the way.
		doomed=("$storage"/https+++*(N/))
		(( ${#doomed} )) && clean-exec rm -rf "${doomed[@]}"

		local -a preserved=("$temp"/*(N))
		(( ${#preserved} )) && clean-exec mv "${preserved[@]}" "$storage"
		clean-exec rmdir "$temp"
	done
}
