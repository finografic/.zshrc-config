export REPOS="$HOME/repos"

# UNIVERSAL - DEV ALIAS TO **CURRENT** REPO
alias dev="echo 'CHOOSE AN ALIAS!'"

# COMMANDS

function repos() {
  # MOVED !!
  cd "$REPOS" && l
}

function npmi() {
  if [[ -n "$@" ]]; then
    # ARGS PASSED: INSTALL PACKAGES AND UPDATE package-lock.json
    git update-index --no-assume-unchanged -- package-lock.json
    npm install $@
    git status
  else
    # NO ARGS: INSTALL DEFAULT PACKAGES TEMP IGNORE package-lock.json
    npm install
    git update-index --assume-unchanged -- package-lock.json
    git status
  fi
}

function _gclean-orig() {
  [ ! -d "./.git" ] && return
  echo "\n${_y}CLEAN / DELETE LOCAL GIT BRANCHES.. sure to proceed? (y/n)\n${_0}"
  read -r response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "\n${_grey}Proceeding to delete local branches..\n${_0}"
    git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d
  else
    echo "Operation aborted."
    exit 1
  fi
}

function _gclean() {
  local pattern=$1
  [ ! -d "./.git" ] && return

  if [ -z "$pattern" ]; then
    echo "\n${_y}Error: Please provide a pattern (e.g., 'T*' for branches starting with T)\n${_0}"
    return 1
  fi

  echo "\n${_y}CLEAN / DELETE LOCAL GIT BRANCHES MATCHING '$pattern'.. sure to proceed? (y/n)\n${_0}"
  read -r response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "\n${_grey}Proceeding to delete local branches matching '$pattern'..\n${_0}"
    git branch --merged | grep -E "^[[:space:]]*$pattern$" | xargs git branch -d
  else
    echo "Operation aborted."
    return 1
  fi
}

# ============================================================================ #
# GITHUB PACKAGE RELEASE (GitHub Packages only, no npmjs)
# ============================================================================ #

