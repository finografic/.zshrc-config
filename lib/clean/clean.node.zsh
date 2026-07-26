# ============================================================================ #
# NOTE: CLEAN NODE - node_modules removal + npm/pnpm cache prune
# Usage:
#   clean-node-modules [--dry-run]
#   clean-node-modules-report [--dry-run]
#   clean-caches-npm
#   clean-caches-pnpm
# ============================================================================ #

# ============================================================================ #
# Recursively remove top-level `node_modules` dirs (via fd --prune).
# Options: --dry-run  (list targets and sizes only; no rm)
# ============================================================================ #

function clean-node-modules() {
	local dry_run=0

	while [[ $# -gt 0 ]]; do
		case "$1" in
		--dry-run)
			dry_run=1
			shift
			;;
		*) break ;;
		esac
	done

	echo "\n${_c}🔍 Finding node_modules directories...${_0}"
	[[ $dry_run -eq 1 ]] && echo "${_w}(dry-run — nothing will be deleted)${_0}\n"

	# --prune: don't descend into node_modules dirs, so nested ones are excluded
	dirs=($(fd -H -I --prune -t d "^node_modules$"))

	failed_dirs=()

	if (( ${#dirs[@]} == 0 )); then
		echo "${_w}No node_modules directories found.${_0}\n"
		return 0
	fi

	echo "${_y}Found ${#dirs[@]} node_modules directories.${_0}\n"

	for dir in "${dirs[@]}"; do
		if [[ -d "$dir" ]]; then
			size=$(du -sh "$dir" 2>/dev/null | cut -f1)

			if [[ -n "$size" ]]; then
				if [[ $dry_run -eq 1 ]]; then
					echo "\n${_grey}🔎 Would remove $dir (size: $size)${_0}\n"
					continue
				fi

				echo "\n${_grey}🗑️  Removing $dir (size: $size)${_0}\n"

				if ! rm -rf "$dir" 2>/dev/null; then
					echo "${_y}⚠️  Permission denied, trying with sudo...${_0}"
					sudo rm -rf "$dir" || {
						echo "${_r}❌ Failed to remove: $dir${_0}"
						failed_dirs+=("$dir")
					}
				fi
			fi
		fi
	done

	if [[ $dry_run -eq 1 ]]; then
		echo "\n${_g}✨ Dry run finished — no directories were removed.${_0}\n"
	else
		echo "\n${_g}✨ Cleanup complete!${_0}\n"
	fi

	if (( ${#failed_dirs[@]} > 0 )); then
		echo "\n${_y}Warning: The following directories had permission issues:${_0}"
		for failed in "${failed_dirs[@]}"; do
			echo "${_r}  - $failed${_0}"
		done
		echo "${_y}You might need to remove these manually with sudo${_0}"
	fi
}

# Wrapper: measure disk usage before and after running the cleaner
function clean-node-modules-report() {
	local dry_run=0 _
	for _ in "$@"; do [[ "$_" == "--dry-run" ]] && dry_run=1; done

	SIZE_A_KB=$(du -sk . 2>/dev/null | awk '{print $1+0}')
	SIZE_A=$(awk "BEGIN{printf \"%.1f\", (${SIZE_A_KB:-0})/1024}")

	clean-node-modules "$@"

	SIZE_B_KB=$(du -sk . 2>/dev/null | awk '{print $1+0}')
	SIZE_B=$(awk "BEGIN{printf \"%.1f\", (${SIZE_B_KB:-0})/1024}")

	SAVED=$(awk "BEGIN{printf \"%.1f\", (${SIZE_A} - ${SIZE_B})}")

	echo "${_grey}before clean: ${SIZE_A} MB${_0}"
	echo "${_grey}after clean: ${SIZE_B} MB${_0}"
	echo "${_g}space saved: ${SAVED} MB${_0}"
	[[ $dry_run -eq 1 ]] && echo "${_w}(dry run — disk usage should match above)${_0}"

	export SIZE_A SIZE_B SAVED
}

function clean-caches-npm() {
	print "${_grey}Cleaning node caches...${_0}"

	if ! command -v npm >/dev/null; then
		print "  npm not found — skipping"
		return 0
	fi

	clean-exec npm cache clean --force
}

function clean-caches-pnpm() {
	print "${_grey}Cleaning pnpm caches...${_0}"

	if ! command -v pnpm >/dev/null; then
		print "  pnpm not found — skipping"
		return 0
	fi

	clean-exec pnpm store prune
}
