source "$ZSHRC_ROOT/lib/colors.zsh"
source "$ZSHRC_ROOT/lib/llms.zsh"

# -----------------------------------------------------------------------------
# _docs — work with the shared docs/notes repo (single branch, no merge commits).
#
#   _docs                       sync only: pull --rebase, report what landed
#   _docs -c                    sync + commit all + push (default message)
#   _docs -c "some message"     sync + commit all + push (custom message)
#   _docs -u                    open latest standup note in $IDE (repo + file)
#   _docs -h | --help           usage
#
# Requires (from .env):
#   REPO_DOCS            repo root
#   ZDIR_DOCS_STANDUP    directory holding the dated standup notes
# -----------------------------------------------------------------------------
_docs() {
  local commit=0 update=0 msg=""

  while (( $# )); do
    case "$1" in
      -c|--commit) commit=1; shift ;;
      -u|--update) update=1; shift ;;
      -h|--help)
        print "usage: _docs [-c|--commit [message]] [-u|--update]"
        return 0
        ;;
      --) shift; msg="$*"; break ;;
      -*) print -u2 "_docs: unknown flag: $1"; return 2 ;;
      *)  msg="$*"; break ;;
    esac
  done

  if (( ! commit )) && [[ -n $msg ]]; then
    print -u2 "_docs: message given without -c/--commit"
    return 2
  fi

  # --- open latest standup note -------------------------------------------
  if (( update )); then
    local root="${REPO_DOCS:?_docs: REPO_DOCS not set — check .env}"
    local dir="${ZDIR_DOCS_STANDUP:?_docs: ZDIR_DOCS_STANDUP not set — check .env}"

    [[ -d $dir ]] || { print -u2 "_docs: no such directory: $dir"; return 1 }

    # regular files, sorted by name; [-1] takes the last (newest dated file).
    # swap for *(.om[1]) to pick most-recently-modified instead.
    local -a notes
    notes=( "$dir"/*(.N) )

    (( $#notes )) || { print -u2 "_docs: no notes found in $dir"; return 1 }

    local latest=${notes[-1]}
    print "_docs: opening ${latest:t}"
    ${IDE:-code} "$root" "$latest"
    return 0
  fi

  git rev-parse --show-toplevel >/dev/null 2>&1 || {
    print -u2 "_docs: not a git repo"
    return 1
  }

  # --- commit path: stage and commit before touching the remote ------------
  if (( commit )); then
    if [[ -z $(git status --porcelain) ]]; then
      print "_docs: nothing to commit"
      return 0
    fi

    : ${msg:="add daily update"}

    git add -A || return 1
    git commit -m "$msg" || return 1
  fi

  # --- shared path: reconcile with remote ----------------------------------
  local before
  before=$(git rev-parse HEAD)

  git pull --rebase --autostash || {
    if (( commit )); then
      print -u2 "_docs: rebase stopped — commit is safe locally, resolve then push"
    else
      print -u2 "_docs: pull failed — resolve, then 'git rebase --continue'"
    fi
    return 1
  }

  if [[ $before == $(git rev-parse HEAD) ]]; then
    (( commit )) || print "_docs: already up to date"
  else
    print "_docs: pulled —"
    git log --oneline --no-decorate "${before}..HEAD"
  fi

  # --- commit path only: publish -------------------------------------------
  if (( commit )); then
    git push || return 1
    print "_docs: pushed — $msg"
  fi
}
