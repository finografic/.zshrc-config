# TODO: populate per employer. This profile ships intentionally neutral —
# it demonstrates the pattern, not a real workplace setup.

# Example: a repo shortcut for wherever your work checkouts live.
alias work="cd \"${WORK_REPOS:-$HOME/repos-work}\" && l"

# ============================================================================ #
# NOTE: GENERATED ALIASES - (SEE .env FOR CONFIGURATION)
# ============================================================================ #

# Optional `.env` source of truth.
# Use full paths as values so local folder layout stays out of tracked files:
#   typeset -gA OFFICE_REPO_ALIASES=(
#     [proj]="$HOME/repos-work/project"
#   )

function _register-office-repo-aliases() {
  (( ${+OFFICE_REPO_ALIASES} )) || return 0

  local alias_name target_path
  for alias_name target_path in ${(kv)OFFICE_REPO_ALIASES}; do
    eval "alias ${alias_name}='cd ${target_path:q} && l'"
  done
}

_register-office-repo-aliases
unset -f _register-office-repo-aliases
