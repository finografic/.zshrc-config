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
	"apnaes") NODE_VERSION_PREFERRED="22.17.1" ;;
esac

# Load NVM if it exists
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Set default Node version when no .nvmrc is present (load-nvmrc handles .nvmrc dirs)
if command -v nvm > /dev/null 2>&1; then
	if [[ -z "$(nvm_find_nvmrc 2> /dev/null)" ]]; then
		nvm use $NODE_VERSION_PREFERRED > /dev/null 2>&1
		nvm alias default $NODE_VERSION_PREFERRED > /dev/null 2>&1
	fi
fi

# Switch on cd (and once at startup); keeps NODE_CURRENT_VERSION / NPM_GLOBALS in sync
source "$ZSHRC_ROOT/lib/nvm-autoload.zsh"
