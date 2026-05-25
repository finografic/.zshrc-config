#########################################
#########  CLEAN node_modules  ##########
#########################################

# ------------------------------------------------------------------------- #
# Recursively remove all `node_modules` directories from a given path.
# ------------------------------------------------------------------------- #

# NOTE: V1 ORIG (faster, no sudo)

_clean_node_modules() {
  local size_before size_after space_saved

  # Get size before cleaning (in MB)
  size_before=$(du -sm . 2>/dev/null | awk '{print $1}')

  # Find and delete all node_modules folders recursively
  # Using -prune to prevent descending into node_modules before deletion
  find . -type d -name "node_modules" -prune -exec rm -rf {} +

  # Get size after cleaning (in MB)
  size_after=$(du -sm . 2>/dev/null | awk '{print $1}')

  # Calculate space saved
  space_saved=$((size_before - size_after))

  # Output results
  echo ""
  echo "${_grey}Before clean: ${size_before} MB${_0}"
  echo "${_grey}After clean:  ${size_after} MB${_0}"
  echo "${_g}Space saved:  ${space_saved} MB${_0}"
}

# alias _cnm="_clean_node_modules"

# NEW: V2 -- USING THIS ONE !!
# DELETE ALL node_modules RECURSIVELY
# Options: --dry-run  (list targets and sizes only; no rm)
clean-node-modules() {
  local dry_run=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) dry_run=1; shift ;;
      *) break ;;
    esac
  done

  echo "\n${_c}🔍 Finding node_modules directories...${_0}"
  [[ $dry_run -eq 1 ]] && echo "${_w}(dry-run — nothing will be deleted)${_0}\n"

  # --prune: don't descend into node_modules dirs, so nested ones are excluded from results
  # (they get deleted automatically when the parent is removed)
  dirs=($(fd -H -I --prune -t d "^node_modules$"))

  # Track total size and failed deletions
  failed_dirs=()

  # If no directories found
  if [ ${#dirs[@]} -eq 0 ]; then
    echo "${_w}No node_modules directories found.${_0}\n"
    return 0
  fi

  # Show total count
  echo "${_y}Found ${#dirs[@]} node_modules directories.${_0}\n"

  # Process each directory
  for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
      # Get size before deletion attempt
      size=$(du -sh "$dir" 2>/dev/null | cut -f1)
      size_bytes=$(du -s "$dir" 2>/dev/null | cut -f1)

      if [ ! -z "$size" ]; then
        if [[ $dry_run -eq 1 ]]; then
          echo "\n${_grey}🔎 Would remove $dir (size: $size)${_0}\n"
          continue
        fi

        echo "\n${_grey}🗑️  Removing $dir (size: $size)${_0}\n"

        # Try to remove with sudo if normal remove fails
        if ! rm -rf "$dir" 2>/dev/null; then
          echo "${_y}⚠️  Permission denied, trying with sudo...${_0}"
          sudo rm -rf "$dir" || {
            echo "${_r}❌ Failed to remove: $dir${_0}"
            failed_dirs+=("$dir")
          }
        fi
      fi
    fi
  done

  # Final summary
  if [[ $dry_run -eq 1 ]]; then
    echo "\n${_g}✨ Dry run finished — no directories were removed.${_0}\n"
  else
    echo "\n${_g}✨ Cleanup complete!${_0}\n"
  fi

  # Report any failures
  if [ ${#failed_dirs[@]} -gt 0 ]; then
    echo "\n${_y}Warning: The following directories had permission issues:${_0}"
    for failed in "${failed_dirs[@]}"; do
      echo "${_r}  - $failed${_0}"
    done
    echo "${_y}You might need to remove these manually with sudo${_0}"
  fi
}


# Wrapper: measure disk usage before and after running the cleaner
clean-node-modules-report() {
  local dry_run=0 _
  for _ in "$@"; do [[ "$_" == "--dry-run" ]] && dry_run=1; done

  # Compute size in kilobytes, fallback to 0
  SIZE_A_KB=$(du -sk . 2>/dev/null | awk '{print $1+0}')
  SIZE_A=$(awk "BEGIN{printf \"%.1f\", (${SIZE_A_KB:-0})/1024}")

  # Run the existing cleaner (allow passing options/args)
  clean-node-modules "$@"

  # Recompute size after cleanup
  SIZE_B_KB=$(du -sk . 2>/dev/null | awk '{print $1+0}')
  SIZE_B=$(awk "BEGIN{printf \"%.1f\", (${SIZE_B_KB:-0})/1024}")

  # Compute saved (may be negative if size increased)
  SAVED=$(awk "BEGIN{printf \"%.1f\", (${SIZE_A} - ${SIZE_B})}")

  # Output results with colours
  echo "${_grey}before clean: ${SIZE_A} MB${_0}"
  echo "${_grey}after clean: ${SIZE_B} MB${_0}"
  echo "${_g}space saved: ${SAVED} MB${_0}"
  [[ $dry_run -eq 1 ]] && echo "${_w}(dry run — disk usage should match above)${_0}"

  # Export variables for interactive inspection
  export SIZE_A SIZE_B SAVED
}

alias _cnm="clean-node-modules-report"
