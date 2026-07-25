# Contributing

This is a personal dotfiles config shared publicly. PRs for portability fixes, bug fixes,
and genuinely reusable patterns are welcome; PRs that add personal/employer-specific
content are not a good fit — see `docs/ARCHITECTURE.md` for the profile model if you want
to add your own host instead.

## Workflow

1. Fork and branch from `master`.
2. Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
   (`commitlint.config.mjs` enforces this via a commit-msg hook).
3. Run `pnpm lint` and `pnpm format:check` before opening a PR.
4. Keep changes scoped — one concern per PR.

## Local checks

```sh
pnpm lint
pnpm lint:md
pnpm format:check
```
