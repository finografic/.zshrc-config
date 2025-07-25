#!/bin/zsh

# Colors for better visualization
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Monitor backup, thermal, and disk activity
while true; do
  clear
  echo "${CYAN}=== Time Machine Status ===${NC}"
  tmutil status
  echo ""

  echo "${YELLOW}=== NVMe Drive Activity (disk6) ===${NC}"
  iostat -d 1 1 disk6 | tail -n +3
  echo ""

  echo "${MAGENTA}=== System Thermal State ===${NC}"
  pmset -g thermlog | tail -5
  echo ""

  echo "${GREEN}Press Ctrl+C to stop monitoring${NC}"
  echo "${WHITE}Next update in 10 seconds...${NC}"
  sleep 10
done
