# ============================================================================ #
# NOTE: CLEAN DOWNLOADS - Fix double .mp4.mp4 suffixes in Downloads/dwhelper
# Usage: clean-downloads
# ============================================================================ #

function clean-downloads() {
	echo -e "${_grey}"
	echo "Cleaning Downloads..."
	echo -e "${_0}"

	setopt local_options no_nomatch

	local -a folders_to_clean=(
		$HOME/Downloads/**/*.mp4.mp4
		$HOME/dwhelper/**/*.mp4.mp4
	)

	local file
	for file in "${folders_to_clean[@]}"; do
		mv "$file" "$(echo "$file" | sed -E 's/.mp4.mp4/.mp4/')" 2>/dev/null
	done
}