# Replaces inline package.json scripts like:
#   "release.github.patch": "pnpm release.verify && pnpm release.verify.git && pnpm release.bump.patch && pnpm release.push"
#   "release.github.minor": "pnpm release.verify && pnpm release.verify.git && pnpm release.bump.minor && pnpm release.push"
#   "release.github.major": "pnpm release.verify && pnpm release.verify.git && pnpm release.bump.major && pnpm release.push"
# Run from repo root. Uses npm by default; supports --pm pnpm.
#
function _release() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "\n${_y}⚠️  Not inside a git repository\n${_0}"
    return 1
  fi

  local GIT_ROOT
  GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
  [[ -z "$GIT_ROOT" ]] && { echo "\n${_r}❌ Unable to determine git root\n${_0}"; return 1; }
  builtin cd "$GIT_ROOT" || return 1

  [[ ! -f "./package.json" ]] && { echo "\n${_r}❌ package.json not found in repo root\n${_0}"; return 1; }

  local PKG_NAME PKG_JSON
  PKG_NAME=$(node -p "require('./package.json').name" 2>/dev/null)
  PKG_JSON=$(cat ./package.json 2>/dev/null)
  [[ -z "$PKG_NAME" ]] && { echo "\n${_r}❌ Unable to read package.json name\n${_0}"; return 1; }

  # Must be scoped (GitHub Packages requires @org/name)
  [[ "$PKG_NAME" != @*/* ]] && {
    echo "\n${_r}❌ Package must be scoped for GitHub Packages (e.g. @org/name), found: $PKG_NAME\n${_0}"
    return 1
  }

  # Must target GitHub Packages (not npmjs)
  local IS_GITHUB=false
  if echo "$PKG_JSON" | grep -qE 'npm\.pkg\.github\.com'; then
    IS_GITHUB=true
  fi
  if [[ -f "./.npmrc" ]] && grep -q "npm.pkg.github.com" ./.npmrc; then
    IS_GITHUB=true
  fi
  [[ "$IS_GITHUB" != true ]] && {
    echo "\n${_r}❌ Not a GitHub package (no publishConfig.registry or .npmrc for npm.pkg.github.com)\n${_0}"
    return 1
  }

  # Flags
  local BUMP="minor"
  local PM="npm"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --bump=*)
        BUMP="${1#--bump=}"; shift;;
      --bump)
        BUMP="$2"; shift 2;;
      --pm=*)
        PM="${1#--pm=}"; shift;;
      --pm)
        PM="$2"; shift 2;;
      --package-manager=*)
        PM="${1#--package-manager=}"; shift;;
      --package-manager)
        PM="$2"; shift 2;;
      -h|--help)
        echo "\n${_grey}Usage: _release [--bump patch|minor|major] [--pm npm|pnpm]\n${_0}"
        echo "  --bump         Version bump type (default: minor)\n"
        echo "  --pm           Package manager: npm (default) or pnpm\n"
        echo "Flow: verify (test) → verify.git (clean) → bump → build → push + publish\n"
        return 0;;
      *)
        echo "\n${_y}⚠️  Unknown option: $1\n${_0}"
        return 1;;
    esac
  done

  # Validate bump
  case "$BUMP" in
    patch|minor|major) ;;
    *)
      echo "\n${_r}❌ Invalid --bump: $BUMP (use patch, minor, or major)\n${_0}"
      return 1;;
  esac

  # Validate package manager
  case "$PM" in
    npm|pnpm) ;;
    *)
      echo "\n${_r}❌ Invalid --pm: $PM (use npm or pnpm)\n${_0}"
      return 1;;
  esac

  echo "\n${_grey}Releasing $PKG_NAME (bump=$BUMP, pm=$PM)\n${_0}"

  # 1. release.verify - run test if exists
  if grep -q '"test"' package.json 2>/dev/null; then
    echo "${_grey}release.verify: running test...${_0}"
    if [[ "$PM" == "npm" ]]; then
      npm run test || { echo "\n${_r}❌ npm run test failed\n${_0}"; return 1; }
    else
      pnpm run test || { echo "\n${_r}❌ pnpm run test failed\n${_0}"; return 1; }
    fi
  fi

  # 2. release.verify.git - clean working tree
  echo "${_grey}release.verify.git: checking working tree...${_0}"
  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    echo "\n${_r}❌ Working tree has uncommitted changes. Commit or stash first.\n${_0}"
    return 1
  fi

  # 3. release.bump.<type>
  echo "${_grey}release.bump.$BUMP: bumping version...${_0}"
  if [[ "$PM" == "npm" ]]; then
    npm version "$BUMP" || { echo "\n${_r}❌ npm version failed\n${_0}"; return 1; }
  else
    pnpm version "$BUMP" || { echo "\n${_r}❌ pnpm version failed\n${_0}"; return 1; }
  fi

  # 4. Build (if script exists) - needed for publish artifact
  if grep -q '"build"' package.json 2>/dev/null; then
    echo "${_grey}Running build...${_0}"
    if [[ "$PM" == "npm" ]]; then
      npm run build || { echo "\n${_r}❌ npm run build failed\n${_0}"; return 1; }
    else
      pnpm run build || { echo "\n${_r}❌ pnpm run build failed\n${_0}"; return 1; }
    fi
  fi

  # 5. release.push - git push + tags + publish
  echo "${_grey}release.push: pushing commits and tags...${_0}"
  git push || { echo "\n${_r}❌ git push failed\n${_0}"; return 1; }
  git push --tags || { echo "\n${_r}❌ git push --tags failed\n${_0}"; return 1; }

  echo "${_grey}Publishing to GitHub Packages...${_0}"
  if [[ "$PM" == "npm" ]]; then
    npm publish || { echo "\n${_r}❌ npm publish failed\n${_0}"; return 1; }
  else
    pnpm publish --no-git-checks || { echo "\n${_r}❌ pnpm publish failed\n${_0}"; return 1; }
  fi

  echo "\n${_g}✅ Released $PKG_NAME\n${_0}"
}

# ============================================================================ #
# NOTE: APNAES - RSYNC TRANSFERS, BACKUPS, and PUBLISHING..
# ============================================================================ #

export ROOT_ACCESS="root@REDACTED-IP"
export REMOTE_LSWS="/usr/local/lsws"

export LOCAL_WEB="$HOME/repos-apnaes/apnaes-web"
export LOCAL_API="$HOME/repos-apnaes/apnaes-api"
export REMOTE_WEB="/usr/local/lsws/Example"
export REMOTE_API="/usr/local/lsws/api"

# REMOTE: HOSTING
# alias a2="ssh -R 52698:localhost:52698 REDACTED-IP -p 7822 -l REDACTED-CODENAME"
alias h="ssh -i ~/.ssh/id_hostinger.pub -p 22 $ROOT_ACCESS"
alias a="ssh -i ~/.ssh/id_hostinger.pub -p 22 apnaes@REDACTED-IP"

function h-get-all() {
  echo "${_c}\nDownloading FULL 'lsws' folder + contents from remote...\n${_0}"
  rsync -avz --progress -e "ssh -p 22" $ROOT_ACCESS:/usr/local/lsws ~/Public

  echo "${_g}\nfull 'lsws' folder downloaded to ~/Public\n${_0}"
}

function h-pub-web() {
  echo "${_y}\nPublishing WEB: LOCAL -> REMOTE...\n${_0}"
  rsync -avz --progress --no-perms --no-owner --no-group $LOCAL_WEB/dist/ $ROOT_ACCESS:$REMOTE_WEB/html/

  echo "${_grey}\nweb 'html' content published to remote.\n${_0}"
}

# ============================================================================ #

