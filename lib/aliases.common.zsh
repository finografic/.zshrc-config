# COMMON COMMANDS / ALIASES

# non-specific to any filesystem

# ========================================================================= #
# UNIVERSAL ALIASES
alias dls="cd $HOME/Downloads && l"
alias www="cd /var/www && l"

# ========================================================================= #
# PNPM

# NOTE: NEW !! (2025-03)
# Enhanced PNPM function with authentication and environment handling
pn() {
  local root_dir
  local current_dir="$PWD"

  # Find the root directory (where package.json exists)
  while [[ "$PWD" != "/" ]]; do
    if [[ -f "package.json" ]]; then
      root_dir="$PWD"
      break
    fi
    cd ..
  done
  cd "$current_dir"

  # If no package.json found in parent directories
  if [[ -z "$root_dir" ]]; then
    root_dir="$current_dir"
  fi

  # Check for GitHub authentication needs
  local needs_github=false
  if [[ -f "$root_dir/.npmrc" ]]; then
    if grep -q "@finografic:registry=https://npm.pkg.github.com" "$root_dir/.npmrc"; then
      needs_github=true
    fi
  fi

  # Handle GitHub authentication if needed
  if [[ "$needs_github" == true ]]; then
    # Try to load GITHUB_TOKEN from .env
    if [[ -f "$root_dir/.env" ]]; then
      export GITHUB_TOKEN=$(grep GITHUB_TOKEN "$root_dir/.env" | cut -d '=' -f2)
    fi

    # Check if we have authentication (either via .netrc or GITHUB_TOKEN)
    if [[ ! -f "$HOME/.netrc" ]] && [[ -z "$GITHUB_TOKEN" ]]; then
      echo "⚠️  Warning: No GitHub authentication found"
      echo "Please either:"
      echo "  1. Run 'npm login --scope=@finografic --registry=https://npm.pkg.github.com'"
      echo "  2. Set up .netrc file"
      echo "  3. Provide GITHUB_TOKEN in .env file"
      return 1
    fi
  fi

  # Execute pnpm with all arguments
  if [[ "$needs_github" == true ]] && [[ -n "$GITHUB_TOKEN" ]]; then
    GITHUB_TOKEN=$GITHUB_TOKEN pnpm "$@"
  else
    pnpm "$@"
  fi
}

# wrapper for scripts calling `pnpm``
# pnpm() {
#   pn "$@"
# }

pnr() {
  pn remove "$@"
}

# ========================================================================= #
# NEW (2026-01)
# NOTE: simple alias for /opt/homebrew/bin/tree that auto-adds the --gitignore flag, displaying simpler trees

# tree() {
#   tree --gitignore "$@"
# }

# ========================================================================= #
# NEW (2024-05)
# TODO: WHAT HAPPENED TO `batcat` ??
# alias bat="batcat"
