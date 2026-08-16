# ============================================================================ #
# NOTE: CORE PROFILE - Declarative profile manifest loader
#
# A profile says WHAT it wants; this file works out HOW. Definitions only —
# sourcing is inert, `zenv-load` does the work.
#
# A profile manifest looks like:
#
#   ZENV_PRESET=full                      # full | minimal | container | none
#   ZENV_MODULES=(git dev node llms macos)
#   ZENV_FEATURES=(aliases dev paths)
#   ZENV_OPT_IN=(music/backup-dj-crate)
#   zenv-load
#
# Modules resolve to `lib/` barrels, features to `$ZENV_PATH/$ZENV.<name>.zsh`,
# opt-ins to `extras/<path>.zsh`.
#
# Two things this deliberately owns rather than trusting profiles with:
#   - Load ORDER. Modules are sourced in the canonical order below, not in
#     whatever order a profile happened to list them. colors must precede
#     anything using ${_c}; nvm must precede lib/node.zsh.
#   - The nvm invariant. `lib/node/nvm-autoload.zsh` silently no-ops if
#     `nvm_find_nvmrc` doesn't exist yet, so vendor/nvm.zsh has to be sourced
#     first. Three profiles previously hand-rolled this, three different ways.
# ============================================================================ #

(( ${+_ZSHRC_PROFILE_LOADED} )) && return 0
typeset -g _ZSHRC_PROFILE_LOADED=1

# ============================================================================ #
# NOTE: REGISTRIES
# ============================================================================ #

# Module name -> path under $ZSHRC_ROOT. An unknown name is an error, not a
# silent skip — a typo'd module should be loud.
typeset -gA ZENV_MODULE_PATHS=(
	[colors]=lib/colors.zsh
	[common]=lib/common.zsh
	[paths]=lib/paths.zsh
	[utils]=lib/utils.zsh
	[disk]=lib/utils/disk.zsh
	[doctor]=lib/doctor.zsh
	[fzf]=lib/fzf.zsh
	[git]=lib/git.zsh
	[node]=lib/node.zsh
	[dev]=lib/dev.zsh
	[llms]=lib/llms.zsh
	[clean]=lib/clean.zsh
	[macos]=lib/macos.zsh
	[ghostty]=lib/ghostty.zsh
	[splash]=lib/splash.zsh
	[zconf]=lib/zconf.zsh
)

# Canonical source order. Anything requested is sourced in THIS order, not the
# order the profile listed it. Names not in a profile's list are skipped.
typeset -ga ZENV_MODULE_ORDER=(
	colors
	paths
	common
	utils
	disk
	doctor
	fzf
	git
	node
	dev
	llms
	clean
	macos
	ghostty
	splash
	zconf
)

# Presets. A profile's own ZENV_MODULES/ZENV_FEATURES are merged on top.
#   full      — an interactive terminal on a personal machine
#   minimal   — IDE/agent shells: fast, quiet, still useful for dev
#   container — minimal minus anything macOS or host-specific
# Two deliberate absences:
#   `splash` (lib/splash.zsh, formerly lib/widgets.zsh) — main-splash.zsh
#     sources it directly and is its only consumer; listing it here would
#     double-source.
#   `ghostty` — hardcodes a macOS config path, so it is not OS-agnostic enough
#     for `full`. The macOS profiles list it explicitly.
# Both stay in the registry so a profile can still ask for them.
typeset -gA ZENV_PRESET_MODULES=(
	[full]="colors paths common utils disk doctor fzf git node dev clean zconf"
	[minimal]="colors git node dev"
	[container]="colors utils git node dev"
	[none]=""
)

# ============================================================================ #
# NOTE: VALIDATION
# ============================================================================ #

# Checks a manifest without loading anything. Returns non-zero and explains on
# stderr if a name is unknown or a target file is missing. Used by `zenv-load`
# and reusable by `zconf doctor` (P5.2).
function zenv-validate() {
	local -a modules features
	local name path errors=0

	modules=(${(z)1})
	features=(${(z)2})

	for name in $modules; do
		if [[ -z "${ZENV_MODULE_PATHS[$name]}" ]]; then
			print "zenv: unknown module '$name' (known: ${(ko)ZENV_MODULE_PATHS})" >&2
			(( errors++ ))
			continue
		fi
		path="$ZSHRC_ROOT/${ZENV_MODULE_PATHS[$name]}"
		if [[ ! -r "$path" ]]; then
			print "zenv: module '$name' -> missing file $path" >&2
			(( errors++ ))
		fi
	done

	for name in $features; do
		path="$ZENV_PATH/${ZENV}.${name}.zsh"
		if [[ ! -r "$path" ]]; then
			print "zenv: feature '$name' -> missing file $path" >&2
			(( errors++ ))
		fi
	done

	(( errors == 0 ))
}

# ============================================================================ #
# NOTE: RESOLUTION
# ============================================================================ #

