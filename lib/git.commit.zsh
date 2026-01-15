# ========================================================================= #
# COMMIT OPERATIONS
# ========================================================================= #

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

# Add all and commit
_gca() {
  if [[ -n "$1" ]]; then
    message="$1"
    shift # Remove first argument (message)

    # Confirm prompt, if in office environment
    if [[ "$ZENV" == "office-macos" ]]; then
      echo -e "${_m}Are you sure? ${_grey}(y/N)${_0}"
      read -r response
      response=${response:-N}

      if [[ "$response" =~ ^[Yy]$ ]]; then
        git add . && git commit -m "$message" "$@"
        echo "\n${_g}✅ DONE\n"
      else
        echo "\n${_y}⚠️  Operation aborted.${_0}"
        return 1
      fi
    else
      if git add . && git commit -m "$message" "$@"; then
        echo "\n${_g}✅ DONE\n"
      fi
    fi
  else
    echo "\n${_y}⚠️  NO COMMIT MESSAGE SUPPLIED\n"
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
