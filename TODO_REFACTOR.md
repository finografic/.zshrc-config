# zshrc-config – Refactor TODO

## Current status

- Phases 1–4 complete (bootstrap stable, VSCode optimized, TS/Node tooling in place)
- Phase 6 complete (cleanup: PATH/.env/pnpm consolidation)
- Monorepo/workspace layout complete (`packages/`, `tools/`, `extras/`)

## Next up (recommended order)

### Phase 5 – Caching (medium)

Goal: reduce shell startup cost by caching expensive data under `~/.cache/zshrc-config/`.

- [ ] Create cache dir + helpers (age/mtime checks, safe read/write)
- [ ] Cache “system info” (hostname, OS, IP, versions) with daily TTL
- [ ] Cache “hardware detection” with boot/session TTL (or daily if simpler)
- [ ] Update widgets/splash to use cached data (and skip entirely in VSCode/Docker)

Notes:

- Plugin bundle caching is already done in bootstrap.
- compinit caching is already done in bootstrap.

### Phase 7 – Documentation (low)

- [ ] Document bootstrap sequence (what runs, in what order, why)
- [ ] Document multi-system setup (macOS/home-linux/docker/vscode)
- [ ] Add troubleshooting section (common startup errors, antidote/plugins, p10k)
- [ ] Clean up/merge remaining legacy docs if any

## Handy commands

- Build node bundle: `pnpm run build:node`
- Typecheck node bundle: `pnpm run typecheck:node`

## Optional future work

- Convert splash data collection to TS for stronger caching + structured output
- Add a "health" command (e.g. `zshrc-health`) to verify expected files/caches
