#!/bin/zsh
# ============================================================================ #
# NOTE: VENDOR PNPM - Package manager PATH setup
# ============================================================================ #

if command -v pnpm >/dev/null || [ -d "$HOME/Library/pnpm" ]; then
  case "$OS_NAME" in
  "macOS")
    export PNPM_HOME="$HOME/Library/pnpm"
    ;;
  "Linux")
    export PNPM_HOME="$HOME/.local/share/pnpm"
    ;;
  *)
    export PNPM_HOME="$HOME/.pnpm"
    ;;
  esac

  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac
fi
