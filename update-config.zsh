#!/bin/zsh
# ============================================================================ #
# NOTE: UPDATE-CONFIG - `zupdate`, the multi-system sync command
#
# Flow: fetch -> review -> stage -> commit -> pull --rebase -> scan -> push
#
# Usage:
#   zupdate "<message>"    commit with this message (gets `chore: ` if it has
#                          no conventional-commit type prefix)
#   zupdate                open $EDITOR for a real message, like `git commit`
#   zupdate --sync         the only auto-message path:
#                          `chore(sync): update from <profile>`
#   zupdate --dry-run      show what would happen; change nothing
#
# Options:
#   --all            also stage untracked files (they are listed, never implied)
#   -y, --yes        skip the confirmation prompt
#   --remote <name>  push somewhere other than the branch's upstream
#   --no-scan        skip the pre-push secret scan (you will be warned)
#   -h, --help       this message
#
# WHY THIS IS NOT THE OLD SCRIPT
#
# The previous version was `fetch -> add . -> commit -m "updated from: $ZENV"
# -> pull --rebase -> push`, with `set -e` and nothing else. Three real
# problems, all of which this rewrite exists to fix:
#
#   1. `git add .` stages everything unseen. That is how 66 MB of vendored
#      binaries and a set of tracked p10k caches got committed in the first
#      place. Staging is now `git add -u` (tracked changes only); untracked
#      files are listed for you and require `--all` or an explicit `git add`.
#   2. The commit message it generated was rejected by this repo's own
#      commitlint hook, so ~570 commits were made with the hook bypassed.
#      Every path here produces a conforming message.
#   3. `set -e` on a rebase conflict left you mid-rebase with no explanation.
#      There is now a real failure path that tells you how to get out.
#
# Pure zsh on purpose: this has to work on a fresh server with no Node.
# ============================================================================ #

ZSHRC_ROOT="${ZSHRC_ROOT:-$HOME/.zshrc-config}"
source "$ZSHRC_ROOT/lib/colors.zsh"

# Conventional-commit types accepted by commitlint.config.mjs. Kept in sync by
# `zconf doctor`? No — deliberately duplicated, because this script must run
# without Node and cannot read the JS config.
readonly ZU_TYPES='build|chore|ci|deps|docs|feat|fix|refactor|revert|style|test'

function zu-die() {
  print "${_r}zupdate: $1${_0}" >&2
  exit "${2:-1}"
}

function zu-info() { print "${_c}zupdate:${_0} $1"; }
function zu-warn() { print "${_y}zupdate:${_0} $1" >&2; }

# Confirm prompt with the default LAST, so Enter accepts it.
function zu-confirm() {
  local prompt="$1" reply
  print -n "$prompt ${_grey}(Y/n)${_0} "
  read -r reply
  [[ -z "$reply" || "$reply" == [yY]* ]]
}

# Adds `chore: ` unless the message already carries a conventional type, so
# the commitlint hook never has to be bypassed.
function zu-normalize-message() {
  local message="$1"
  if [[ "$message" =~ "^(${ZU_TYPES})(\([^)]+\))?!?: " ]]; then
    print -r -- "$message"
  else
    print -r -- "chore: $message"
  fi
}

# Resolves the remote to push to: the branch's own upstream, else origin.
function zu-remote-for-branch() {
  local branch="$1" upstream
  upstream="$(git rev-parse --abbrev-ref --symbolic-full-name "${branch}@{upstream}" 2> /dev/null || true)"

  if [[ -n "$upstream" ]]; then
    print -r -- "${upstream%%/*}"
  else
    print -r -- origin
  fi
}

# Pre-push secret scan.
#
# Prefers `zconf scan`, but this script must work where Node does not exist, so
# it falls back to a dependency-free grep mirroring the CI `secret-scan` job.
# The check is never silently skipped — only skipped when you ask for it.
function zu-scan() {
  if command -v node > /dev/null 2>&1 && [[ -f "$ZSHRC_ROOT/packages/zconf/dist/index.js" ]]; then
    zu-info "scanning for secrets (zconf)"
    node "$ZSHRC_ROOT/packages/zconf/dist/index.js" scan || return 1
    return 0
  fi

  zu-info "scanning for secrets (grep fallback — zconf build not available)"

  local pattern='([0-9]{1,3}\.){3}[0-9]{1,3}|-----BEGIN [A-Z ]*PRIVATE KEY-----'
  local hits
  hits="$(
    git grep -InE "$pattern" -- . ':!docs/todo/**' ':!.agents/**' ':!pnpm-lock.yaml' \
      ':!package-lock.json' ':!.github/workflows/ci.yml' 2> /dev/null \
      | grep -vE '127\.0\.0\.1|0\.0\.0\.0|255\.255\.255\.255' || true
  )"

  if [[ -n "$hits" ]]; then
    print "$hits" >&2
    return 1
  fi

  return 0
}

