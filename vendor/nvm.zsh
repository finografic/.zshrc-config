# NVM Configuration
export NVM_DIR="$HOME/.nvm"
export NVM_LAZY_LOAD=true  # Faster shell startup
export NVM_COMPLETION=true # Enable completion

# Node version preferences by environment
# NODE_VERSION_PREFERRED="22.15.0" # Default
# NODE_VERSION_PREFERRED="22.17.1" # Default
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

# Load NVM if it exists
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Set default Node version when no .nvmrc is present
# (.nvmrc switching: lib/node/nvm-autoload.zsh via lib/node.zsh barrel)
#
# PERF: `nvm use` (~478ms) and `nvm alias default` (~260ms) are expensive, and
# in the steady state both are no-ops — sourcing nvm.sh above already activates
# the default version, so NVM_BIN and the alias file are usually correct before
# we get here. Together they were ~738ms per shell doing nothing.
#
# This branch only runs when there is NO .nvmrc, i.e. the ordinary case of
# opening a terminal in $HOME, which made it the common path, not the rare one:
# sourcing this file measured 1,217ms from $HOME versus 505ms inside a repo.
#
# So: check the cheap way first (a parameter test and one small file read, both
# microseconds) and only shell out to nvm when something actually differs — a
# fresh machine, a newly installed Node, or a changed NODE_VERSION_PREFERRED.
if command -v nvm > /dev/null 2>&1; then
	if [[ -z "$(nvm_find_nvmrc 2> /dev/null)" ]]; then
		# Is the wanted version already the active one? nvm.sh sets NVM_BIN.
		if [[ "$NVM_BIN" != *"/versions/node/v${NODE_VERSION_PREFERRED}/bin"* ]]; then
			nvm use $NODE_VERSION_PREFERRED > /dev/null 2>&1
		fi

		# Is it already the default? The alias is a one-line plain file.
		if [[ "$(< "$NVM_DIR/alias/default" 2> /dev/null)" != "$NODE_VERSION_PREFERRED" ]]; then
			nvm alias default $NODE_VERSION_PREFERRED > /dev/null 2>&1
		fi
	fi
fi

