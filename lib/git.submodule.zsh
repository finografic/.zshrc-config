# ========================================================================= #
# SUBMODULE OPERATIONS
# ========================================================================= #

# Safely push submodule changes and update parent repository
_gps() {
  # Check if inside a git repository
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a git repository."
    return 1
  fi

  # Get parent repository path
  local PARENT_REPO=$(git rev-parse --show-superproject-working-tree)
  if [ -z "$PARENT_REPO" ]; then
    echo "⚠️  Warning: This doesn't appear to be a submodule."
    echo "Are you sure you want to continue? (Y/n)"
    read -r response
    response=${response:-Y}
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      echo "Aborted."
      return 1
    fi
  fi

  # Get current branch (should be master for submodules)
  local CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  if [ "$CURRENT_BRANCH" != "master" ]; then
    echo "⚠️  Warning: You're not on master branch (current: $CURRENT_BRANCH)"
    echo "Submodules typically use master branch. Continue? (Y/n)"
    read -r response
    response=${response:-Y}
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      echo "Aborted."
      return 1
    fi
  fi

  # Check for uncommitted changes
  if ! git diff-index --quiet HEAD --; then
    echo "⚠️  You have uncommitted changes. Commit them first."
    return 1
  fi

  # Push submodule changes
  echo "📦 Pushing submodule changes to origin master..."
  if ! git push origin master; then
    echo "❌ Submodule push failed!"
    return 1
  fi
  echo "✅ Submodule push successful!"

  # If this is a submodule, update parent repository
  if [ -n "$PARENT_REPO" ]; then
    echo -e "\n🔄 Updating parent repository..."

    # Store current path
    local SUBMODULE_PATH=$(git rev-parse --show-prefix)

    # Change to parent repository
    cd "$PARENT_REPO"

    # Add submodule changes
    git add "${SUBMODULE_PATH}"

    # Check if there are changes to commit
    if git diff --cached --quiet; then
      echo "ℹ️  No changes to commit in parent repository"
    else
      # Commit and push if there are changes
      if git commit -m "chore: update eslint-config submodule"; then
        echo "✅ Parent repository commit successful!"

        # Push parent repository changes
        echo -e "\n🚀 Pushing parent repository changes..."
        if git push; then
          echo "✅ Parent repository push successful!"
        else
          echo "❌ Parent repository push failed!"
          return 1
        fi
      else
        echo "❌ Parent repository commit failed!"
        return 1
      fi
    fi
  fi

  echo -e "\n✨ All done! Both submodule and parent repository are up to date."
}
