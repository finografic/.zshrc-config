## Learned User Preferences

- Define zsh functions with the `function` keyword and kebab-case names (never snake_case)
- Prefer `--dry-run` over `--dry` for CLI dry-run flags
- Keep `~/.zshrc` section headers as `NOTE: {STEP_DESCRIPTION}` inside the canonical boxed comment style
- Refer to sourced `.zsh` files as "modules"
- Use color variables from `lib/colors.zsh` (e.g. `${_c}`, `${_0}`) for terminal output
- Editor formatters: dprint for JS/TS/JSON/jsonc/YAML/TOML/CSS/SCSS/HTML; mkhl.shfmt for shellscript with tabs (`editor.insertSpaces: false`, `editor.detectIndentation: false`)
- Prefer `pnpm -C "$path"` when running pnpm scripts in another repo without changing the shell PWD
- Update `TODO_REFACTOR_PROGRESS.md` when continuing refactor work across agent sessions

## Learned Workspace Facts

- Multi-system zsh bootstrap: minimal `~/.zshrc` sources `$ZSHRC_ROOT/main.zsh`; `.env` vars `IS_HOME` / `IS_OFFICE` select `_zenvs/*` profiles
- Committed repo file `.zshrc` is the reference template for system `~/.zshrc` (sync on major refactors or new system setup)
- Bootstrap sequence under `bootstrap/`: compinit must run before plugins; plugin list in `plugins/.zsh_plugins.txt` (Antidote)
- Canonical comment block separators: 78-char boxed equals (`# ============================================================================ #`); normalization script at `scripts/normalize-comment-blocks.py`
- Git remote host is Bitbucket (`bitbucket.org:justin-rankin/.zshrc-config.git`)
- `$REPOS_FINO` in `_zenvs/home-macos/` points at Finografic repos (e.g. `_@finografic-deps-policy`)