# Prints the usage half of this file's own header, stopping at the sentinel
# below so the rationale section is not dumped at the user. Anchored to text
# rather than line numbers, which would silently drift as the header is edited.
function zu-usage() {
  awk 'NR >= 3 { if ($0 ~ /^# WHY THIS IS NOT/) exit; print }' \
    "$ZSHRC_ROOT/update-config.zsh" | sed 's/^# \{0,1\}//'
}

function zupdate-main() {
  # `local_options` restores these on return, so sourcing this file for its
  # helpers (as tests/test-zupdate.zsh does) cannot leave err_exit set in the
  # caller's shell.
  setopt local_options err_exit pipe_fail

  local message='' sync=false dry_run=false stage_all=false assume_yes=false do_scan=true
  local remote=''

  while (( $# > 0 )); do
    case "$1" in
      --sync) sync=true; shift ;;
      --dry-run) dry_run=true; shift ;;
      --all) stage_all=true; shift ;;
      -y | --yes) assume_yes=true; shift ;;
      --no-scan) do_scan=false; shift ;;
      --remote) remote="${2:-}"; [[ -n "$remote" ]] || zu-die "--remote needs a value"; shift 2 ;;
      -h | --help) zu-usage; return 0 ;;
      -*) zu-die "unknown option: $1 (try --help)" ;;
      *)
        [[ -z "$message" ]] || zu-die "more than one message given"
        message="$1"
        shift
        ;;
    esac
  done

  $sync && [[ -n "$message" ]] && zu-die "--sync takes no message"

  builtin cd "$ZSHRC_ROOT" || zu-die "cannot cd to $ZSHRC_ROOT"
  git rev-parse --is-inside-work-tree > /dev/null 2>&1 || zu-die "$ZSHRC_ROOT is not a git repository"

  local branch
  branch="$(git rev-parse --abbrev-ref HEAD)"
  [[ -n "$remote" ]] || remote="$(zu-remote-for-branch "$branch")"

  # Refuse to run mid-rebase rather than making it worse.
  if [[ -d "$(git rev-parse --git-path rebase-merge)" || -d "$(git rev-parse --git-path rebase-apply)" ]]; then
    zu-die "a rebase is already in progress — finish it with \`git rebase --continue\` or \`git rebase --abort\`"
  fi

  zu-info "branch ${_bold}${branch}${_0} -> remote ${_bold}${remote}${_0}"
  git fetch "$remote" --quiet || zu-die "could not fetch from $remote"

  # ------------------------------------------------------------------ review
  local tracked untracked
  tracked="$(git status --porcelain --untracked-files=no)"
  untracked="$(git ls-files --others --exclude-standard)"

  if [[ -n "$tracked" ]]; then
    print "\n${_bold}Tracked changes to be staged:${_0}"
    print "$tracked"
  fi

  if [[ -n "$untracked" ]]; then
    print "\n${_y}Untracked files${_0} ${_grey}(NOT staged unless you pass --all)${_0}"
    # Sizes shown so a stray large file is obvious rather than silently added.
    print "$untracked" | while IFS= read -r file; do
      print "  ${_grey}$(du -h "$file" 2> /dev/null | cut -f1)${_0}\t$file"
    done
  fi

  if [[ -z "$tracked" && ( -z "$untracked" || $stage_all == false ) ]]; then
    zu-info "no tracked changes to commit"
    if [[ -n "$untracked" ]]; then
      zu-info "untracked files exist — use ${_bold}--all${_0} or \`git add\` them to include them"
    fi

    # Nothing new to commit does NOT mean nothing to push. A previous run may
    # have committed and then been stopped by the secret scan, which would
    # otherwise strand that commit locally forever. Found by the test suite.
    if $dry_run; then
      zu-info "${_grey}dry run — would pull --rebase, then push anything already committed${_0}"
      return 0
    fi

    zu-pull-rebase "$remote" "$branch"
    zu-push-if-ahead "$remote" "$branch" "$do_scan"
    return 0
  fi

  # ----------------------------------------------------------------- message
  local commit_message=''
  if $sync; then
    commit_message="chore(sync): update from ${ZENV:-$(hostname -s 2> /dev/null || print unknown)}"
  elif [[ -n "$message" ]]; then
    commit_message="$(zu-normalize-message "$message")"
  fi

  if [[ -n "$commit_message" ]]; then
    print "\n${_bold}Commit message:${_0} $commit_message"
  else
    print "\n${_bold}Commit message:${_0} ${_grey}\$EDITOR will open${_0}"
  fi

  # ----------------------------------------------------------------- dry run
  if $dry_run; then
    print ""
    zu-info "${_grey}dry run — nothing staged, committed or pushed${_0}"
    $stage_all && [[ -n "$untracked" ]] && zu-info "${_grey}would also stage the untracked files above${_0}"
    zu-info "${_grey}would push ${branch} to ${remote}${_0}"
    return 0
  fi

  # ----------------------------------------------------------------- confirm
  if ! $assume_yes; then
    print ""
    zu-confirm "Stage, commit and push to ${_bold}${remote}/${branch}${_0}?" || {
      zu-info "aborted"
      return 1
    }
  fi

  # ------------------------------------------------------------------- stage
  git add -u
  if $stage_all && [[ -n "$untracked" ]]; then
    git add --all
  fi

  if git diff --staged --quiet; then
    zu-info "nothing staged after all"
  elif [[ -n "$commit_message" ]]; then
    git commit -m "$commit_message"
  else
    # No -m: git opens $EDITOR and the commitlint hook still runs.
    git commit
  fi

  zu-pull-rebase "$remote" "$branch"
  zu-push-if-ahead "$remote" "$branch" "$do_scan"
}

