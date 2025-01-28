# COMMON COMMANDS / ALIASES
# non-specific to any filesystem

alias pn="pnpm"

# NEW (2024-05)
# TODO: WHAT HAPPENED TO `batcat` ??
# alias bat="batcat"

# NEW (2025-02) - PNPM ALIAS THAT READS ${GITHUB_TOKEN} FROM .ENV
pnr() {
  # Load GITHUB_TOKEN from .env if it exists
  if [ -f .env ]; then
    export GITHUB_TOKEN=$(grep GITHUB_TOKEN .env | cut -d '=' -f2)
  fi

  # Run pnpm with all arguments passed to the function
  GITHUB_TOKEN=$GITHUB_TOKEN pnpm "$@"
}
