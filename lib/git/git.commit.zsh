# ============================================================================ #
# COMMIT OPERATIONS
# ============================================================================ #

source "$ZSHRC_ROOT/lib/colors.zsh"
source "$ZSHRC_ROOT/lib/llms.zsh"

function _is-finografic-repo() {
  local root
  root="$(git-root)" || return 1

  [[ -f "$root/package.json" ]] || return 1
  grep -q '"@finografic/' "$root/package.json"
}

function _has-build-artifact-changes() {
  git status --porcelain | grep -E '^( M|A |AM|MM).* (dist/|bin/)' >/dev/null
}

# Drafts a commit message via a local Ollama model (`ollama-commit-message` in
# lib/llms.zsh) from the current staged diff and asks for confirmation. `n`
# regenerates; Ctrl+C aborts. Sets $ai_commit_message on accept, empty otherwise
# (Ollama unavailable) — callers just check for output, same trial-basis contract
# as `ollama-commit-message` itself. Caller is responsible for making sure there
# IS a staged diff first.
#
# Pass `--staged` to describe only the staged diff — used by `_gc --ai`, which
# commits staged files only (see `ollama-commit-message` in lib/llms.zsh).
#
# Shared by `_gc --ai` and `_gca --ai` (lib/git/git.commit.zsh).
function _git-ai-commit-message() {
  local confirm_status
  ai_commit_message=''

  while true; do
    ollama-commit-message "$1" || return 1
    ai_commit_message="$ollama_commit_message"

    # Label, blank line, then the message on its own in yellow — it is what you are
    # judging — with the model/latency receding to grey underneath.
    echo "\n${_w}Suggested commit message:${_0}\n"
    echo "${_y}${ai_commit_message}${_0}"
    ollama-commit-meta-line
    echo ""

    confirm_status=0
    ollama-commit-confirm || confirm_status=$?
    (( confirm_status == 0 )) && return 0
    (( confirm_status == 2 )) && return 1
  done
}

# Shared "add everything, then commit" flow: finografic build-artifact guard,
# office-macos confirmation, `git add -A`, staged-diff check, and the commit
# itself. Used by `_gca` for both its plain and `--ai` message paths.
function _git-add-all-and-commit() {
  local message="$1"
  shift

  if _is-finografic-repo && _has-build-artifact-changes; then
    echo "\n${_y}⚠️  Finografic repo detected with build artifact changes.${_0}"
    echo "${_grey}This commit will include dist/ or bin/.${_0}"
    echo "${_grey}Recommended flow:${_0}"
    echo "  pnpm build"
    echo "  git add dist bin"
    echo "  git commit -m \"build: update artifacts\""
    echo

    echo -e "${_m}Proceed anyway? ${_grey}(y/N)${_0}"
    read -r response
    response=${response:-N}

    [[ "$response" =~ ^[Yy]$ ]] || {
      echo "\n${_y}⚠️  Commit aborted.${_0}"
      return 1
    }
  fi

  if [[ "$ZENV" == "office-macos" ]]; then
    echo -e "${_m}Are you sure? ${_grey}(y/N)${_0}"
    read -r response
    response=${response:-N}

    [[ "$response" =~ ^[Yy]$ ]] || {
      echo "\n${_y}⚠️  Operation aborted.${_0}"
      return 1
    }
  fi

  git add -A || return 1

  if git diff --cached --quiet; then
    echo "\n${_y}⚠️  No staged changes to commit.${_0}"
    return 1
  fi

  if git commit -m "$message" "$@"; then
    echo "\n${_g}✅ DONE${_0}\n"
  fi
}

