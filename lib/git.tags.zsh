# Color variables
_y='\033[1;33m'      # Yellow (warnings)
_r='\033[1;31m'      # Red (errors)
_g='\033[1;32m'      # Green (success)
_grey='\033[0;90m'   # Grey (informational)
_0='\033[0m'         # Reset

# ========================================================================= #
# GIT TAG OPERATIONS -- FOR CI
# ========================================================================= #

# Create/recreate and push a dev tag (force mode for iterative development)
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

  # Defaults from package.json + current branch
  local PKG_VERSION
  PKG_VERSION=$(node -p "require('./package.json').version" 2>/dev/null)
  if [[ -z "$PKG_VERSION" ]]; then
    echo "\n${_r}❌ Unable to read package.json version via node\n${_0}"
    return 1
  fi

  local CURRENT_BRANCH CURRENT_JIRA
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  CURRENT_JIRA=${CURRENT_BRANCH#build-}
  CURRENT_JIRA=${CURRENT_JIRA%%/*}

  local CARBON_VERSION TAG_NUM
  CARBON_VERSION=""
  TAG_NUM=""

  # Version detection
  if [[ "$PKG_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    CARBON_VERSION="$PKG_VERSION"
  elif [[ "$PKG_VERSION" =~ ^([0-9]+\.[0-9]+\.[0-9]+)-(.+)-tag-v([0-9]+)$ ]]; then
    CARBON_VERSION="${match[1]}"
    CURRENT_JIRA="${match[2]}"
    TAG_NUM="${match[3]}"
  else
    echo "\n${_r}❌ Unrecognised package.json version format: $PKG_VERSION\n${_0}"
    return 1
  fi

  # Flags
  local FLAG_CARBON FLAG_JIRA FLAG_V FLAG_TAG
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --carbon=*)
        FLAG_CARBON="${1#--carbon=}"; shift;;
      --carbon)
        FLAG_CARBON="$2"; shift 2;;
      --jira=*)
        FLAG_JIRA="${1#--jira=}"; shift;;
      --jira)
        FLAG_JIRA="$2"; shift 2;;
      --v=*)
        FLAG_V="${1#--v=}"; shift;;
      --v)
        FLAG_V="$2"; shift 2;;
      --tag=*)
        FLAG_TAG="${1#--tag=}"; shift;;
      --tag)
        FLAG_TAG="$2"; shift 2;;
      -h|--help)
        echo "\nUsage: _gtag [--carbon X.Y.Z] [--jira SBS-123456] [--v 4|v4] [--tag vX.Y.Z-SBS-123456-tag-vN]\n"
        echo "Creates/recreates dev tag, pushes branch + tag (force mode)\n"
        return 0;;
      *)
        echo "\n${_y}⚠️  Unknown option: $1\n${_0}"
        return 1
        ;;
    esac
  done

  [[ -n "$FLAG_CARBON" ]] && CARBON_VERSION="$FLAG_CARBON"
  [[ -n "$FLAG_JIRA" ]] && CURRENT_JIRA="${FLAG_JIRA#build-}"
  CURRENT_JIRA=${CURRENT_JIRA%%/*}

  local TAG_VERSION
  TAG_VERSION=""

  if [[ -n "$FLAG_V" ]]; then
    local NUM
    NUM="${FLAG_V#v}"
    if [[ ! "$NUM" =~ ^[0-9]+$ ]]; then
      echo "\n${_r}❌ Invalid --v value: $FLAG_V (expected 4 or v4)\n${_0}"
      return 1
    fi
    TAG_VERSION="v$NUM"
  elif [[ -n "$TAG_NUM" ]]; then
    TAG_VERSION="v$TAG_NUM"
  else
    TAG_VERSION="v1"
  fi

  local FULL_TAG
  if [[ -n "$FLAG_TAG" ]]; then
    FULL_TAG="$FLAG_TAG"
  else
    if [[ -z "$CURRENT_JIRA" ]]; then
      echo "\n${_r}❌ Unable to determine JIRA issue from branch (try --jira SBS-123456)\n${_0}"
      return 1
    fi
    FULL_TAG="v${CARBON_VERSION}-${CURRENT_JIRA}-tag-${TAG_VERSION}"
  fi

  # Delete old tag (local + remote) if it exists
  if git rev-parse -q --verify "refs/tags/$FULL_TAG" >/dev/null 2>&1; then
    echo "\n${_grey}Deleting local tag:${_0} $FULL_TAG"
    git tag -d "$FULL_TAG" 2>/dev/null
  fi

  if git ls-remote --tags origin | grep -q "refs/tags/$FULL_TAG"; then
    echo "${_grey}Deleting remote tag:${_0} $FULL_TAG"
    git push --delete origin "$FULL_TAG" 2>/dev/null
  fi

  # Create new tag at HEAD
  echo "${_grey}Creating tag at HEAD:${_0} $FULL_TAG"
  git tag "$FULL_TAG"
  if [ $? -ne 0 ]; then
    echo "\n${_r}❌ Failed to create tag\n${_0}"
    return 1
  fi

  # Create metadata (optional)
  {
    echo "$(date '+%Y-%m-%d %H:%M:%S') carbon=$CARBON_VERSION jira=$CURRENT_JIRA v=$TAG_VERSION tag=$FULL_TAG"
  } >> "$HOME/TAGS_METADATA" 2>/dev/null

  # Push branch with force-with-lease
  echo "${_grey}Pushing branch:${_0} $CURRENT_BRANCH ${_grey}(--force-with-lease)${_0}"
  git push -u origin "$CURRENT_BRANCH" --force-with-lease
  if [ $? -ne 0 ]; then
    echo "\n${_r}❌ Failed to push branch\n${_0}"
    return 1
  fi

  # Push tag
  echo "${_grey}Pushing tag:${_0} $FULL_TAG"
  git push origin "$FULL_TAG"
  if [ $? -ne 0 ]; then
    echo "\n${_r}❌ Failed to push tag\n${_0}"
    return 1
  fi

  echo "\n${_g}✅ Tag pushed:${_0} $FULL_TAG\n"
}
