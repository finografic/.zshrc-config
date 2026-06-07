# ============================================================================ #
# MAINTENANCE OPERATIONS
# ============================================================================ #

# Clear VSCode / VSCode Insiders / Cursor IDE caches
# Delegates to scripts/vscode-clean.zsh (supports all 3 IDEs, Cursor-safe)

function vsclean() {
  zsh "${ZSHRC_ROOT:-$HOME/.zshrc-config}/scripts/vscode-clean.zsh"
}