# Sources a file with an EMPTY positional parameter list.
#
# `source file` (with no trailing args) does not clear $@ — the sourced file
# inherits the caller's positional parameters. Since every loader function here
# takes its work list as "$1", a naive `source "$path"` would hand each sourced
# file a $1 of e.g. "music/backup-dj-crate music/djay_icloud_sync". Any script
# that inspects $1 at source time then acts on garbage.
#
# `shift` after capturing the path leaves $@ empty for the sourced file, which
# is what a config module should see. Real case this protects:
# extras/music/djay_icloud_sync.zsh has a `case "${1:-sync}"` CLI dispatcher at
# the bottom, guarded on $ZSH_EVAL_CONTEXT. In a real interactive shell that
# guard happens not to match, so the bug stayed latent — but it fires in any
# context where ZSH_EVAL_CONTEXT starts with "toplevel" (a plain `zsh script.zsh`
# harness, for instance), where it would print a usage error and `exit 1`.
function zenv-source() {
	local __zenv_path="$1"
	shift
	source "$__zenv_path"
}

# Sources the requested `lib/` barrels in canonical order, honouring the nvm
# load-order invariant. Takes a space-separated list of module names.
function zenv-modules() {
	local -a requested
	requested=(${(z)1})

	local name
	for name in $ZENV_MODULE_ORDER; do
		(( ${requested[(I)$name]} )) || continue

		# `node` is the one module with a mandatory boot sequence around it.
		# vscode, codex and docker-dev each hand-rolled this, three slightly
		# different ways; it lives here now so it cannot be got wrong.
		if [[ "$name" == node ]]; then
			# nvm must be initialised BEFORE lib/node.zsh: nvm-autoload
			# early-returns (silently) if nvm_find_nvmrc doesn't exist yet.
			[[ "${NVM:-false}" == true ]] && zenv-source "$ZSHRC_ROOT/vendor/nvm.zsh"
			# pnpm PATH / PNPM_HOME — sourced AFTER nvm.zsh on purpose: nvm.zsh
			# prepends $NVM_BIN to PATH (lazy-path `path=("$NVM_BIN" $path)`
			# and the eager fallback both do this), and an NVM Node version's
			# bin/ can itself contain a pnpm (npm-installed, or a Corepack
			# shim). Sourcing pnpm-path.zsh last means its prepend of
			# $PNPM_HOME/bin lands in front of $NVM_BIN, so pnpm's own
			# self-managed binary (`pnpm self-update`) always wins instead of
			# whatever happens to be sitting in the active Node version's bin/.
			zenv-source "$ZSHRC_ROOT/vendor/pnpm-path.zsh"
		fi

		zenv-source "$ZSHRC_ROOT/${ZENV_MODULE_PATHS[$name]}"

		# Activate .nvmrc auto-switching once the barrel has defined it.
		if [[ "$name" == node ]]; then
			(( $+functions[nvm-autoload-init] )) && nvm-autoload-init
		fi
	done
}

# Sources profile-local feature files: $ZENV_PATH/$ZENV.<name>.zsh, in the
# order the profile listed them (these are the profile's own business).
function zenv-features() {
	local -a requested
	requested=(${(z)1})

	local name
	for name in $requested; do
		zenv-source "$ZENV_PATH/${ZENV}.${name}.zsh"
	done
}

# Sources opt-in extras: extras/<path>.zsh. Never implied by a preset.
function zenv-opt-in() {
	local -a requested
	requested=(${(z)1})

	local name path
	for name in $requested; do
		path="$ZSHRC_ROOT/extras/${name}.zsh"
		if [[ -r "$path" ]]; then
			zenv-source "$path"
		else
			print "zenv: opt-in '$name' -> missing file $path" >&2
		fi
	done
}

# ============================================================================ #
# NOTE: ENTRY POINT
# ============================================================================ #

# Resolves and loads the manifest declared by the calling profile. Reads
# ZENV_PRESET, ZENV_MODULES, ZENV_FEATURES, ZENV_OPT_IN from the caller's scope.
function zenv-load() {
	local preset="${ZENV_PRESET:-none}"

	if [[ -z "${ZENV_PRESET_MODULES[$preset]+x}" ]]; then
		print "zenv: unknown preset '$preset' (known: ${(ko)ZENV_PRESET_MODULES})" >&2
		return 1
	fi

	# Preset modules first, then the profile's additions, de-duplicated while
	# preserving the canonical order applied in zenv-modules.
	# NOTE: not named `modules` — that is a special read-only parameter once
	# zsh/parameter is loaded (p10k loads it), and the collision is avoidable.
	local -a resolved_modules resolved_features
	resolved_modules=(${=ZENV_PRESET_MODULES[$preset]} ${ZENV_MODULES[@]})
	resolved_modules=(${(u)resolved_modules})
	resolved_features=(${ZENV_FEATURES[@]})

	zenv-validate "${resolved_modules[*]}" "${resolved_features[*]}" || return 1

	zenv-modules "${resolved_modules[*]}"
	zenv-features "${resolved_features[*]}"
	(( ${#ZENV_OPT_IN} )) && zenv-opt-in "${ZENV_OPT_IN[*]}"

	return 0
}
