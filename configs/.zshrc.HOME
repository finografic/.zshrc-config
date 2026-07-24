# ============================================================================ #
# NOTE: 0. CORE PATHS
# ============================================================================ #

export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/Library/pnpm/bin:$PATH"

export PATH="$HOME/.local/bin/:$PATH"
export PATH="$HOME/.local/pipx/venvs/graphifyy/bin/python:$PATH"
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.lmstudio/bin:$PATH"

export PATH="$HOME/.proto/bin/moon:$PATH"
export PATH="$HOME/.proto/bin:$PATH"

export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/bin/hs:$PATH"

export PATH="$(go env GOPATH)/bin:$PATH"

# ============================================================================ #
# NOTE: 1. P10K INSTANT PROMPT (must be early, before other console output)
# ============================================================================ #

# Disable instant prompt so the prompt appears only at the END after full
# bootstrap/splash output. Instant prompt causes a premature prompt to appear
# while bootstrapping continues in the background.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

if [[ "${IS_CODEX:-}" != "true" && -z "${CODEX_CI:-}" && -z "${CODEX_THREAD_ID:-}" && "${__CFBundleIdentifier:-}" != "com.openai.codex" && -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================ #
# NOTE: 2. ZSHRC-CONFIG BOOTSTRAP
# ============================================================================ #

export ZSHRC_ROOT="$HOME/.zshrc-config"
source "$ZSHRC_ROOT/bootstrap/index.zsh"

# ============================================================================ #
# NOTE: 3. MAIN CONFIG
# ============================================================================ #

source "$ZSHRC_ROOT/main.zsh"

# ============================================================================ #
# NOTE: 4. LeanCTX
# ============================================================================ #

# lean-ctx shell hook — begin
if [ -n "${LEAN_CTX_AGENT:-}" ] && [ -f "$HOME/.config/lean-ctx/shell-hook.zsh" ]; then
	. "$HOME/.config/lean-ctx/shell-hook.zsh"
fi
# lean-ctx shell hook — end

# >>> lean-ctx agent aliases >>>
alias claude='LEAN_CTX_AGENT=1 BASH_ENV="$HOME/.bashenv" claude'
alias codebuddy='LEAN_CTX_AGENT=1 BASH_ENV="$HOME/.bashenv" codebuddy'
alias codex='LEAN_CTX_AGENT=1 BASH_ENV="$HOME/.bashenv" codex'
alias gemini='LEAN_CTX_AGENT=1 BASH_ENV="$HOME/.bashenv" gemini'
# <<< lean-ctx agent aliases <<<
