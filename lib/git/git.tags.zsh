source "$ZSHRC_ROOT/lib/colors.zsh"

# ============================================================================ #
# GIT TAG OPERATIONS
# ============================================================================ #

# Create and push a tag that exactly matches the version in package.json.
#
# The tag is always `v<version>` — there is nothing to pass and nothing to
# choose. Run it from anywhere inside the repo.
function _gtag() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        echo "\n${_bold}Usage:${_0} _gtag\n"
        echo "Creates and pushes ${_c}v<package.json version>${_0} at HEAD.\n"
        return 0;;
      *)
        echo "\n${_y}⚠️  Unknown option: $1${_0}"
        echo "${_grey}Usage: _gtag  (no arguments)${_0}\n"
        return 1;;
    esac
  done

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "\n${_y}⚠️  Not inside of git repository\n${_0}"
    return 1
  fi

  local GIT_ROOT
  GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z "$GIT_ROOT" ]]; then
    echo "\n${_r}❌ Unable to determine git root\n${_0}"
    return 1
  fi

  if [[ ! -f "$GIT_ROOT/package.json" ]]; then
    echo "\n${_r}❌ package.json not found in repo root\n${_0}"
    return 1
  fi

  local PKG_NAME PKG_VERSION
  PKG_NAME=$(node -p "require('$GIT_ROOT/package.json').name" 2>/dev/null)
  PKG_VERSION=$(node -p "require('$GIT_ROOT/package.json').version" 2>/dev/null)
  if [[ -z "$PKG_VERSION" || "$PKG_VERSION" == "undefined" ]]; then
    echo "\n${_r}❌ Unable to read package.json version via node\n${_0}"
    return 1
  fi

  local FULL_TAG
  FULL_TAG="v${PKG_VERSION}"

  if git -C "$GIT_ROOT" rev-parse -q --verify "refs/tags/$FULL_TAG" >/dev/null 2>&1; then
    echo "\n${_grey}Skipping tag push:${_0} local tag already exists: ${_c}$FULL_TAG${_0}\n"
    return 0
  fi

  if git -C "$GIT_ROOT" ls-remote --tags origin | grep -qF "refs/tags/$FULL_TAG"; then
    echo "\n${_grey}Skipping tag push:${_0} remote tag already exists: ${_c}$FULL_TAG${_0}\n"
    return 0
  fi

  echo ""
  [[ -n "$PKG_NAME" && "$PKG_NAME" != "undefined" ]] && \
    echo "${_grey}Package:${_0} $PKG_NAME"
  echo "${_grey}Tag:    ${_0} ${_c}$FULL_TAG${_0}"
  echo ""

  echo "${_grey}Creating tag at HEAD:${_0} $FULL_TAG"
  if ! git -C "$GIT_ROOT" tag "$FULL_TAG"; then
    echo "\n${_r}❌ Failed to create tag\n${_0}"
    return 1
  fi

  # Create metadata (optional)
  {
    echo "$(date '+%Y-%m-%d %H:%M:%S') package=$PKG_NAME version=$PKG_VERSION"
  } >> "$HOME/TAGS_METADATA" 2>/dev/null

  echo "${_grey}Pushing tag:${_0} $FULL_TAG"
  if ! git -C "$GIT_ROOT" push origin "$FULL_TAG"; then
    echo "\n${_r}❌ Failed to push tag\n${_0}"
    return 1
  fi

  echo "\n${_g}✅ Tag pushed:${_0} $FULL_TAG\n"
}
