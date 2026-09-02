source "$ZSHRC_ROOT/lib/colors.zsh"
source "$ZSHRC_ROOT/lib/llms.zsh"

# -----------------------------------------------------------------------------
# _docs — sync a shared docs/notes repo that lives on a single branch.
#
#   _docs                       sync only: pull --rebase, report what landed
#   _docs -c                    sync + commit all + push (default message)
#   _docs -c "some message"     sync + commit all + push (custom message)
#   _docs --commit "message"    same as -c
#   _docs -h | --help           usage
# -----------------------------------------------------------------------------

_docs() {
  local commit=0 msg=""

  while (( $# )); do
    case "$1" in
      -c|--commit)
        commit=1
        shift
        ;;
      -h|--help)
        print "usage: _docs [-c|--commit [message]]"
        return 0
        ;;
      --)
        shift
        msg="$*"
        break
        ;;
      -*)
        print -u2 "_docs: unknown flag: $1"
        return 2
        ;;
      *)
        msg="$*"
        break
        ;;
    esac
  done

  if (( ! commit )) && [[ -n $msg ]]; then
    print -u2 "_docs: message given without -c/--commit"
    return 2
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
