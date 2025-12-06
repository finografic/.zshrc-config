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
fi
