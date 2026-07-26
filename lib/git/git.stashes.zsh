# ============================================================================ #
# NOTE: LIST GIT STASHES..
# ============================================================================ #

# OUTPUT LAYOUT CONSTANTS
export MAX_CHARS=131
export BRANCH_NAME_FALLBACK="n/a"
export FILES_NUM_WIDTH=2
export CHANGES_NUM_WIDTH=4
export METER_LENGTH=30
export ALIGN_LEFT="left"
export ALIGN_RIGHT="right"
# ============================================================================ #
# export DEFAULT_COL_WIDTH=40
# ============================================================================ #

# export BRANCH_NAME_WIDTH=12
# export STASH_NAME_WIDTH=35
# ============================================================================ #
export DEFAULT_COL_WIDTH=40
export BRANCH_NAME_WIDTH=40
export STASH_NAME_WIDTH=52

# Format branch text with specified width and alignment
function _format-branch() {
  local text=$1
  local width=${2:-$DEFAULT_COL_WIDTH}
  local align=${3:-$ALIGN_LEFT}

  if [[ "$align" == "$ALIGN_RIGHT" ]]; then
    printf "  %${width}s" "$text" # Two spaces before right-aligned text
  else
    printf "  %-${width}s" "$text" # Two spaces before left-aligned text
  fi
}

# Format date to be consistent and remove timezone
function _format-date() {
  local line=$1
  echo "$line" |
    sed -E 's/([A-Za-z]+) ([A-Za-z]+) ([0-9]) /\1 \2 0\3 /g' |
    sed -E 's/([A-Za-z]+) ([A-Za-z]+) ([0-9]{2}) ([0-9]{4})/\1 \2 \3 \4/g' |
    sed 's/ +0200//' # remove timezone offset
}

# Get stats for a stash reference
function _get-stash-stats() {
  local stash_ref=$1
  local stats=$(git stash show "$stash_ref" --shortstat 2>/dev/null)

  # Extract the numbers
  local num_files=$(echo "$stats" | grep -o '[0-9]* file' | cut -d' ' -f1)
  local inserts=$(echo "$stats" | grep -o '[0-9]* insertion' | cut -d' ' -f1)
  local deletes=$(echo "$stats" | grep -o '[0-9]* deletion' | cut -d' ' -f1)

  # Default to 0 if empty
  echo "${num_files:-0} ${inserts:-0} ${deletes:-0}"
}

# Generate a visual meter of changes
function _generate-changes-meter() {
  local inserts=$1
  local deletes=$2

  if (( inserts + deletes > 0 )); then
    local total=$((inserts + deletes))
    local plus_count=$((inserts * METER_LENGTH / total))
    local minus_count=$((deletes * METER_LENGTH / total))

    printf "${_g}"
    for ((i = 0; i < plus_count; i++)); do printf "+"; done
    printf "${_r}"
    for ((i = 0; i < minus_count; i++)); do printf "-"; done
    printf "${_0}"
  fi
}

# ============================================================================ #
# NOTE: MAIN FUNCTION - LIST GIT STASHES (FOR CURRENT/LOCAL REPO)
# ============================================================================ #

function _stashes() {
  local MAX_CHARS=131
  local BRANCH_NAME_FALLBACK="n/a"
  local FILES_NUM_WIDTH=2
  local CHANGES_NUM_WIDTH=4
  local METER_LENGTH=30
  local ALIGN_LEFT="left"
  local ALIGN_RIGHT="right"
  # ================================================================== #
  # local DEFAULT_COL_WIDTH=40
  # local BRANCH_NAME_WIDTH=12
  # local STASH_NAME_WIDTH=35
  # ================================================================== #
  local DEFAULT_COL_WIDTH=40
  local BRANCH_NAME_WIDTH=40
  local STASH_NAME_WIDTH=52

  # Use a different format string to avoid the double-dash
  git stash list --format="%ad %gd %gs" | while read -r line; do
    # Extract stash reference from the line
    stash_ref=$(echo "$line" | grep -o "stash@{[0-9]*}")

    # Fallback to finding stash reference if not directly present
    if [[ -z "$stash_ref" ]]; then
      stash_index=$(git stash list --format="%ad %gd %gs" | grep -nF "$line" | cut -d: -f1)
      stash_ref="stash@{$((stash_index - 1))}"
    fi

    # Format date and extract components
    formatted_date=$(_format-date "$line")
    date_part=$(echo "$formatted_date" | awk '{print $1, $2, $3, $4}')

    # Extract branch information
    branch_info=$(echo "$line" | grep -o "On [^:]*\|WIP on [^:]*\|(no branch)" | sed 's/^On //')
    stash_name="${branch_info//(no branch)/$BRANCH_NAME_FALLBACK}"
    branch_name=$(echo "$line" | grep -o ": .*$" | sed 's/^: //')

    # Get change statistics
    read num_files inserts deletes <<<$(_get-stash-stats "$stash_ref")

    # Print with fixed widths for each section
    printf "%s" "$date_part"
    printf "${_grey}%s  ${_0}" "$(_format-branch "$stash_name" "$BRANCH_NAME_WIDTH" "$ALIGN_RIGHT")"
    printf "${_c}%s${_0}" "$(_format-branch "$branch_name" "$STASH_NAME_WIDTH")"
    printf "${_grey}files:${_0} ${_c}%${FILES_NUM_WIDTH}d${_0} " "$num_files"
    printf "  ${_g}+%${CHANGES_NUM_WIDTH}d${_0}  ${_r}-%${CHANGES_NUM_WIDTH}d${_0}  " "$inserts" "$deletes"

    # Generate and print meter
    _generate-changes-meter "$inserts" "$deletes"

    printf "\n"
  done 2>/dev/null
}
