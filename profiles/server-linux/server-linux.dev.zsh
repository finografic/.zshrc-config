# REPOS
REPOS="${SERVER_REPOS:-$HOME/repos}"

alias repos="cd $REPOS && l"

# ============================================================================ #
# PERMISSIONS
# ============================================================================ #

# chown-to [-R] [--dry-run] <user>[:<group>] <path>
# Replaces a trio of near-identical chown wrappers, one of which hardcoded
# an org-specific group name.
function chown-to() {
  local recursive=false dry_run=false owner="" path="" arg

  for arg in "$@"; do
    case "$arg" in
    -R) recursive=true ;;
    --dry-run) dry_run=true ;;
    *)
      if [[ -z "$owner" ]]; then
        owner="$arg"
      else
        path="$arg"
      fi
      ;;
    esac
  done

  if [[ -z "$owner" || -z "$path" ]]; then
    echo "usage: chown-to [-R] [--dry-run] <user>[:<group>] <path>" >&2
    return 1
  fi

  local -a cmd=(sudo chown)
  [[ "$recursive" == true ]] && cmd+=(-R)
  cmd+=("$owner" "$path")

  if [[ "$dry_run" == true ]]; then
    echo "would run: ${cmd[*]}"
  else
    "${cmd[@]}"
  fi
}
