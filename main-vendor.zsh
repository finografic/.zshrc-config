# PNPM Configuration
if command -v pnpm >/dev/null || [ -d "$HOME/Library/pnpm" ]; then
  case "$OS_NAME" in
  "macOS")
    export PNPM_HOME="$HOME/Library/pnpm"
    ;;
  "Linux")
    export PNPM_HOME="$HOME/.local/share/pnpm"
    ;;
  *)
    # Default location for other systems
    export PNPM_HOME="$HOME/.pnpm"
    ;;
  esac

  # Add to PATH if not already present
  case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
  esac
fi
