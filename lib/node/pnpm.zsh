# ============================================================================ #
# NOTE: PNPM / NPM helpers (non-cleaning)
# Usage: pn <args> | pnr <pkg> | npmls
# ============================================================================ #

alias npmls="npm ls -g --depth=0"

# Enhanced PNPM wrapper with GitHub auth / NPM_TOKEN handling
function pn() {
	local root_dir
	local current_dir="$PWD"

	# Find the root directory (where package.json exists)
	while [[ "$PWD" != "/" ]]; do
		if [[ -f "package.json" ]]; then
			root_dir="$PWD"
			break
		fi
		cd ..
	done
	cd "$current_dir"

	# If no package.json found in parent directories
	if [[ -z "$root_dir" ]]; then
		root_dir="$current_dir"
	fi

	# Check for GitHub authentication needs
	local needs_github=false
	if [[ -f "$root_dir/.npmrc" ]]; then
		if grep -q "@finografic:registry=https://npm.pkg.github.com" "$root_dir/.npmrc"; then
			needs_github=true
		fi
	fi

	# Handle GitHub authentication if needed
	if [[ "$needs_github" == true ]]; then
		# Try to load NPM_TOKEN from .env
		if [[ -f "$root_dir/.env" ]]; then
			export NPM_TOKEN=$(awk -F= '/^NPM_TOKEN=/ {print $2; exit}' "$root_dir/.env" 2>/dev/null)
		fi

		# Check if we have authentication (either via .netrc or NPM_TOKEN)
		if [[ ! -f "$HOME/.netrc" ]] && [[ -z "$NPM_TOKEN" ]]; then
			echo "⚠️  Warning: No GitHub authentication found"
			echo "Please either:"
			echo "  1. Run 'npm login --scope=@finografic --registry=https://npm.pkg.github.com'"
			echo "  2. Set up .netrc file"
			echo "  3. Provide NPM_TOKEN in .env file"
			return 1
		fi
	fi

	# Execute pnpm with all arguments
	if [[ "$needs_github" == true ]] && [[ -n "$NPM_TOKEN" ]]; then
		NPM_TOKEN=$NPM_TOKEN pnpm "$@"
	else
		pnpm "$@"
	fi
}

function pnr() {
	pn remove "$@"
}
