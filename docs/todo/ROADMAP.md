# Roadmap

> **This is the primary high-level plan for the project.**
> Check this file before proposing new work. Add new items when conceiving features.
> Keep it ordered by priority — move completed items to the Done section at the bottom.

---

## How to use this file

| Tier | Meaning                                   |
| ---- | ----------------------------------------- |
| P0   | Active — being worked on now              |
| P1   | Next — fully scoped, ready to start       |
| P2   | Planned — direction decided, detail TBD   |
| P3   | Backlog — good ideas, not yet prioritised |

When an item is done, move it to the Done section at the bottom with a completion date.

---

## Next

- [ ] Answer decisions D1–D9 in [`TODO_PUBLIC_RELEASE_REFACTOR.md`](./TODO_PUBLIC_RELEASE_REFACTOR.md#decisions-needed-from-you) — several phases branch on them.
- [ ] Capture a startup benchmark baseline before any optimisation (`P4.3`).

---

## P0 — Active

**Public release readiness** — blocking everything else. See [`TODO_PUBLIC_RELEASE_REFACTOR.md` Phase 0](./TODO_PUBLIC_RELEASE_REFACTOR.md#phase-0--publish-safety).

- [ ] `P0.1` Decide and execute the git history strategy (history is already on the GitHub remote)
- [ ] `P0.2` Scrub secrets and PII from the working tree (IPs, emails, tracked git configs, p10k caches)
- [ ] `P0.3` Stop mutating global git config and authenticating on shell start
- [ ] `P0.4` Purge 70 MB of vendored third-party binaries; replace with an installer
- [ ] `P0.5` `LICENSE`, `CONTRIBUTING`, `SECURITY`, minimal CI

---

## P1 — Next Up

- [ ] **Phase 1 — Load-model contract**: document the layer rules, purge source-time side effects, single `PATH` owner, fix environment detection
- [ ] **Phase 2 — Profile system**: genericise `office-macos`, `apnaes` → `server-linux` (LSWS optional), declarative profile manifests

---

## P2 — Planned

- [ ] **Phase 3 — `lib/` consolidation**: delete ~1,700 lines of orphans, finish the domain barrels, consistency sweep, guarded colour sourcing
- [ ] **Phase 4 — Startup performance**: remove Node from the hot path, benchmark harness, `autoload` cold functions, `zcompile`
- [ ] **Phase 5 — TypeScript `zconf` toolkit**: `doctor` · `graph` · `scan` · `bench` · `new-profile`
- [ ] **Phase 6 — `zupdate` rewrite** with conventional commits, `--sync`, `--dry-run`

---

## P3 — Backlog

- [ ] **Phase 7 — Docs, agent rules, CI**: README for strangers, `docs/ARCHITECTURE.md`, zsh-first instruction files, container smoke matrix
- [ ] **Phase 8 — Optional polish**: `_zenvs/` → `profiles/` rename, `scripts/` grouping, `extras/` audit, `zdoctor` machine health check

---

## Done

| Item                           | Completed |
| ------------------------------ | --------- |
| _No completed milestones yet._ | —         |
