if [ $IS_HOME = true ]; then
  # NOTE: HOME: (macOS)

  # pnpm
  export PNPM_HOME="$HOME/Library/pnpm"
  case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
  esac
  # pnpm end
elif [ $IS_OFFICE = true ]; then
  # NOTE: OFFICE: (macOS)
else
  # DEFAULT..
fi
