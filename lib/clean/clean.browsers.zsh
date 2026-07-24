# ============================================================================ #
# NOTE: CLEAN BROWSERS - Prune Firefox site storage (keeps allowlisted origins)
# Usage: clean-browsers
# ============================================================================ #

function clean-browsers() {
	echo -e "${_grey}"
	echo "Cleaning Browsers..."
	echo -e "${_0}"

	setopt local_options no_nomatch

	local PATH_FIREFOX_STORAGE="$HOME/Library/Application Support/Firefox/Profiles/3qn4h86i.dev-edition-default/storage/default"
	local PATH_FIREFOX_STORAGE_TEMP="$PATH_FIREFOX_STORAGE/__TEMP"
	local ignored

	local -a clean_ignores=(
		"https+++mail.google.com"
		"https+++calendar.google.com"
		"https+++drive.google.com"
		"https+++www.youtube.com"
		"https+++www.bing.com"
	)

	[[ ! -d "$PATH_FIREFOX_STORAGE_TEMP" ]] && mkdir "$PATH_FIREFOX_STORAGE_TEMP" 2>/dev/null

	for ignored in "${clean_ignores[@]}"; do
		[[ -d "$PATH_FIREFOX_STORAGE/$ignored" ]] && mv "$PATH_FIREFOX_STORAGE/$ignored" "$PATH_FIREFOX_STORAGE_TEMP" 2>/dev/null
	done

	rm -fr "$PATH_FIREFOX_STORAGE"/https+++* 2>/dev/null

	mv "$PATH_FIREFOX_STORAGE_TEMP"/* "$PATH_FIREFOX_STORAGE" 2>/dev/null
	rm -fr "$PATH_FIREFOX_STORAGE_TEMP" 2>/dev/null
}
