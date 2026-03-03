#!/bin/zsh

# Helper script to quickly run a Docker container with host zshrc-config
# Usage: ./run-docker-zsh.sh [image-name] [workspace-dir]

set -e

# Default values
IMAGE_NAME="${1:-ubuntu:22.04}"
WORKSPACE_DIR="${2:-$(pwd)}"
CONTAINER_NAME="zsh-dev-$(date +%s)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "${BLUE}  Docker Container with Host Zsh Config${NC}"
echo "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "${YELLOW}Image:${NC}      ${IMAGE_NAME}"
echo "${YELLOW}Workspace:${NC}  ${WORKSPACE_DIR}"
echo "${YELLOW}Container:${NC}  ${CONTAINER_NAME}"
echo ""

# Check if zshrc-config exists
if [[ ! -d "$HOME/.zshrc-config" ]]; then
  echo "${RED}✗ Error: ~/.zshrc-config directory not found${NC}"
  echo "${YELLOW}  Please ensure your zshrc-config is at ~/.zshrc-config${NC}"
  exit 1
fi

# Check if .zshrc exists
if [[ ! -f "$HOME/.zshrc" ]]; then
  echo "${YELLOW}⚠ Warning: ~/.zshrc not found. Container will use default config.${NC}"
  ZSHRC_MOUNT=""
else
  ZSHRC_MOUNT="-v $HOME/.zshrc:/root/.zshrc:ro"
fi

echo "${GREEN}✓ Starting container...${NC}"
echo ""

# Run the container
docker run -it --rm \
  --name "${CONTAINER_NAME}" \
  -v "$HOME/.zshrc-config:/root/.zshrc-config:ro" \
  ${ZSHRC_MOUNT} \
  -v "${WORKSPACE_DIR}:/workspace" \
  -e DOCKER_CONTAINER=1 \
  -e IN_DOCKER=1 \
  -e ZSHRC_ROOT=/root/.zshrc-config \
  -e TERM=xterm-256color \
  -w /workspace \
  "${IMAGE_NAME}" \
  zsh -c "
    # Install zsh if not present
    if ! command -v zsh >/dev/null 2>&1; then
      echo '${YELLOW}Installing zsh...${NC}'
      apt-get update -qq && apt-get install -y -qq zsh git curl > /dev/null 2>&1
    fi

    # Start zsh with our config
    exec zsh
  "

echo ""
echo "${GREEN}✓ Container exited${NC}"
