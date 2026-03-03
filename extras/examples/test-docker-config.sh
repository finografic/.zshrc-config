#!/bin/zsh

# Test script to verify Docker container detection and configuration loading
# Run this inside a container to test the setup

set -e

echo "🧪 Testing Docker Container Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

pass=0
fail=0

# Test function
test_check() {
  local name="$1"
  local condition="$2"

  if eval "$condition"; then
    echo "${GREEN}✓${NC} $name"
    ((pass++))
  else
    echo "${RED}✗${NC} $name"
    ((fail++))
  fi
}

# Run tests
echo "${BLUE}Environment Detection:${NC}"
test_check "Docker container detected" "[[ -f /.dockerenv ]] || [[ -n \$DOCKER_CONTAINER ]]"
test_check "DOCKER_CONTAINER is set" "[[ -n \$DOCKER_CONTAINER ]]"
test_check "IN_DOCKER is set" "[[ -n \$IN_DOCKER ]]"
test_check "ZENV is docker-container" "[[ \$ZENV == 'docker-container' ]]"
echo ""

echo "${BLUE}Configuration:${NC}"
test_check "ZSHRC_ROOT is set" "[[ -n \$ZSHRC_ROOT ]]"
test_check "Config directory exists" "[[ -d \$ZSHRC_ROOT ]]"
test_check "ZSHRC_PLATFORM is linux" "[[ \$ZSHRC_PLATFORM == 'linux' ]]"
test_check "SKIP_HARDWARE_DETECT is set" "[[ -n \$SKIP_HARDWARE_DETECT ]]"
echo ""

echo "${BLUE}Required Files:${NC}"
test_check "main.zsh exists" "[[ -f \$ZSHRC_ROOT/main.zsh ]]"
test_check "docker-container.zsh exists" "[[ -f \$ZSHRC_ROOT/_zenvs/docker-container/docker-container.zsh ]]"
test_check "colors.zsh loaded" "typeset -f colors >/dev/null 2>&1 || [[ -n \$_g ]]"
test_check "utils.zsh loaded" "typeset -f flatten_PATH >/dev/null 2>&1"
echo ""

echo "${BLUE}Git Configuration:${NC}"
test_check "Git functions loaded" "typeset -f gst >/dev/null 2>&1 || typeset -f git_status >/dev/null 2>&1"
echo ""

echo "${BLUE}Shell Environment:${NC}"
test_check "Shell is zsh" "[[ \$SHELL == *zsh* ]] || [[ -n \$ZSH_VERSION ]]"
test_check "Prompt is set" "[[ -n \$PROMPT ]]"
test_check "PATH is set" "[[ -n \$PATH ]]"
echo ""

echo "${BLUE}Optional Features:${NC}"
test_check "Workspace directory exists" "[[ -d /workspace ]]"
command -v fzf >/dev/null 2>&1 && test_check "FZF available" "command -v fzf >/dev/null 2>&1" || echo "${YELLOW}⊘${NC} FZF not installed (optional)"
command -v git >/dev/null 2>&1 && test_check "Git available" "command -v git >/dev/null 2>&1" || echo "${YELLOW}⊘${NC} Git not installed"
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${GREEN}Passed: $pass${NC}"
if [[ $fail -gt 0 ]]; then
  echo "${RED}Failed: $fail${NC}"
fi
echo ""

if [[ $fail -eq 0 ]]; then
  echo "${GREEN}✓ All tests passed! Docker container configuration is working correctly.${NC}"
  exit 0
else
  echo "${RED}✗ Some tests failed. Please check the configuration.${NC}"
  exit 1
fi
