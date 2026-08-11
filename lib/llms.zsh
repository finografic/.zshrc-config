(( ${+_ZSHRC_LLMS_LOADED} )) && return 0
typeset -g _ZSHRC_LLMS_LOADED=1

# Best-effort AI-drafted commit message, from the pending diff, via a local
# Ollama model (`zconf message`). Trial basis — silently unavailable (both
# outputs empty, non-zero return) when Node/the build/Ollama itself aren't
# there, so callers just check for output rather than parsing errors.
# OLLAMA_HOST/OLLAMA_DEFAULT_MODEL are forwarded explicitly: .env is exported
# (see core/env.zsh) but this may run from a non-interactive subshell that
# never sourced it, so the values are passed through the environment as-is.
#
# Sets $ollama_commit_message/$ollama_commit_meta directly (the latter a
# "model  123ms" line from `zconf message`'s stderr) rather than printing
# them — this must be called plainly, NOT as `x="$(ollama-commit-message)"`,
# because command substitution forks a subshell in zsh and these assignments
# would never reach the caller.
#
# Shared by `zupdate` (update-config.zsh) and `_gcai` (lib/git/git.commit.zsh).
function ollama-commit-message() {
  ollama_commit_message=''
  ollama_commit_meta=''
  command -v node > /dev/null 2>&1 || return 1
  [[ -f "$ZSHRC_ROOT/packages/zconf/dist/index.js" ]] || return 1

  local err_file exit_code
  err_file="$(mktemp "${TMPDIR:-/tmp}/ollama-commit-message-err.XXXXXX")"
  ollama_commit_message="$(OLLAMA_HOST="${OLLAMA_HOST:-}" OLLAMA_DEFAULT_MODEL="${OLLAMA_DEFAULT_MODEL:-}" \
    node "$ZSHRC_ROOT/packages/zconf/dist/index.js" message 2> "$err_file")"
  exit_code=$?
  ollama_commit_meta="$(< "$err_file")"
  rm -f "$err_file"

  if (( exit_code != 0 )) || [[ -z "$ollama_commit_message" ]]; then
    ollama_commit_message=''
    return 1
  fi
}

# Grey provenance line shown BELOW a drafted commit message: model and latency, bullet
# separated. Reads $ollama_commit_meta ("model  123ms", two spaces) as set by
# `ollama-commit-message`, and prints nothing at all when it is empty.
#
# Unlike `ollama-commit-message` this DOES print rather than assign, so it is meant to be
# called as `$(ollama-commit-meta-line)` — nothing needs to reach the caller but stdout.
#
# Shared by `_gcai` (lib/git/git.commit.zsh) and `zupdate` (update-config.zsh) so both
# render identically.
function ollama-commit-meta-line() {
  [[ -n "$ollama_commit_meta" ]] || return 0

  local model="${ollama_commit_meta%% *}"
  local latency="${ollama_commit_meta##* }"

  # NOT `print -r`: colors.zsh stores literal "\033[..." strings, so the escapes have to be
  # interpreted here now that this prints directly rather than through a caller's echo.
  print -- "${_grey}${model} • ${latency}${_0}"
}

function ollama-default-model() {
  print -r -- "${1:-${OLLAMA_DEFAULT_MODEL:-gemma4:e4b-it-qat}}"
}

function ollama-model-loaded() {
  local model host body
  model="$(ollama-default-model "$1")"
  host="${OLLAMA_HOST:-http://localhost:11434}"

  command -v curl >/dev/null 2>&1 || return 1
  body="$(curl -fsS "$host/api/ps" 2>/dev/null)" || return 1
  print -r -- "$body" | grep -Fq "\"model\":\"$model\"" || \
    print -r -- "$body" | grep -Fq "\"name\":\"$model\""
}

function should-preload-ollama() {
  local model stamp now last
  model="$(ollama-default-model "$1")"
  stamp="${TMPDIR:-/tmp}/zshrc-ollama-preload-${model//[:\/]/_}"
  now="$(date +%s)"
  last="$(< "$stamp" 2>/dev/null || print 0)"

  (( now - last > 300 )) || return 1
  print -r -- "$now" > "$stamp"
}

function ollama-preload-default-model() {
  local model host keep_alive
  model="$(ollama-default-model "$1")"
  host="${OLLAMA_HOST:-http://localhost:11434}"
  keep_alive="${OLLAMA_KEEP_ALIVE:-30m}"

  command -v curl >/dev/null 2>&1 || return 1
  ollama-model-loaded "$model" && return 0
  should-preload-ollama "$model" || return 0

  curl -fsS "$host/api/generate" \
    -d "{\"model\":\"$model\",\"keep_alive\":\"$keep_alive\"}" >/dev/null 2>&1
}

function ollama-unload-default-model() {
  local model host
  model="$(ollama-default-model "$1")"
  host="${OLLAMA_HOST:-http://localhost:11434}"

  command -v curl >/dev/null 2>&1 || return 1
  curl -fsS "$host/api/generate" \
    -d "{\"model\":\"$model\",\"keep_alive\":0}" >/dev/null
}

function ollama-reset-check() {
  local models_dir="/Volumes/SSD.DEV/.ollama/models"

  echo ""
  echo "=== Ollama status ==="
  echo ""

  echo "CLI:"
  command -v ollama
  ollama --version 2>/dev/null || echo "ollama CLI not available"

  echo ""
  echo "OLLAMA env:"
  echo "shell OLLAMA_MODELS: ${OLLAMA_MODELS:-<empty>}"
  echo "launchctl OLLAMA_MODELS: $(launchctl getenv OLLAMA_MODELS 2>/dev/null || echo '<empty>')"
  echo "OLLAMA_HOST: ${OLLAMA_HOST:-<empty>}"

  echo ""
  echo "Running processes:"
  ps aux | grep -i '[o]llama' || echo "No Ollama process found"

  echo ""
  echo "API tags:"
  curl -s http://127.0.0.1:11434/api/tags 2>/dev/null || echo "Ollama API not responding"

  echo ""
  echo "Expected model dir:"
  echo "$models_dir"

  echo ""
  echo "Model dir exists?"
  if [[ -d "$models_dir" ]]; then
    echo "yes"
  else
    echo "NO - missing: $models_dir"
  fi

  echo ""
  echo "SSD manifests:"
  find "$models_dir/manifests" -type f 2>/dev/null | head -20

  echo ""
  echo "Default local manifests:"
  find "$HOME/.ollama/models/manifests" -type f 2>/dev/null | head -20

  echo ""
  echo "Current ollama ls:"
  ollama ls 2>/dev/null || echo "ollama ls failed"

  echo ""
  echo "Set launchctl OLLAMA_MODELS to:"
  echo "$models_dir"
  echo ""
  echo "Then kill/restart Ollama app? [y/N]"

  read -r reply

  case "$reply" in
  [yY] | [yY][eE][sS])
    echo ""
    echo "Setting launchctl environment..."
    launchctl setenv OLLAMA_MODELS "$models_dir"

    echo "Stopping Ollama..."
    pkill Ollama 2>/dev/null
    pkill ollama 2>/dev/null

    sleep 2

    echo "Starting Ollama app..."
    open -a Ollama

    echo ""
    echo "Waiting for API..."
    sleep 3

    echo ""
    echo "New ollama ls:"
    ollama ls
    ;;
  *)
    echo "No changes made."
    ;;
  esac
}
