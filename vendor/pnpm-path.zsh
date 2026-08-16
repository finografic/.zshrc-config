# ============================================================================ #
# NOTE: VENDOR PNPM PATH - Set PNPM_HOME and prepend to PATH only
# UX helpers (pn / pnr / npmls) live in lib/node/pnpm.zsh
# ============================================================================ #

if command -v pnpm >/dev/null || [[ -d "$HOME/Library/pnpm" ]]; then
	case "$OS_NAME" in
	macOS) export PNPM_HOME="$HOME/Library/pnpm" ;;
	Linux) export PNPM_HOME="$HOME/.local/share/pnpm" ;;
	*) export PNPM_HOME="$HOME/.pnpm" ;;
	esac

	# $PNPM_HOME/bin is where pnpm's self-managed launcher (`pnpm self-update`)
	# lives as of pnpm 11 — global package shims (eslint, acorn, ...) stay
	# directly in $PNPM_HOME. Both must be on PATH, /bin first, and both must
	# win the front of PATH — not just be "present somewhere".
	#
	# A plain "already in PATH, skip" guard is NOT enough here: .zshrc's own
	# early PATH lines already put $PNPM_HOME/bin on PATH before this file
	# ever runs, so that guard always sees it as present and never moves it —
	# it just sits wherever .zshrc left it while everything sourced after
	# (nvm.zsh's own PATH prepend, `brew shellenv`, ...) walks straight past
	# it. `${(@)path:#pattern}` strips any existing occurrence first so the
	# prepend below is a genuine move-to-front, not a no-op.
	path=("${(@)path:#$PNPM_HOME}")
	path=("${(@)path:#$PNPM_HOME/bin}")
	path=("$PNPM_HOME/bin" "$PNPM_HOME" $path)
fi
