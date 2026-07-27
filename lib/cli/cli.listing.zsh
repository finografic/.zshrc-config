# ============================================================================ #
# FILE LISTINGS
# ============================================================================ #

source "$ZSHRC_ROOT/lib/colors.zsh"

# CORE
alias ls="ls -lAh"
alias ll="ls -la --color -h --group-directories-first"
alias l="ls -lAh" # TODO: replace with `k`

# ENHANCED FOLDER LISTINGS
alias llh="ls -ld .?*" # list hidden

# subl $(dirname $(gem which colorls))/yaml
alias lc="colorls -lA --sort-dirs --git-status --report && echo \n" # RUBY GEM ls w/ icons :D

# LIST PERMISSIONS -- HOW TO ADD COLOR ??
alias lp="stat -c '%A  %a  %U:%G  ___  %n' *" # SIMPLE

function listing() {
  k -Ah $1
  [[ -d .git ]] && git status -uno
}

function listing-eza() {
  # eza --long --all --group-directories-first --accessed --time-style=long-iso --git $1
  EZA_IGNORES=".DS_Store|Icon*|.directory"
  eza --long --all --ignore-glob="${EZA_IGNORES}" --group-directories-first --accessed --time-style=long-iso --git $1
  [[ -d .git ]] && git status -uno

  if (( ${+functions[is-git-root]} )) && (( ${+functions[ollama-preload-default-model]} )) && is-git-root; then
    ollama-preload-default-model >/dev/null 2>&1 &!
  fi
}

function lr() {
  k -rAth
}

# DEFAULT MAIN DIRECTORY LISTERS
alias l="listing-eza"
alias l2="listing"
# alias ls="eval `dircolors -b ${HOME}/.dircolors` && ls -Alh --color" # list hidden

# Recently-modified files in the CURRENT directory.
# NOTE: single-quoted on purpose. Double quotes expanded `$(pwd)` when this file
# was SOURCED, baking the shell's startup directory into the alias for its whole
# life — `lr` then listed that directory no matter where you ran it, and spawned
# a `pwd` process on every shell start to do it. Same class of bug as the old
# `alias vim="${EDITOR} $@"`.
alias lr='find "$(pwd)" -maxdepth 1 -mtime -1 -ls'

# ============================================================================ #
# TREE LISTING
# ============================================================================ #

alias t="eza --tree --group-directories-first --level 2"
alias t2="tree --dirsfirst -L 2"

# Homebrew tree; inside a git work tree, respect .gitignore (hides node_modules, etc.)
function tree() {
	local tree_bin="/opt/homebrew/bin/tree"
	if [[ ! -x "$tree_bin" ]]; then
		tree_bin="$(command -v tree)"
	fi
	if [[ -z "$tree_bin" ]]; then
		echo "\n${_y}⚠️  tree not found${_0}\n"
		return 1
	fi

	if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		"$tree_bin" --gitignore "$@"
	else
		"$tree_bin" "$@"
	fi
}

# NEW (2026-01) — pure-find fallback tree (no gitignore)
function tree2() {
	find . | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"
}
