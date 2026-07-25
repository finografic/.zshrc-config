# ============================================================================ #
# NOTE: CORE DETECT - Pure environment predicates
#
# Definitions only, no side effects, no output — safe to source from
# `bootstrap/index.zsh` (which runs before `core/env.zsh`) and again later.
# The guard makes the second source free.
#
# This exists as its own file precisely because bootstrap needs these answers
# before `core/env.zsh` has run. One source of truth per fact.
# ============================================================================ #

(( ${+_ZSHRC_DETECT_LOADED} )) && return 0
typeset -g _ZSHRC_DETECT_LOADED=1

# True inside a container. Checks the standard Docker and Podman markers plus
# the env flags this config sets. All builtin tests — no subprocess.
function is-container() {
	[[ -f /.dockerenv || -f /run/.containerenv ]] && return 0
	[[ -n "${IN_DOCKER:-}" || -n "${DOCKER_CONTAINER:-}" ]] && return 0
	[[ "${IS_DOCKER:-false}" == true ]]
}

# True in an AI-agent shell (Codex), which wants a minimal, quiet config.
function is-agent-shell() {
	[[ "${IS_CODEX:-false}" == true ]] && return 0
	[[ -n "${CODEX_CI:-}" || -n "${CODEX_THREAD_ID:-}" ]] && return 0
	[[ "${__CFBundleIdentifier:-}" == "com.openai.codex" ]]
}

# True in an IDE-embedded terminal.
function is-ide-shell() {
	[[ "${TERM_PROGRAM:-}" == "vscode" ]]
}

# ============================================================================ #
# NOTE: PROFILE RESOLUTION
# ============================================================================ #

# Resolves which profile this shell should load, setting $ZENV and
# $ZENV_RESOLVED_BY. Precedence, highest first:
#
#   1. $ZENV_FORCE             — explicit override (CI, docker images,
#                                `ZENV_FORCE=server-linux zsh` for testing)
#   2. agent shell (Codex)
#   3. IDE terminal (VS Code)
#   4. container
#   5. .env flags — IS_HOME, IS_OFFICE, IS_SERVER
#   6. OS-based fallback
#
# The override deliberately reads ZENV_FORCE and *not* ZENV: ZENV is exported,
# so honouring it would make every nested shell inherit its parent's answer —
# a VS Code terminal opened from a normal shell would never resolve to `vscode`.
#
# Sets globals rather than printing, because `x=$(determine-environment)` runs
# in a subshell where $ZENV_RESOLVED_BY would be discarded.
#
# Emits nothing: `core/` is a settings layer and must not write to the terminal.
# A fallback resolution is not an error, but it does mean the machine has no
# .env flags set — surfacing that is the splash's job, not this function's.
function determine-environment() {
	if [[ -n "${ZENV_FORCE:-}" ]]; then
		typeset -g ZENV="$ZENV_FORCE" ZENV_RESOLVED_BY=forced
		return 0
	fi

	if is-agent-shell; then
		typeset -g ZENV=codex ZENV_RESOLVED_BY=agent
		return 0
	fi

	if is-ide-shell; then
		typeset -g ZENV=vscode ZENV_RESOLVED_BY=ide
		return 0
	fi

	if is-container; then
		typeset -g ZENV=docker-dev ZENV_RESOLVED_BY=container
		return 0
	fi

	if [[ "${IS_HOME:-false}" == true ]]; then
		typeset -g ZENV=home-macos ZENV_RESOLVED_BY=flags
		return 0
	fi
	if [[ "${IS_OFFICE:-false}" == true ]]; then
		typeset -g ZENV=office-macos ZENV_RESOLVED_BY=flags
		return 0
	fi
	if [[ "${IS_SERVER:-false}" == true ]]; then
		typeset -g ZENV=apnaes ZENV_RESOLVED_BY=flags
		return 0
	fi

	# No flags set. Pick by OS rather than silently assuming this is the
	# author's home Mac — a stranger's machine is not.
	typeset -g ZENV_RESOLVED_BY=fallback
	case "${OS_NAME:-}" in
	Android) typeset -g ZENV=android ;;
	macOS) typeset -g ZENV=home-macos ;;
	*) typeset -g ZENV=home-linux ;;
	esac
}
