# Conventions

The zsh style rules this repo follows, and why. `pnpm zconf doctor` enforces
most of these statically; this doc is the explanation for a human, not the
lint spec — see `packages/zconf/src/core/rules.ts` for the exact checks.

## Functions: the `function` keyword, kebab-case

```zsh
function clean-node-modules() { ... }   # yes
clean-node-modules() { ... }            # missing the keyword
function clean_node_modules() { ... }   # snake_case
```

A name that already starts with `_` (the `_ga`/`_gb`-style git shorthand
prefix) is exempt from the kebab-case check — the underscore is an
established prefix convention here, not snake_case.

`zconf normalize` will rewrite both violations for you, including every call
site of a renamed function. Vendored code (`vendor/`, `themes/`) is exempt —
it isn't ours to restyle, and doing so would make the next upstream update
harder to diff.

## `[[ ]]`, not `[ ]`

```zsh
[[ -n "$1" ]]           # yes
[ -n "$1" ]             # POSIX test — works, but inconsistent with the rest
[[ $1 > "" ]]           # looks like a non-empty test; is a STRING COMPARISON
```

That last one is a real bug class this repo has hit twice (`_ga`/`_gb` in
`lib/git/`) — `>` inside `[[ ]]` is lexicographic string comparison, not "is
set". Use `[[ -n "$1" ]]`.

Exceptions: `vendor/nvm.zsh` is upstream code, left in its original style.

## No shebang in a sourced-only module

```zsh
# lib/git.zsh — sourced, never executed
# ============================================================================ #
# NOTE: GIT UTILITIES INDEX
# ============================================================================ #

source "$ZSHRC_ROOT/lib/git/git.core.zsh"
```

A shebang implies "run me directly." Files under `lib/`, `core/`, `bootstrap/`,
and `profiles/` are sourced, not executed, and shouldn't carry one — a boxed
`# NOTE:` header instead. `scripts/` is exempt: several of its files are
legitimately dual-use (sourced for their functions, executed for their CLI).

## Comment blocks

```zsh
# ============================================================================ #
# NOTE: SECTION TITLE
#
# Prose explaining the WHY — a subtle invariant, a workaround, something that
# would surprise a reader — can span multiple lines. It stays between the
# rules; only the two rules themselves get rewritten.
# ============================================================================ #
```

78-character boxed equals, top and bottom. `pnpm zconf normalize` applies this
across the whole repo and is idempotent — running it twice makes no further
changes. It preserves multi-line bodies exactly; it will not touch the prose
between two rules of a block.

## Colors: never a local ANSI escape

```zsh
source "$ZSHRC_ROOT/lib/colors.zsh"
print "${_y}warning${_0}"
```

Every module that prints in color sources `lib/colors.zsh` explicitly, even
though it is very likely already loaded — the guard at the top of that file
(`(( ${+_ZSHRC_COLORS_LOADED} )) && return 0`) makes a repeat `source` a single
arithmetic test, not a re-parse. Explicit sourcing means a module documents
its own dependency and still works if you `source` it standalone for testing.
Never hand-roll a raw `\033[...m` escape or a local color variable — that is
how a repo ends up with two different palettes silently drifting apart (a real
bug found in `lib/git/git.tags.zsh`, since fixed).

## `--dry-run`, not `--dry`

Every destructive helper takes `--dry-run`, matching the flag name people
actually expect from other tools, and prints what it _would_ do rather than
doing it.

## Confirm prompts: default last

```zsh
print -n "Proceed? (Y/n) "   # Enter accepts the default
```

Destructive operations without a safe default (deleting branches, a hard
reset) may legitimately have _no_ default — requiring an explicit `y` — rather
than defaulting to proceed.

## `print`/`printf` over `echo -e`

`echo -e`'s behaviour is not portable across shells; `print` is a zsh builtin
with the same escape handling everywhere this config runs.

## The side-effect rule

Sourcing anything under `lib/` must not run anything — no `echo`, no network
call, no file write, no command substitution at the top level. If a module
does work today, that work becomes a named function, and a _profile_ decides
whether to call it. This is `zconf doctor`'s most-checked rule (`lib-side-effect`)
and is proven empirically by `tests/test-lib-inert.zsh`. Full rationale in
`docs/ARCHITECTURE.md`.

## Checking your work

```console
$ pnpm zconf doctor
✔ doctor: clean (119 zsh files, 180 load edges)

$ pnpm zconf normalize --dry-run
✔ normalize: nothing to change (116 files)
```

Run both before committing a change to `lib/`, `core/`, `bootstrap/`, or
`profiles/`. CI runs them too, but catching a violation locally is faster than
waiting for the job.
