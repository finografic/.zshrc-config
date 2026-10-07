source "$ZSHRC_ROOT/lib/colors.zsh"
source "$ZSHRC_ROOT/lib/llms.zsh"

# ------------------------------------------------------------------------------
# _sprint — sprint tooling for the shared docs repo.
#
#   _sprint -n | --new       open the "create new sprint" workflow (3 steps)
#   _sprint -c | --cleanup   create today's weekly-cleanup note from the latest one, open it
#   _sprint -h | --help      usage
#
# Requires (from .env):
#   REPO_DOCS             docs repo root
#   ZDIR_DOCS_SPRINT      absolute path to Tools/DevOps in the docs repo
# ------------------------------------------------------------------------------

function _sprint() {
  local new=0 cleanup=0

  # --- parse flags ---------------------------------------------------------
  while (($#)); do
    case "$1" in
    -n | --new)
      new=1
      shift
      ;;
    -c | --cleanup)
      cleanup=1
      shift
      ;;
    -h | --help)
      print "usage: _sprint [-n|--new] [-c|--cleanup]"
      return 0
      ;;
    -*)
      print -u2 "_sprint: unknown flag: $1"
      return 2
      ;;
    *)
      print -u2 "_sprint: unexpected argument: $1"
      return 2
      ;;
    esac
  done

  if ((! new && ! cleanup)); then
    print "usage: _sprint [-n|--new] [-c|--cleanup]"
    return 0
  fi

  # --- --new: create a new sprint ------------------------------------------
  if ((new)); then
    local root="${REPO_DOCS:?_sprint: REPO_DOCS not set — check .env}"
    local dir="${ZDIR_DOCS_SPRINT:?_sprint: ZDIR_DOCS_SPRINT not set — check .env}"
    local look_forward_md="$root/process/ceremonies/look-forward.md"
    local guide_md="$dir/create-new-sprint.md"
    local tickets_csv="$dir/weekly_ticket_import.csv"

    # 1. Open the look-forward ceremony (markdown) in $IDE_DOCS
    [[ -f $look_forward_md ]] || {
      print -u2 "_sprint: file not found: $look_forward_md"
      return 1
    }
    print "_sprint: [1/3] opening ${look_forward_md:t} in ${IDE_DOCS:-code}"
    ${IDE_DOCS:-code} "$look_forward_md" || return 1

    # 2. Open the sprint guide (markdown) in Typora
    [[ -f $guide_md ]] || {
      print -u2 "_sprint: file not found: $guide_md"
      return 1
    }
    print "_sprint: [2/3] opening ${guide_md:t} in Typora"
    open -a "Typora" "$guide_md" || return 1

    # 3. Open the weekly ticket import CSV in its default app
    [[ -f $tickets_csv ]] || {
      print -u2 "_sprint: file not found: $tickets_csv"
      return 1
    }
    print "_sprint: [3/3] opening ${tickets_csv:t} with default app"
    open "$tickets_csv" || return 1
  fi

  # --- --cleanup: create today's weekly-cleanup note ------------------------
  if ((cleanup)); then
    local root="${REPO_DOCS:?_sprint: REPO_DOCS not set — check .env}"
    local cleanup_dir="$root/process/weekly-cleanup"
    local today
    today=$(date +%F)
    local target="$cleanup_dir/weekly-cleanup_${today}.md"

    # 1. Find the latest previous note (newest dated name, excluding today's)
    local -a notes
    notes=("$cleanup_dir"/weekly-cleanup_*.md(.N))
    notes=(${notes:#"$target"})

    (($#notes)) || {
      print -u2 "_sprint: no previous notes found in $cleanup_dir"
      return 1
    }
    local latest=${notes[-1]}

    if [[ -e $target ]]; then
      print "_sprint: ${target:t} already exists — opening it"
    else
      print "_sprint: creating ${target:t} from ${latest:t}"

      # 2. Copy the latest note to today's filename, replacing every YYYY-MM-DD with today
      cp "$latest" "$target" || return 1
      sed -i '' -E "s/[0-9]{4}-[0-9]{2}-[0-9]{2}/$today/g" "$target" || return 1

      # 3. Reset the start/end times to 10:00
      sed -i '' -E 's/^([[:space:]]*[0-9]+\. (start|end): ([0-9]{4}-[0-9]{2}-[0-9]{2} )?)[0-9]{1,2}:[0-9]{2}/\110:00/' "$target" || return 1

      # 4. Empty the shortlist section (keep the heading and one blank line)
      awk '
        /^## shortlist[[:space:]]*$/ { print; print ""; skip = 1; next }
        skip && /^## /               { skip = 0 }
        skip                         { next }
                                     { print }
      ' "$target" >"$target.tmp" && mv "$target.tmp" "$target" || return 1
    fi

    # 5. Open today's note in $IDE_DOCS
    print "_sprint: opening ${target:t} in ${IDE_DOCS:-code}"
    ${IDE_DOCS:-code} "$target" || return 1
  fi
}
