# ============================================================================ #
# NOTE: CLEAN DOWNLOADS - Fix double .mp4.mp4 suffixes in Downloads/dwhelper
# Usage: clean-downloads
# ============================================================================ #

source "$ZSHRC_ROOT/lib/colors.zsh"

function clean-downloads() {
	print "${_grey}Cleaning Downloads...${_0}"

	setopt local_options no_nomatch

	local -a files_to_clean=(
		$HOME/Downloads/**/*.mp4.mp4(N)
		$HOME/dwhelper/**/*.mp4.mp4(N)
	)

	if (( ${#files_to_clean} == 0 )); then
		print "  nothing to do"
		return 0
	fi

	local file
	for file in "${files_to_clean[@]}"; do
		clean-exec mv "$file" "${file%.mp4.mp4}.mp4"
	done
}
