# Color variables
_y='\033[1;33m'      # Yellow (warnings)
_r='\033[1;31m'      # Red (errors)
_g='\033[1;32m'      # Green (success)
_grey='\033[0;90m'   # Grey (informational)
_0='\033[0m'         # Reset

# ========================================================================= #
# GIT TAG OPERATIONS -- FOR CI
# ========================================================================= #

# Create and push a dev tag that exactly matches package.json
_gtag() {
  # Check if inside a git repository
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

  # Run from repo root to keep paths stable
  builtin cd "$GIT_ROOT" || return 1

  if [[ ! -f "./package.json" ]]; then
    echo "\n${_r}❌ package.json not found in repo root\n${_0}"
    return 1
  fi

  # Ensure this is the carbon-sageone repo
  local PROJECT_NAME
  PROJECT_NAME=$(node -p "require('./package.json').name" 2>/dev/null)
  if [[ -z "$PROJECT_NAME" ]]; then
    echo "\n${_r}❌ Unable to read package.json name via node\n${_0}"
    return 1
  fi
  if [[ "$PROJECT_NAME" != "carbon-sageone" ]]; then
    echo "\n${_r}❌ This helper is only for carbon-sageone (found: $PROJECT_NAME)\n${_0}"
    return 1
  fi

  local PKG_VERSION
  PKG_VERSION=$(node -p "require('./package.json').version" 2>/dev/null)
  if [[ -z "$PKG_VERSION" ]]; then
    echo "\n${_r}❌ Unable to read package.json version via node\n${_0}"
    return 1
  fi

  local CURRENT_BRANCH
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ -z "$CURRENT_BRANCH" || "$CURRENT_BRANCH" == "HEAD" ]]; then
    echo "\n${_r}❌ Unable to determine current branch\n${_0}"
    return 1
  fi

  local REQUESTED_TAG_VERSION
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --v=*)
        REQUESTED_TAG_VERSION="${1#--v=}"; shift;;
      --v)
        if [[ -z "$2" ]]; then
          echo "\n${_r}❌ Missing value for --v\n${_0}"
          return 1
        fi
        REQUESTED_TAG_VERSION="$2"; shift 2;;
      -h|--help)
        echo "\nUsage: _gtag --v N\n"
        echo "Creates and pushes the exact tag from package.json (v<package.json version>)\n"
        return 0;;
      *)
        echo "\n${_y}⚠️  Unknown option: $1\n${_0}"
        return 1
        ;;
    esac
  done

  if [[ -z "$REQUESTED_TAG_VERSION" ]]; then
    echo "\n${_r}❌ Missing required flag: --v N\n${_0}"
    return 1
  fi

  local NORMALIZED_TAG_VERSION
  NORMALIZED_TAG_VERSION="${REQUESTED_TAG_VERSION#v}"
  if [[ ! "$NORMALIZED_TAG_VERSION" =~ ^[0-9]+$ ]]; then
    echo "\n${_r}❌ Invalid tag number: $REQUESTED_TAG_VERSION (expected 4 or v4)\n${_0}"
    return 1
  fi

  local VERSION_BRANCH_FRAGMENT PACKAGE_TAG_VERSION
  if [[ "$PKG_VERSION" =~ ^([0-9]+\.[0-9]+\.[0-9]+)-(.+)-tag-([0-9]+)$ ]]; then
    VERSION_BRANCH_FRAGMENT="${match[2]}"
    PACKAGE_TAG_VERSION="${match[3]}"
  else
    echo "\n${_r}❌ package.json version must match X.Y.Z-<branch-fragment>-tag-N (found: $PKG_VERSION)\n${_0}"
    return 1
  fi

  if [[ "$CURRENT_BRANCH" != *"$VERSION_BRANCH_FRAGMENT"* ]]; then
    echo "\n${_r}❌ package.json version fragment '$VERSION_BRANCH_FRAGMENT' is not in current branch '$CURRENT_BRANCH'\n${_0}"
    return 1
  fi

  if [[ "$NORMALIZED_TAG_VERSION" != "$PACKAGE_TAG_VERSION" ]]; then
    echo "\n${_grey}Skipping tag push:${_0} package.json tag version '$PACKAGE_TAG_VERSION' does not match --v '$NORMALIZED_TAG_VERSION'\n"
    return 0
  fi

  local FULL_TAG
  FULL_TAG="v${PKG_VERSION}"

  if git rev-parse -q --verify "refs/tags/$FULL_TAG" >/dev/null 2>&1; then
    echo "\n${_grey}Skipping tag push:${_0} local tag already exists: $FULL_TAG\n"
    return 0
  fi

  if git ls-remote --tags origin | grep -qF "refs/tags/$FULL_TAG"; then
    echo "\n${_grey}Skipping tag push:${_0} remote tag already exists: $FULL_TAG\n"
    return 0
  fi

  echo "${_grey}Creating tag at HEAD:${_0} $FULL_TAG"
  git tag "$FULL_TAG"
  if [ $? -ne 0 ]; then
    echo "\n${_r}❌ Failed to create tag\n${_0}"
    return 1
  fi

  # Create metadata (optional)
  {
    echo "$(date '+%Y-%m-%d %H:%M:%S') version=$PKG_VERSION branch=$CURRENT_BRANCH tag=$PACKAGE_TAG_VERSION"
  } >> "$HOME/TAGS_METADATA" 2>/dev/null

  echo "${_grey}Pushing tag:${_0} $FULL_TAG"
  git push origin "$FULL_TAG"
  if [ $? -ne 0 ]; then
    echo "\n${_r}❌ Failed to push tag\n${_0}"
    return 1
  fi

  echo "\n${_g}✅ Tag pushed:${_0} $FULL_TAG\n"
}