# Scans, then pushes — but only when there is actually something to push.
#
# Shared by both paths on purpose. The "nothing to commit" path needs it too,
# because a commit made by an earlier run that the scan then blocked would
# otherwise never leave this machine.
function zu-push-if-ahead() {
  local remote="$1" branch="$2" do_scan="$3" ahead

  ahead="$(git rev-list --count "${remote}/${branch}..${branch}" 2> /dev/null || print 0)"

  if (( ahead == 0 )); then
    zu-info "${_g}up to date — nothing to push${_0}"
    return 0
  fi

  if [[ "$do_scan" == true ]]; then
    if ! zu-scan; then
      print ""
      zu-die "secret scan failed — NOT pushing. Fix the matches above, or re-run with --no-scan if they are false positives."
    fi
  else
    zu-warn "${_y}pre-push secret scan skipped (--no-scan)${_0}"
  fi

  git push "$remote" "$branch"
  zu-info "${_g}pushed ${ahead} commit(s) — ${branch} -> ${remote}${_0}"
}

# Rebase onto the remote, with a failure path that explains itself instead of
# leaving you mid-rebase wondering what happened (the old `set -e` behaviour).
function zu-pull-rebase() {
  local remote="$1" branch="$2"

  if git pull --rebase "$remote" "$branch"; then
    return 0
  fi

  print "" >&2
  print "${_r}zupdate: rebase onto ${remote}/${branch} hit a conflict.${_0}" >&2
  print "" >&2
  print "${_bold}Your commit is safe.${_0} To finish:" >&2
  print "  ${_c}git status${_0}                 see the conflicted files" >&2
  print "  ${_c}git add <file>${_0}             once each is resolved" >&2
  print "  ${_c}git rebase --continue${_0}      finish, then re-run zupdate" >&2
  print "" >&2
  print "Or back out completely with ${_c}git rebase --abort${_0}." >&2
  exit 1
}

# Run only when EXECUTED, never when sourced — tests source this file to reach
# the pure helpers above without triggering a real commit and push.
# ${zsh_eval_context[-1]} is "file" whenever sourced, at any depth; when run it
# is the invocation kind, so `!= file` means exactly "not being sourced".
if [[ "${zsh_eval_context[-1]}" != file ]]; then
  zupdate-main "$@"
fi
