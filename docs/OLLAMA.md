# Ollama Local AI Setup

Local AI models running locally for private, offline development assistance. No cloud, no
API keys, no data leaving your machine.

```
Ollama.app (Server: localhost:11434)
├── Model: llama3:latest (4.3GB)
├── Model: gpt-oss:20b (12.8GB)
└── Serves multiple clients:
    ├── Continue Extension (Cursor IDE)
    ├── Terminal: ollama-test script
    └── Any tool connecting to localhost:11434
```

## Setup

### Prerequisites

- Ollama.app installed and running
- Continue Extension installed in Cursor (or equivalent IDE integration)
- Node 18+ (for the `ollama-test` script)

### Quick start

1. Start Ollama.app (leave running in background).
2. Open Cursor -> the Continue panel opens automatically.
3. Start chatting with the local `llama3:latest` model.

## Usage

### Continue Extension (recommended for development)

Click the Continue panel in your IDE, type a question, get a response. Best for code
generation, refactoring suggestions, documentation, and real-time IDE assistance.

### Terminal script

```sh
# Quick test
ollama-test "Explain Node.js modules"

# With a specific model
ollama-test --model gpt-oss:20b "Generate TypeScript interface"

# List available models
ollama-test --list

# Check Ollama status
ollama-test --check
```

Best for scripting/automation, batch processing, CI/CD, and offline analysis.

## Configuration

- **Server:** `http://localhost:11434`
- **Default model:** `llama3:latest`
- **Alternative model:** `gpt-oss:20b`
- **Config:** `~/.continue/config.yaml`

## Troubleshooting

- **Cannot reach Ollama:** `ollama-test --check`; confirm Ollama.app is running; check
  `lsof -i :11434`.
- **Model not found:** `ollama-test --list`; download the model via Ollama.app.
- **Slow responses:** first run is slower while the model loads; try a smaller model.

## Resources

- [Ollama](https://ollama.ai)
- [Continue.dev](https://continue.dev)
