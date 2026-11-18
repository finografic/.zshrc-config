source "$ZSHRC_ROOT/lib/colors.zsh"
source "$ZSHRC_ROOT/lib/llms.zsh"

# -----------------------------------------------------------------------------
# _docs — work with the shared docs/notes repo (single branch, no merge commits).
#
#   _docs                       sync only: pull --rebase, report what landed
#   _docs -c                    commit all + sync + push, then fix + commit locally
#   _docs -c "some message"     same flow with a custom initial commit message
#   _docs -f | --fix            pnpm fix:all + commit all locally (no sync/push)
#   _docs -u | --update         sync, then open latest standup note in $IDE_DOCS (repo + file)
#   _docs -p | --pull           stash changes, pull, pop stash, refocus $IDE_DOCS
#   _docs -h | --help           usage
#
# Requires (from .env):
#   REPO_DOCS            repo root
#   ZDIR_DOCS_STANDUP    directory holding the dated standup notes
# -----------------------------------------------------------------------------
function _docs() {
  local commit=0 update=0 pull=0 fix=0 msg=""

  while (($#)); do
    case "$1" in
    -c | --commit)
      commit=1
      shift
      ;;
    -f | --fix)
      fix=1
      shift
      ;;
    -u | --update)
      update=1
      shift
      ;;
    -p | --pull)
      pull=1
      shift
      ;;
    -h | --help)
      print "usage: _docs [-c|--commit [message]] [-f|--fix] [-u|--update] [-p|--pull]"
      print "  -c: commit, sync and push, then fix and commit locally"
      print "  -f: run pnpm fix:all and commit locally (no sync/push)"
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

  if ((! commit)) && [[ -n $msg ]]; then
    print -u2 "_docs: message given without -c/--commit"
    return 2
  fi

  if ((pull && (commit || update))); then
    print -u2 "_docs: -p/--pull cannot be combined with -c or -u"
    return 2
  fi

  if ((fix && (pull || update))); then
    print -u2 "_docs: -f/--fix cannot be combined with -p or -u"
    return 2
  fi

  # --- open latest standup note -------------------------------------------
  if ((update)); then
    local root="${REPO_DOCS:?_docs: REPO_DOCS not set — check .env}"
    local dir="${ZDIR_DOCS_STANDUP:?_docs: ZDIR_DOCS_STANDUP not set — check .env}"

    # sync first so the newest note from remote is on disk.
    # git pull fetches itself, so no separate fetch is needed.
    # -C runs git in $root, so this works from any directory.
    local before
    before=$(git -C "$root" rev-parse HEAD) || {
      print -u2 "_docs: not a git repo: $root"
      return 1
    }

    git -C "$root" pull --rebase --autostash || {
      print -u2 "_docs: pull failed: resolve in $root, then retry"
      return 1
    }

    if [[ $before == $(git -C "$root" rev-parse HEAD) ]]; then
      print "_docs: already up to date"
    else
      print "_docs: pulled:"
      git -C "$root" log --oneline --no-decorate "${before}..HEAD"
    fi

    [[ -d $dir ]] || {
      print -u2 "_docs: no such directory: $dir"
      return 1
    }

    # regular files, sorted by name; [-1] takes the last (newest dated file).
    # swap for *(.om[1]) to pick most-recently-modified instead.
    local -a notes
    notes=("$dir"/*(.N))

    (($#notes)) || {
      print -u2 "_docs: no notes found in $dir"
      return 1
    }

    local latest=${notes[-1]}
    print "_docs: opening ${latest:t}"
    ${IDE_DOCS:-code} "$root" "$latest"
    return 0
  fi

  git rev-parse --show-toplevel >/dev/null 2>&1 || {
    print -u2 "_docs: not a git repo"
    return 1
  }

  if ((fix && ! commit)); then
    pnpm fix:all || {
      print -u2 "_docs: pnpm fix:all failed — no fix commit created"
      return 1
    }

    local changes
    changes=$(git status --porcelain) || return 1
    if [[ -z $changes ]]; then
      print "_docs: nothing to commit"
      return 0
    fi

    git add -A || return 1
    git commit -m "lint + format fixes" || return 1
    return 0
  fi

  # --- pull path: stash, pull, restore, refocus ----------------------------
  if ((pull)); then
    local before stashed=0
    before=$(git rev-parse HEAD)

    # 1. Stash local changes (including untracked) as a temp stash
    if [[ -n $(git status --porcelain) ]]; then
      git stash push --include-untracked -m "_docs: temp stash" || return 1
      stashed=1
    fi

    # 2. Pull (git pull fetches first, so no separate fetch)
    git pull --rebase || {
      ((stashed)) && print -u2 "_docs: pull failed — your changes are in the stash ('git stash pop')"
      return 1
    }

    # 3. Restore the temp stash
    if ((stashed)); then
      git stash pop || {
        print -u2 "_docs: stash pop conflicted — resolve, then 'git stash drop'"
        return 1
      }
    fi

    if [[ $before == $(git rev-parse HEAD) ]]; then
      print "_docs: already up to date"
    else
      print "_docs: pulled —"
      git log --oneline --no-decorate "${before}..HEAD"
    fi

    # 4. Refocus the docs IDE on the repo
    ${IDE_DOCS:-code} "$(git rev-parse --show-toplevel)"
    return 0
  fi

  # --- commit path: stage and commit before touching the remote ------------
  if ((commit)); then
    if [[ -z $(git status --porcelain) ]]; then
      print "_docs: nothing to commit"
      _docs --fix
      return $?
    fi

    : ${msg:="add daily update"}

    git add -A || return 1
    git commit -m "$msg" || return 1
  fi

  # --- shared path: reconcile with remote ----------------------------------
  local before
  before=$(git rev-parse HEAD)

  git pull --rebase --autostash || {
    if ((commit)); then
      print -u2 "_docs: rebase stopped — commit is safe locally, resolve then push"
    else
      print -u2 "_docs: pull failed — resolve, then 'git rebase --continue'"
    fi
    return 1
  }

  if [[ $before == $(git rev-parse HEAD) ]]; then
    ((commit)) || print "_docs: already up to date"
  else
    print "_docs: pulled —"
    git log --oneline --no-decorate "${before}..HEAD"
  fi

  # --- commit path only: publish -------------------------------------------
  if ((commit)); then
    git push || return 1
    print "_docs: pushed — $msg"
    _docs --fix
    return $?
  fi
}
