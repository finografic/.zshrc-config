# MY REPOS
REPOS_FINO="$HOME/repos-finografic"
REPOS_FINO_REF="$HOME/repos-finografic-ref"
REPOS="$REPOS_FINO"
REPOS_NEXT="$HOME/repos-next"
REPOS_SERVER="$HOME/repos-server"
REPOS_LOUPEDECK="$HOME/repos-loupedeck"
REPOS_APNAES="$HOME/repos-apnaes"

alias repos="cd $REPOS && l"
alias skills="cd $HOME/ai-agent-skills && l"
alias misc="cd $REPOS/repos-various && l"
alias apps="cd $REPOS/repos-x-apps && l"
alias json="cd $REPOS_NEXT/json-walker && l"
alias driz="cd $REPOS_SERVER/__DRIZZLE__/api-fastify-drizzle && l"
alias loup='cd "$HOME/Library/Application Support/Logi/LogiPluginService" && ls -lAh'

# ============================================================================ #
# OVERRIDES
# ============================================================================ #

function config() {
  cursor "$ZSHRC_ROOT/.vscode/zshrc-config.code-workspace"
}

function @lab() {
  cd "$HOME/LLAAB" && l
}

function @vault() {
  cd "$HOME/LLAAB/vault" && l
}

function _lab() {
  cursor "$HOME/LLAAB/llaab.code-workspace"
}

# ============================================================================ #
# MY REPOS (NEXT!)
# ============================================================================ #

REPO_SCRIPTS="$REPOS_FINO/@finografic-project-scripts"
REPO_PLATE="$REPOS_FINO/@finografic-plate-editor"
REPO_ZUSTAND_CONTEXT="$REPOS_FINO/@finografic-zustand-context-creator"
REPO_APNAES="$REPOS_APNAES/apnaes-monorepo"

REPO_IOX_LOUPEDECK="$REPOS_FINO/iox-loupedeck"
REPO_FNX_MONOREPO="$REPOS_FINO/fnx-monorepo"
REPO_TOUCH_MONOREPO="$REPOS_FINO/touch-monorepo"
REPO_TOUCH_MONOREPO_ORIG="$REPOS_FINO_REF/touch-monorepo"

alias fnx="cd $REPO_FNX_MONOREPO && l"
alias iox="cd $REPO_IOX_LOUPEDECK && l"

# APNAES
alias apnaes="cd $REPO_APNAES && l"
alias mono="cd $REPO_APNAES && l"
alias admin="cd $REPO_APNAES/apps/client && l"
alias api="cd $REPOS_APNAES/apnaes-api && l"

@fino() {
  cd "$REPOS_FINO" && l
}

function my() {
  cd "$REPOS_FINO" && l
}

@zust() {
  cd "$REPO_ZUSTAND_CONTEXT" && l
}

@plate() {
  cd "$REPO_PLATE" && l
}

@touch() {
  cd "$REPO_TOUCH_MONOREPO" && l
}

@touch_orig() {
  cd "$REPO_TOUCH_MONOREPO_ORIG" && l
}

@prod() {
  cd "$REPO_TOUCH_MONOREPO/dist-production" && l
}

# ============================================================================ #
# MONOREPO ALIASES - DETECTS THE MONOREPO PATH USING $PWD
# ============================================================================ #

# Helper function to find monorepo ROOT
function find-monorepo-root() {
  local current=$PWD
  while [[ $current != "/" ]]; do
    if [[ -f "$current/pnpm-workspace.yaml" ]]; then
      echo "$current"
      return 0
    fi
    current=$(dirname "$current")
  done
  echo "$REPO_APNAES"
  return 1
}

@config() {
  local monorepo=$(find-monorepo-root)
  cd "$monorepo/config" && l
}

@server() {
  local monorepo=$(find-monorepo-root)
  cd "$monorepo/apps/server" && l
}

@client() {
  local monorepo=$(find-monorepo-root)
  cd "$monorepo/apps/client" && l
}

@design() {
  local monorepo=$(find-monorepo-root)
  cd "$monorepo/packages/design-system" && l
}

@ui() {
  local monorepo=$(find-monorepo-root)
  cd "$monorepo/packages/ui" && l
}

@shared() {
  local monorepo=$(find-monorepo-root)
  cd "$monorepo/packages/shared" && l
}

