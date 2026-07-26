source "$ZSHRC_ROOT/lib/colors.zsh"

# TODO: populate per employer with real repo paths / workflow helpers.
# What's here is generic enough to be useful as-is.

# TIME-SAVERS
function prep() {
  npm ci
  npm run format
  npm run lint
  npm run test:coverage
}

function lintx() {
  npm run format && npm run lint -- --fix
}

function confirm() {
  local response
  read -r "response?Are you sure? [y/N] "
  response="${response:l}" # tolower
  [[ $response == (y|yes) ]]
}

function commit() {
  if [[ -n "$1" ]]; then
    git add .
    git commit -m "$1" --no-verify
  else
    echo "\n${_y}⚠️   NO COMMIT MESSAGE SUPPLIED\n"
  fi
}

# ============================================================================ #

function bots() {
  if [[ "$1" == "--json" ]]; then
    gh pr list --label dependencies --json number,title,url
  else
    gh pr list --label dependencies
  fi
}

# USAGE: gh pr list [flags] — see `gh pr list --help` for the full flag list.
