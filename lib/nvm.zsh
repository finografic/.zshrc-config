# NVM Configuration
export NVM_DIR="$HOME/.nvm"
export NVM_LAZY_LOAD=true  # Faster shell startup
export NVM_COMPLETION=true # Enable completion

# Node version preferences by environment
# NODE_VERSION_PREFERRED="22.15.0" # Default
# NODE_VERSION_PREFERRED="22.17.1" # Default
NODE_VERSION_PREFERRED="24.12.0" # Default

# NOTE: HOME
case "$OS_NAME" in
"Linux" | "macOS") NODE_VERSION_PREFERRED="24.12.1" ;;
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

# ============================================================================ #
# NOTE: NVM AUTOLOAD - ref: https://github.com/nvm-sh/nvm?tab=readme-ov-file#zsh

# place this after nvm initialization!
autoload -U add-zsh-hook

load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc
