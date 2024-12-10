# NVM Configuration
export NVM_DIR="$HOME/.nvm"
export NVM_LAZY_LOAD=true  # Faster shell startup
export NVM_COMPLETION=true # Enable completion

# Node version preferences by environment
NODE_VERSION_PREFERRED="16" # Default
case "$OS_NAME" in
"Linux" | "macOS") NODE_VERSION_PREFERRED="16" ;;
"Android") NODE_VERSION_PREFERRED="14" ;;
esac

# Override for specific environments
case "$ZENV" in
"office-macos") NODE_VERSION_PREFERRED="20.11.0" ;;
"apnaes") NODE_VERSION_PREFERRED="20.14.0" ;;
esac

# Load NVM if it exists
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Set default Node version (only if nvm is available)
if command -v nvm >/dev/null 2>&1; then
  nvm use $NODE_VERSION_PREFERRED >/dev/null 2>&1
  nvm alias default $NODE_VERSION_PREFERRED >/dev/null 2>&1
fi

# Export globals path (excluding apnaes environment)
if [ "$ZENV" != 'apnaes' ]; then
  if command -v node >/dev/null 2>&1; then
    export NODE_CURRENT_VERSION=$(node --version)
    export NPM_GLOBALS=$NVM_DIR/versions/node/$NODE_CURRENT_VERSION/bin
  fi
fi
