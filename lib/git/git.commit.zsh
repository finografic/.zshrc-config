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

# Commit (staged files only)
function _gc() {
  if [[ -n "$1" ]]; then
    message="$1"
    shift # Remove first argument (message)

    if git commit -m "$message" "$@"; then
      echo "\n${_g}✅ DONE${_0}\n"
    fi
  else
    echo "\n${_y}⚠️  NO COMMIT MESSAGE SUPPLIED\n"
  fi
}

function _gca() {
  if [[ -n "$1" ]]; then
    message="$1"
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

      if [[ "$response" =~ ^[Yy]$ ]]; then
        git add -A || return 1

        if git diff --cached --quiet; then
          echo "\n${_y}⚠️  No staged changes to commit.${_0}"
          return 1
        fi

        git commit -m "$message" "$@" || return 1
        echo "\n${_g}✅ DONE${_0}\n"
      else
        echo "\n${_y}⚠️  Operation aborted.${_0}"
        return 1
      fi
    else
      git add -A || return 1

      if git diff --cached --quiet; then
        echo "\n${_y}⚠️  No staged changes to commit.${_0}"
        return 1
      fi

      if git commit -m "$message" "$@"; then
        echo "\n${_g}✅ DONE${_0}\n"
      fi
    fi
  else
    echo "\n${_y}⚠️  NO COMMIT MESSAGE SUPPLIED\n"
    return 1
  fi
}

# Git, commit, add, AI. Same add-all semantics as `_gca`, but drafts the
# message via a local Ollama model when none is supplied. Trial basis: if
# Ollama isn't running, no model is installed, or the draft is declined, this
# falls back to the same "NO COMMIT MESSAGE SUPPLIED" behaviour as `_gca`.
# Shared `ollama-commit-message` helper lives in `lib/llms.zsh`, also used by
# `zupdate`.
function _gcai() {
  local message="$1"
  [[ -n "$message" ]] && shift

  if [[ -z "$message" ]]; then
    git add -A || return 1

    if git diff --cached --quiet; then
      echo "\n${_y}⚠️  No staged changes to commit.${_0}"
      return 1
    fi

    if ollama-commit-message; then
      message="$ollama_commit_message"

      # Label, blank line, then the message on its own in yellow — it is what you are
      # judging — with the model/latency receding to grey underneath.
      echo "\n${_w}Suggested commit message:${_0}\n"
      echo "${_y}${message}${_0}"
      ollama-commit-meta-line
      echo ""

      echo -e "${_m}Use this message? ${_grey}(Y/n)${_0}"
      read -r response
      response=${response:-Y}

      [[ "$response" =~ ^[Yy]$ ]] || message=''
    fi
  fi

  if [[ -z "$message" ]]; then
    echo "\n${_y}⚠️  NO COMMIT MESSAGE SUPPLIED\n"
    return 1
  fi

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

    if [[ "$response" =~ ^[Yy]$ ]]; then
      git add -A || return 1

      if git diff --cached --quiet; then
        echo "\n${_y}⚠️  No staged changes to commit.${_0}"
        return 1
      fi

      git commit -m "$message" "$@" || return 1
      echo "\n${_g}✅ DONE${_0}\n"
    else
      echo "\n${_y}⚠️  Operation aborted.${_0}"
      return 1
    fi
  else
    git add -A || return 1

    if git diff --cached --quiet; then
      echo "\n${_y}⚠️  No staged changes to commit.${_0}"
      return 1
    fi

    if git commit -m "$message" "$@"; then
      echo "\n${_g}✅ DONE${_0}\n"
    fi
  fi
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
