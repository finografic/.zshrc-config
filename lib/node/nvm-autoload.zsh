# ============================================================================ #
# NOTE: NVM .nvmrc AUTOLOAD - ref: https://github.com/nvm-sh/nvm?tab=readme-ov-file#zsh
#
# Requires vendor/nvm.zsh to have run first, which provides `nvm_find_nvmrc`
# either from nvm.sh itself (eager path) or as a pure-zsh stub (lazy path).
# ============================================================================ #

if ! command -v nvm_find_nvmrc > /dev/null 2>&1; then
	return 0
fi

autoload -U add-zsh-hook

function _sync-nvm-path-vars() {
	if [[ "$ZENV" == 'server-linux' ]]; then
		return 0
	fi

	# PERF: derive the version from $NVM_BIN rather than spawning `node
	# --version` on every directory change. NVM_BIN always ends in
	# .../versions/node/vX.Y.Z/bin, and both the eager and lazy paths in
	# vendor/nvm.zsh set it.
	if [[ -n "$NVM_BIN" ]]; then
		export NODE_CURRENT_VERSION="${${NVM_BIN%/bin}##*/}"
		export NPM_GLOBALS="$NVM_BIN"
	elif command -v node > /dev/null 2>&1; then
		export NODE_CURRENT_VERSION="$(node --version)"
		export NPM_GLOBALS="$NVM_DIR/versions/node/$NODE_CURRENT_VERSION/bin"
	fi
}

# Returns the vX.Y.Z currently on PATH, without calling nvm.
function _nvm-active-version() {
	print -r -- "${${NVM_BIN%/bin}##*/}"
}

function load-nvmrc() {
	local nvmrc_path
	nvmrc_path="$(nvm_find_nvmrc)"

	if [[ -n "$nvmrc_path" ]]; then
		local wanted
		wanted="$(< "$nvmrc_path")"
		wanted="${wanted//[[:space:]]/}"
		# .nvmrc may or may not carry the leading v.
		[[ "$wanted" == v* ]] || wanted="v${wanted}"

		# FAST PATH: the wanted version is already active, so there is nothing
		# to do and — crucially on the lazy path — no reason to pay ~449ms
		# sourcing nvm.sh just to be told so. This is the common case: an
		# .nvmrc that matches the default version.
		if [[ "$wanted" == "$(_nvm-active-version)" ]]; then
			_sync-nvm-path-vars
			return 0
		fi

		# A real switch is needed, so the genuine nvm has to come out.
		(( $+functions[zshrc-nvm-load-real] )) && zshrc-nvm-load-real

		local nvmrc_node_version
		nvmrc_node_version="$(nvm version "$(cat "${nvmrc_path}")")"

		if [[ "$nvmrc_node_version" == "N/A" ]]; then
			nvm install
		elif [[ "$nvmrc_node_version" != "$(nvm version)" ]]; then
			nvm use
		fi
	elif [[ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ]]; then
		# Left a directory that had an .nvmrc. Only revert if we are not
		# already sitting on the default version.
		local default_version
		default_version="$(< "$NVM_DIR/alias/default" 2> /dev/null)"
		[[ "$default_version" == v* ]] || default_version="v${default_version}"

		if [[ "$default_version" != "$(_nvm-active-version)" ]]; then
			(( $+functions[zshrc-nvm-load-real] )) && zshrc-nvm-load-real
			echo "Reverting to nvm default version"
			nvm use default
		fi
	fi

	_sync-nvm-path-vars
}

# Activates the auto-switch: registers the chpwd hook and resolves the version
# for the starting directory. Sourcing this file must stay inert, so the caller
# (main.zsh, or a profile) decides when to turn the feature on.
function nvm-autoload-init() {
	add-zsh-hook chpwd load-nvmrc
	load-nvmrc
}
