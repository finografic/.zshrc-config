#!/bin/zsh
# ============================================================================ #
# UPDATE-CONFIG - Commit and push zshrc-config updates (safe multi-system flow)
# ============================================================================ #

# Usage: Run from repo root (e.g. via zupdate from ~/bin)
# Flow: fetch → add → commit (if changes) → pull --rebase → push
# ============================================================================ #

set -e

# Fetch latest from remote (no merge, just updates refs)
git fetch origin

# Stage all changes
git add .

# Commit only if there are staged changes
if ! git diff --staged --quiet; then
  git commit -m "updated from: ${ZENV:-$(hostname)}"
fi

# Rebase our commits on top of remote (avoids merge commits when pushing from other systems)
git pull --rebase origin

# Push to remote
git push origin
