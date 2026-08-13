# ============================================================================ #
# NOTE: OLLAMA - Best-effort local model server startup
# ============================================================================ #

function ollama-local-host() {
	local host="${OLLAMA_HOST:-http://localhost:11434}"

	[[ "$host" == http://localhost:* || "$host" == http://127.0.0.1:* ]]
}

function ollama-api-ready() {
	local host="${OLLAMA_HOST:-http://localhost:11434}"

	command -v curl >/dev/null 2>&1 || return 1
	curl -fsS --max-time 0.3 "$host/api/tags" >/dev/null 2>&1
}

function ollama-sync-launchctl-env() {
	[[ -n "${OLLAMA_MODELS:-}" ]] || return 0
	command -v launchctl >/dev/null 2>&1 || return 0

	launchctl setenv OLLAMA_MODELS "$OLLAMA_MODELS" >/dev/null 2>&1 || true
}

function ollama-start-server() {
	[[ "$OSTYPE" == darwin* ]] || return 0
	[[ -o interactive ]] || return 0
	ollama-local-host || return 0
	ollama-sync-launchctl-env
	ollama-api-ready && return 0
	pgrep -x ollama >/dev/null 2>&1 && return 0

	if [[ -d /Applications/Ollama.app || -d "$HOME/Applications/Ollama.app" ]]; then
		command -v open >/dev/null 2>&1 || return 0
		open -gj -a Ollama >/dev/null 2>&1 || true
		return 0
	fi

	[[ "${OLLAMA_BOOTSTRAP_SERVE:-false}" == true ]] || return 0
	command -v ollama >/dev/null 2>&1 || return 0
	OLLAMA_HOST="${OLLAMA_HOST:-http://localhost:11434}" ollama serve >/dev/null 2>&1 &!
}

ollama-start-server