# Commit (staged files only). With `--ai` and no message, drafts one via
# `_git-ai-commit-message` from the staged diff — no `git add` involved either
# way. Trial basis: if the draft is unavailable, falls back to the same
# "NO COMMIT MESSAGE SUPPLIED" behaviour as a plain call with no message.
function _gc() {
  local -a args=()
  local use_ai=0 arg
  for arg in "$@"; do
    if [[ "$arg" == "--ai" ]]; then
      use_ai=1
    else
      args+=("$arg")
    fi
  done

  local message="${args[1]}"
  (( $#args )) && args[1]=()

  if [[ -z "$message" && "$use_ai" -eq 1 ]]; then
    if git diff --cached --quiet; then
      echo "\n${_y}⚠️  No staged changes to commit.${_0}"
      return 1
    fi

    _git-ai-commit-message --staged
    message="$ai_commit_message"
  fi

  if [[ -n "$message" ]]; then
    if git commit -m "$message" "${args[@]}"; then
      echo "\n${_g}✅ DONE${_0}\n"
    fi
  else
    echo "\n${_y}⚠️  NO COMMIT MESSAGE SUPPLIED\n"
  fi
}

# Commit (stages everything first via `git add -A`). With `--ai` and no
# message, drafts one via `_git-ai-commit-message` from the staged diff (after
# the add-all). Trial basis: if the draft is unavailable, falls back to the
# same "NO COMMIT MESSAGE SUPPLIED" behaviour as a plain call with no message.
function _gca() {
  local -a args=()
  local use_ai=0 arg
  for arg in "$@"; do
    if [[ "$arg" == "--ai" ]]; then
      use_ai=1
    else
      args+=("$arg")
    fi
  done

  local message="${args[1]}"
  (( $#args )) && args[1]=()

  if [[ -z "$message" && "$use_ai" -eq 1 ]]; then
    git add -A || return 1

    if git diff --cached --quiet; then
      echo "\n${_y}⚠️  No staged changes to commit.${_0}"
      return 1
    fi

    _git-ai-commit-message
    message="$ai_commit_message"
  fi

  if [[ -z "$message" ]]; then
    echo "\n${_y}⚠️  NO COMMIT MESSAGE SUPPLIED\n"
    return 1
  fi

  _git-add-all-and-commit "$message" "${args[@]}"
}

# Git, commit, COPY (LAST) (reuses last commit message; supports multi-line)
function _gcc() {
  # Check if inside a git repository
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a git repository."
    return 1
  fi

  # Ensure there is at least one commit to repeat
  if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
    echo "\n${_y}⚠️  No commits found to repeat.${_0}"
    return 1
  fi

  # Exit early if there is nothing to commit (tracked/untracked)
  if [[ -z "$(git status --porcelain 2>/dev/null)" ]]; then
    echo "\n${_y}⚠️  No changes to commit.${_0}"
    return 1
  fi

  local previous_head
  local previous_parent
  previous_head="$(git rev-parse HEAD 2>/dev/null)" || return 1
  previous_parent="$(git rev-parse "${previous_head}^" 2>/dev/null)"

  local last_message
  last_message="$(git log -1 --pretty=%B 2>/dev/null)" || return 1

  if [[ -z "$last_message" ]]; then
    echo "\n${_y}⚠️  Last commit message is empty; aborting.${_0}"
    return 1
  fi

  echo "\n${_w}committing with message:   \n${_c}${last_message}${_0}\n"

  git add -A || return 1

  if git diff --cached --quiet; then
    echo "\n${_y}⚠️  No staged changes to commit.${_0}"
    return 1
  fi

  # Use -F - to preserve multi-line messages exactly
  if print -r -- "$last_message" | git commit -F - "$@"; then
    echo -e "\n${_c}Squash commit? ${_grey}(n/Y)${_0}"
    read -r response
    response=${response:-Y}

    if [[ "$response" =~ ^[Yy]$ ]]; then
      if [[ -z "$previous_head" ]]; then
        echo "\n${_y}⚠️  Cannot squash because the copied commit is the root commit.${_0}"
      else
        git reset --soft "$previous_head" || return 1

        if ! print -r -- "$last_message" | git commit --amend -F - "$@"; then
          return 1
        fi
      fi
    fi

    echo "\n${_g}✅ DONE${_0}\n"
  fi

  # NOTE: DISALBED.
  # REBASE AND AUTO-ACCEPTED PUSH FORCE-WITH-LEASE
  # _grb -y
}

# Amend commit
function _ga() {
  if [[ -n "$1" ]]; then
    git commit -am "$1" --allow-empty
  else
    echo "\n${_y}⚠️   NO COMMIT MESSAGE TO AMEND\n"
  fi
}

# Continue merge
function _gmc() {
  if [[ -f .git/MERGE_HEAD ]]; then
    echo -e "${_m}Merge in progress. Commit with --no-verify..? ${_grey}(y/N)${_0}"
    read -r response
    response=${response:-N}
    git commit --no-verify
  else
    echo "\n${_y}⚠️   No merge in progress. Exiting.${_0}\n"
  fi
}

# Untrack file/folders (keeps them on disk)
function _grm() {
  local target="$1"

  if [[ -z "$target" ]]; then
    echo "\n${_y}⚠️   Usage: _grm <tracked-path>${_0}\n"
    return 2
  fi

  # Only untrack if Git is tracking it
  if ! git ls-files --error-unmatch -- "$target" >/dev/null 2>&1; then
    echo "\n${_y}⚠️   NOT TRACKED: ${_0}$target\n"
    return 1
  fi

  if [[ -d "$target" && ! -L "$target" ]]; then
    echo "\n${_y}UN-TRACKING FOLDER: ${_0}$target\n"
    git rm -r --cached -- "$target"
  else
    echo "\n${_y}UN-TRACKING FILE: ${_0}$target\n"
    git rm --cached -- "$target"
  fi

  git status
}

# git restore --staged --worktree -- .cursor/hooks/state/continual-learning.json

# Untrack file/folders
# _grm() {
#   if [[ $1 > "" ]]; then
#     git rm --cached "$1"
#     git status
#   else
#     echo "\n${_y}⚠️   NO FOLDER SPECIFIED TO UN-TRACK${_0}\n"
#   fi
# }

# _grm() {
#   if [[ -f "$1" ]]; then
#     git rm --cached "$1"
#     git status
#   else
#     echo "\n${_y}⚠️   NO FOLDER SPECIFIED TO UN-TRACK${_0}\n"
#   fi
# }

# if [ -f .cursor ]; then
#   echo ".cursor is file"
# fi