@globals() {
  local monorepo=$(find-monorepo-root)
  cd "$monorepo/packages/globals" && l
}

@editor() {
  local monorepo=$(find-monorepo-root)
  cd "$monorepo/packages/plate-editor" && l
}

@icons() {
  local monorepo=$(find-monorepo-root)
  cd "$monorepo/packages/icons" && l
}

@i18n() {
  local monorepo=$(find-monorepo-root)
  cd "$monorepo/packages/i18n" && l
}

@core() {
  local monorepo=$(find-monorepo-root)
  cd "$monorepo/packages/core" && l
}

@purge() {
  local monorepo=$(find-monorepo-root)
  cd "$monorepo/packages/purge-builds" && l
}

@scripts() {
  local monorepo=$(find-monorepo-root)
  cd "$monorepo/packages/scripts" && l
}

@types() {
  local monorepo=$(find-monorepo-root)
  cd "$monorepo/packages/types" && l
}

# ============================================================================ #

@_deps() {
  cd "$REPOS_FINO/@finografic-deps-policy" && l
}

function _deps() {
  pnpm -C "$REPOS_FINO/_@finografic-deps-policy" run policy:update:release
}

@_harness() {
  cd "$REPOS_FINO/@finografic-ai-harness" && l
}

# ============================================================================ #

@_web() {
  cd "$HOME/LLAAB/packages/web" && l
}

@_testing() {
  cd "$REPOS_FINO/___FINOGRAFIC-TESTING___" && l
}

@_cv() {
  cd "$REPOS_FINO/cv-justin-rankin" && l
}

@_kit() {
  cd "$REPOS_FINO/@finografic-cli-kit" && l
}

@_genx() {
  cd "$REPOS_FINO/@finografic-genx" && l
}

@_gli() {
  cd "$REPOS_FINO/@finografic-gli" && l
}

@_md() {
  cd "$REPOS_FINO/@finografic-md-lint" && l
}

@_lay() {
  cd "$REPOS_FINO/macos-layouts" && l
}

@_core() {
  cd "$REPOS_FINO/@finografic-core" && l
}

@_xscan() {
  cd "$REPOS_FINO/@finografic-deps-xscan" && l
}

@_starter() {
  cd "$REPOS_FINO/monorepo-starter" && l
}

@_demo() {
  cd "$REPOS_FINO/monorepo-demo" && l
}

@_ds() {
  cd "$REPOS_FINO/@finografic-design-system" && l
}

@_icons() {
  cd "$REPOS_FINO/@finografic-design-system/packages/icons" && l
}

@_dprint() {
  cd "$REPOS_FINO/@finografic-dprint-config" && l
}

@_eslint() {
  cd "$REPOS_FINO/@finografic-eslint-config" && l
}

@_oxc() {
  cd "$REPOS_FINO/@finografic-oxc-config" && l
}

@_pipeline() {
  cd "$REPOS_FINO/@finografic-ai-agent-pipeline" && l
}

alias pipe="cd $REPOS_FINO/@finografic-ai-agent-pipeline && l"

@_agents() {
  cd "$REPOS_FINO/@finografic-ai-agent-config" && l
}

alias agents="cd $REPOS_FINO/@finografic-ai-agent-config && l"

@_lucide() {
  cd "$REPOS_FINO/@finografic-lucide-manager" && l
}

@_scripts() {
  cd "$REPOS_FINO/@finografic-project-scripts" && l
}

@_react() {
  cd "$REPOS_FINO/@finografic-react" && l
}

@_zustand() {
  cd "$REPOS_FINO/@finografic-zustand-context-creator" && l
}

# Mounts a LAN SMB share. Credentials and host come from .env — never inline them
# here; the previous version had the password in the alias body.
function mount-nas() {
  if [[ -z "${NAS_HOST:-}" || -z "${NAS_SHARE:-}" ]]; then
    print "mount-nas: set NAS_HOST, NAS_SHARE (and optionally NAS_USER) in .env" >&2
    return 1
  fi
  local target="$HOME/Public/${NAS_SHARE}"
  mkdir -p "$target"
  # Omitting the password makes mount_smbfs prompt for it, or use the Keychain.
  sudo mount_smbfs "//${NAS_USER:-$USER}@${NAS_HOST}/${NAS_SHARE}" "$target"
  cd "$target" && l
}
