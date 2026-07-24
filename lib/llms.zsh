ollama-reset-check() {
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
