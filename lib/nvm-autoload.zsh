# ============================================================================ #
# NOTE: NVM .nvmrc AUTOLOAD - ref: https://github.com/nvm-sh/nvm?tab=readme-ov-file#zsh
# Requires nvm.sh to be sourced first (nvm_find_nvmrc must exist).
# ============================================================================ #

if ! command -v nvm_find_nvmrc > /dev/null 2>&1; then
	return 0
fi

autoload -U add-zsh-hook

function _sync-nvm-path-vars() {
	if [[ "$ZENV" == 'apnaes' ]]; then
		return 0
	fi

	if command -v node > /dev/null 2>&1; then
		export NODE_CURRENT_VERSION="$(node --version)"
		export NPM_GLOBALS="$NVM_DIR/versions/node/$NODE_CURRENT_VERSION/bin"
	fi
}

function load-nvmrc() {
	local nvmrc_path
	nvmrc_path="$(nvm_find_nvmrc)"

	if [[ -n "$nvmrc_path" ]]; then
		local nvmrc_node_version
		nvmrc_node_version="$(nvm version "$(cat "${nvmrc_path}")")"

		if [[ "$nvmrc_node_version" == "N/A" ]]; then
			nvm install
		elif [[ "$nvmrc_node_version" != "$(nvm version)" ]]; then
			nvm use
		fi
	elif [[ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ]] && [[ "$(nvm version)" != "$(nvm version default)" ]]; then
		echo "Reverting to nvm default version"
		nvm use default
	fi

	_sync-nvm-path-vars
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc
