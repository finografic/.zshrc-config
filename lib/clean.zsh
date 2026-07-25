# ============================================================================ #
# NOTE: CLEAN - Barrel for lib/clean/ modules (source-only; call functions to run)
# ============================================================================ #

source "$ZSHRC_ROOT/lib/colors.zsh"

# Modules (define functions only)
source "$ZSHRC_ROOT/lib/clean/clean.downloads.zsh"
source "$ZSHRC_ROOT/lib/clean/clean.browsers.zsh"
source "$ZSHRC_ROOT/lib/clean/clean.ides.zsh"
source "$ZSHRC_ROOT/lib/clean/clean.node.zsh"

# Aliases
alias vsclean="clean-ides"
alias _cnm="clean-node-modules-report"
alias _cnpm="clean-caches-npm"
alias _cpnpm="clean-caches-pnpm"

# ============================================================================ #
# NOTE: DRY-RUN HELPER - used by every destructive operation in lib/clean/
# ============================================================================ #

# Runs a command, or prints it when ZSHRC_CLEAN_DRY_RUN=true.
function clean-exec() {
	if [[ "${ZSHRC_CLEAN_DRY_RUN:-false}" == true ]]; then
		print "  ${_y}[dry-run]${_0} $*"
	else
		"$@"
	fi
}

# ============================================================================ #
# NOTE: ZCLEAN - the deliberate entry point
#
# These operations delete files. They used to run automatically on every full
# shell start, which is indefensible: a config should not mutate your machine
# just because you opened a terminal. You now ask for them.
# ============================================================================ #

function zclean() {
	local -a targets=()
	local dry_run=false arg

	for arg in "$@"; do
		case "$arg" in
		--all) targets=(downloads browsers node) ;;
		--downloads) targets+=(downloads) ;;
		--browsers) targets+=(browsers) ;;
		--node) targets+=(node) ;;
		--dry-run) dry_run=true ;;
		-h | --help)
			print "${_c}zclean${_0} [--all|--downloads|--browsers|--node] [--dry-run]"
			print "  --downloads  fix doubled .mp4.mp4 suffixes in ~/Downloads"
			print "  --browsers   prune Firefox site storage (keeps an allowlist)"
			print "  --node       clear npm + pnpm caches"
			print "  --all        all of the above"
			print "  --dry-run    show what would happen, change nothing"
			return 0
			;;
		*)
			print "zclean: unknown option '$arg' (try --help)" >&2
			return 1
			;;
		esac
	done

	if (( ${#targets} == 0 )); then
		print "zclean: nothing selected (try --help)" >&2
		return 1
	fi

	local target
	for target in ${(u)targets}; do
		case "$target" in
		downloads) ZSHRC_CLEAN_DRY_RUN=$dry_run clean-downloads ;;
		browsers) ZSHRC_CLEAN_DRY_RUN=$dry_run clean-browsers ;;
		node) ZSHRC_CLEAN_DRY_RUN=$dry_run clean-caches-npm ;;
		esac
	done
}
