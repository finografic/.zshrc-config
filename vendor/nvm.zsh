# NVM Configuration
export NVM_DIR="$HOME/.nvm"
export NVM_COMPLETION=true # Enable completion

# Node version preferences by environment
NODE_VERSION_PREFERRED="24.16.0" # Default

# NOTE: HOME
case "$OS_NAME" in
	"Linux" | "macOS") NODE_VERSION_PREFERRED="24.16.0" ;;
	"Android") NODE_VERSION_PREFERRED="20.18.2" ;;
esac

# NOTE: OFFICE + SERVER
case "$ZENV" in
	"office-macos") NODE_VERSION_PREFERRED="22.14.0" ;;
	"server-linux") NODE_VERSION_PREFERRED="22.17.1" ;;
esac

# ============================================================================ #
# NOTE: LAZY NVM
#
# `source $NVM_DIR/nvm.sh` costs ~449ms, plus ~58ms for its bash_completion.
# That was the largest single item left on the startup path, and almost every
# shell paid it to end up in the state it could have had for free: the default
# Node version active.
#
# Fast path: read $NVM_DIR/alias/default (a one-line file), put that version's
# bin directory on PATH directly, and DON'T source nvm.sh at all. node, npm,
# npx, pnpm, yarn and corepack all live in that directory, so they work
# immediately. nvm.sh is then sourced on demand — the first time `nvm` is
# called, or the first time load-nvmrc finds an .nvmrc wanting a DIFFERENT
# version than the one already active.
#
# Escape hatch: ZSHRC_NVM_LAZY=0 restores the old eager behaviour verbatim.
#
# The fast path is only taken when the default alias is a plain X.Y.Z that is
# actually installed. Anything else (an alias like `lts/*`, a missing version)
# falls through to the eager path, so an unusual setup degrades to the old
# behaviour instead of silently getting no Node.
# ============================================================================ #

typeset -g _ZSHRC_NVM_LOADED=0

# Sources the real nvm.sh, once. Everything lazy funnels through here.
function zshrc-nvm-load-real() {
	(( _ZSHRC_NVM_LOADED )) && return 0
	typeset -g _ZSHRC_NVM_LOADED=1

	# Remove the stubs so nvm.sh's own definitions win.
	unfunction nvm nvm_find_nvmrc 2> /dev/null

	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

# Pure-zsh .nvmrc search. Walks up from $PWD exactly as nvm does, but without
# needing nvm loaded. Prints the path, or nothing.
function zshrc-nvm-find-nvmrc() {
	local dir="${1:-$PWD}"
	while [[ -n "$dir" && "$dir" != / ]]; do
		[[ -f "$dir/.nvmrc" ]] && { print -r -- "$dir/.nvmrc"; return 0; }
		dir="${dir:h}"
	done
	[[ -f /.nvmrc ]] && { print -r -- /.nvmrc; return 0; }
	return 1
}

function _zshrc-nvm-use-lazy-path() {
	[[ "${ZSHRC_NVM_LAZY:-1}" == 0 ]] && return 1
	[[ -r "$NVM_DIR/alias/default" ]] || return 1

	local default
	default="$(< "$NVM_DIR/alias/default")"
	default="${default//[[:space:]]/}"

	# Only a plain X.Y.Z we can resolve without nvm.
	[[ "$default" == <->.<->.<-> ]] || return 1
	[[ -d "$NVM_DIR/versions/node/v${default}/bin" ]] || return 1

	export NVM_BIN="$NVM_DIR/versions/node/v${default}/bin"
	export NVM_INC="$NVM_DIR/versions/node/v${default}/include/node"
	# `typeset -U path` (bootstrap/index.zsh) keeps this from accumulating.
	path=("$NVM_BIN" $path)
	return 0
}

if _zshrc-nvm-use-lazy-path; then
	# Stubs: the first real use swaps in the genuine implementations.
	function nvm() {
		zshrc-nvm-load-real
		nvm "$@"
	}
	function nvm_find_nvmrc() {
		zshrc-nvm-find-nvmrc "$@"
	}
else
	# Eager fallback — the original behaviour, unchanged.
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
	typeset -g _ZSHRC_NVM_LOADED=1

	# Set default Node version when no .nvmrc is present.
	#
	# PERF: `nvm use` (~478ms) and `nvm alias default` (~260ms) are expensive and
	# are usually no-ops — sourcing nvm.sh already activates the default version.
	# Check the cheap way first and only shell out when something differs.
	if command -v nvm > /dev/null 2>&1; then
		if [[ -z "$(nvm_find_nvmrc 2> /dev/null)" ]]; then
			if [[ "$NVM_BIN" != *"/versions/node/v${NODE_VERSION_PREFERRED}/bin"* ]]; then
				nvm use $NODE_VERSION_PREFERRED > /dev/null 2>&1
			fi
			if [[ "$(< "$NVM_DIR/alias/default" 2> /dev/null)" != "$NODE_VERSION_PREFERRED" ]]; then
				nvm alias default $NODE_VERSION_PREFERRED > /dev/null 2>&1
			fi
		fi
	fi
fi

unfunction _zshrc-nvm-use-lazy-path
