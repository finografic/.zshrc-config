# ========================================================================= #
# COMMIT OPERATIONS
# ========================================================================= #

_is_finografic_repo() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1

  [[ -f "$root/package.json" ]] || return 1
  grep -q '"@finografic/' "$root/package.json"
}

_has_build_artifact_changes() {
  git status --porcelain | grep -E '^( M|A |AM|MM).* (dist/|bin/)' >/dev/null
}

# Commit (staged files only)
_gc() {
  if [[ -n "$1" ]]; then
    message="$1"
    shift # Remove first argument (message)

    if git commit -m "$message" "$@"; then
      echo "\n${_g}✅ DONE\n"
    fi
  else
    echo "\n${_y}⚠️  NO COMMIT MESSAGE SUPPLIED\n"
  fi
}

_gca () {
  if [[ -n "$1" ]]
  then
    message="$1"
    shift

    if _is_finografic_repo && _has_build_artifact_changes; then
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

    if [[ "$ZENV" == "office-macos" ]]
    then
      echo -e "${_m}Are you sure? ${_grey}(y/N)${_0}"
      read -r response
      response=${response:-N}

      if [[ "$response" =~ ^[Yy]$ ]]
      then
        git add -A || return 1

        if git diff --cached --quiet
        then
          echo "\n${_y}⚠️  No staged changes to commit.${_0}"
          return 1
        fi

        git commit -m "$message" "$@" || return 1
        echo "\n${_g}✅ DONE\n"
      else
        echo "\n${_y}⚠️  Operation aborted.${_0}"
        return 1
      fi
    else
      git add -A || return 1

      if git diff --cached --quiet
      then
        echo "\n${_y}⚠️  No staged changes to commit.${_0}"
        return 1
      fi

      if git commit -m "$message" "$@"
      then
        echo "\n${_g}✅ DONE\n"
      fi
    fi
  else
    echo "\n${_y}⚠️  NO COMMIT MESSAGE SUPPLIED\n"
    return 1
  fi
}


# Amend commit
_ga() {
  if [[ $1 > "" ]]; then
    git commit -am "$1" --allow-empty
  else
    echo "\n${_y}⚠️   NO COMMIT MESSAGE TO AMEND\n"
  fi
}

# Continue merge
_gmc() {
  if [ -f .git/MERGE_HEAD ]; then
    echo -e "${_m}Merge in progress. Commit with --no-verify..? ${_grey}(y/N)${_0}"
    read -r response
    response=${response:-N}
    git commit --no-verify
  else
    echo "\n${_y}⚠️   No merge in progress. Exiting.${_0}\n"
  fi
}

# Untrack file/folders
_grm() {
  if [[ $1 > "" ]]; then
    git rm --cached "$1"
  else
    echo "\n${_y}⚠️   NO FILE SPECIFIED TO UN-TRACK${_0}\n"
  fi
}
