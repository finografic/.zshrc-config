# General Development Rules

This is a zsh configuration repo. Nearly everything here is zsh; the one
exception is `packages/zconf`, the maintainer CLI, which is TypeScript (see
`code/typescript-patterns.instructions.md`, scoped there via `applyTo`).
These rules apply everywhere else.

## The load-model contract

The rule that matters most in this repo: **sourcing anything under `lib/`
must not run anything.** No `echo`, no network call, no file write, no
command substitution at the top level. If a module needs to do work, that
work becomes a named function, and a _profile_ decides whether to call it.
Full layer table and rationale: `docs/ARCHITECTURE.md`. The complete style
guide, with the reasoning behind each rule: `docs/CONVENTIONS.md`.

Before proposing a change to `lib/`, `core/`, `bootstrap/`, or `profiles/`,
run `pnpm zconf doctor` — it lints exactly this contract, statically, against
the real module registry.

## Zsh conventions

- Functions: the `function` keyword, kebab-case names (`function clean-node-modules()`, not `clean_node_modules()` or a bare `clean-node-modules() {`).
- `[[ ]]`, never `[ ]`. Watch for `[[ $1 > "" ]]` masquerading as a non-empty test — it's a string comparison; use `[[ -n "$1" ]]`.
- No shebang on a file that is only ever sourced (`lib/`, `core/`, `bootstrap/`, `profiles/`). Use a boxed `# NOTE:` header instead.
- Comment-block separators are the canonical 78-char boxed equals — see `docs/CONVENTIONS.md` for the exact form. `pnpm zconf normalize` applies it.
- Color output goes through `${_c}`-style vars from `lib/colors.zsh`, sourced explicitly at the top of the module that uses them — never a local ANSI escape or a hand-rolled palette.
- Destructive helpers take `--dry-run`, not `--dry`.
- Confirm prompts put the default last: `(Y/n)`, so Enter accepts it — unless the operation is destructive enough to warrant no default at all.
- `print`/`printf` over `echo -e` — the latter's behaviour isn't portable across shells.

## Modules and terminology

- "Module" means a file under `lib/`. A "barrel" (`lib/git.zsh`) sources the
  "leaf" files in its matching directory (`lib/git/git.core.zsh`, etc.) in a
  fixed order.
- Environment selection is `$ZENV`, resolved once by `core/detect.zsh`'s
  `determine-environment` and read everywhere else — never re-derived.
- Personal configuration (paths, hostnames, tokens) comes from `.env`
  (gitignored) or a profile's own file, never a literal in a tracked module.
  See "Public means portable" in `docs/ARCHITECTURE.md`.

## Checking your work

```sh
zsh -n <file>                   # syntax
pnpm zconf doctor                # load-model contract
pnpm zconf scan                  # secrets / PII
zsh tests/test-lib-inert.zsh     # empirical inertness proof
```

CI runs all of these; catching a violation locally is faster than waiting for
the job.

## TypeScript (`packages/zconf` only)

See `code/typescript-patterns.instructions.md`, `code/modern-typescript-patterns.instructions.md`,
and `code/picocolors-cli-styling.instructions.md` — all scoped to
`packages/zconf/**` via `applyTo` frontmatter, since that is the only
TypeScript in the repo.

## Markdown Conventions

- Use plain headings (`##`, `###`) without extra bold.
- Add blank lines around code blocks.
- Wrap filenames/paths/methods/variables in backticks for inline code.
