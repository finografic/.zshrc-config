# ============================================================================ #
# CLEANING UTILITIES - Loads all clean modules from lib/clean/
# ============================================================================ #

source "$ZSHRC_ROOT/lib/clean/clean.downloads.zsh"
source "$ZSHRC_ROOT/lib/clean/clean.browsers.zsh"
source "$ZSHRC_ROOT/lib/clean/clean.node-caches.zsh"

# ============================================================================ #
# MAINTENANCE OPERATIONS
# ============================================================================ #

source "$ZSHRC_ROOT/lib/clean/utils/clean.node_modules.utils.zsh" # functions

# Clear VSCode / VSCode Insiders / Cursor IDE caches
# Delegates to lib/clean/utils/clean.ides.utils.zsh (supports all 3 IDEs, Cursor-safe)

function vsclean() {
  zsh "${ZSHRC_ROOT}/lib/clean/utils/clean.ides.utils.zsh"
}
