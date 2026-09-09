# ============================================================================ #
# CHECKOUT OPERATIONS
# ============================================================================ #

source "$ZSHRC_ROOT/lib/colors.zsh"

# Turns arbitrary text into a git-ref-safe fragment: lowercased, every run of
# non-alphanumerics collapsed to a single `-`, leading/trailing `-` stripped.
#
# Restricting the output alphabet to [a-z0-9-] sidesteps the whole of
# git-check-ref-format at once — no `..`, `~`, `^`, `:`, `?`, `*`, `[`, `@{`,
# backslash, no leading/trailing dot, no `.lock` suffix.
function _git-slugify() {
  setopt localoptions extended_glob

  local slug="${1:l}"
  slug="${slug//[^a-z0-9]/-}" # anything else becomes a dash
  slug="${slug//-##/-}"       # collapse dash runs
  slug="${slug#-}"
  slug="${slug%-}"

  print -r -- "$slug"
}

# Checkout. With a branch name, a plain `git checkout` (extra args pass
# through). With no arguments, prompts for a ticket number and title, builds
# `{NNNNN}_{slugified-title}` and creates that branch with `-b`.
function _gco() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "\n${_y}⚠️  Not inside a git repository.${_0}\n"
    return 1
  fi

  # Branch name supplied — existing branch, no -b.
  if [[ -n "$1" ]]; then
    git checkout "$@"
    return $?
  fi

  local ticket_number ticket_title slug

  while true; do
    echo -e "${_m}Ticket number ${_grey}(5 digits)${_m}:${_0}"
    read -r ticket_number || return 1

    [[ "$ticket_number" == [0-9][0-9][0-9][0-9][0-9] ]] && break
    echo "${_y}⚠️  Must be exactly 5 digits.${_0}"
  done

  while true; do
    echo -e "${_m}Ticket title ${_grey}(100 chars max)${_m}:${_0}"
    read -r ticket_title || return 1

    if (( ${#ticket_title} > 100 )); then
      ticket_title="${ticket_title:0:100}"
      echo "${_y}⚠️  Title truncated to 100 characters.${_0}"
    fi

    slug="$(_git-slugify "$ticket_title")"
    [[ -n "$slug" ]] && break
    echo "${_y}⚠️  Title must contain at least one letter or number.${_0}"
  done

  local branch="${ticket_number}_${slug}"

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    echo "\n${_y}⚠️  Branch already exists: ${_0}${branch}\n"
    return 1
  fi

  echo "\n${_w}New branch:${_0}\n"
  echo "${_c}${branch}${_0}\n"

  if git checkout -b "$branch"; then
    echo "\n${_g}✅ DONE${_0}\n"
  fi
}
