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

- [ ] `P0.1` — decide and execute the git history strategy (`[HUMAN]`, still open — see [`TODO_PUBLIC_RELEASE_REFACTOR.md`](./TODO_PUBLIC_RELEASE_REFACTOR.md#p01--decide-and-execute-the-history-strategy)). Blocking: nothing goes public until this is resolved.

---

## P0 — Active

- [ ] `P0.1` Decide and execute the git history strategy (`[HUMAN]`) — the only remaining blocker to public release.

---

## P1 — Next Up

- [ ] **Phase 3 — `lib/` consolidation**: finish the domain barrels, consistency sweep, guarded colour sourcing. (Orphan deletion, the other half of Phase 3, already happened incidentally during P1.2.)
- [ ] **Phase 6 — `zupdate` rewrite** (`[OPUS]`) with conventional commits, `--sync`, `--dry-run`, fail-safe rebase handling.

---

## P2 — Planned

- [ ] **Phase 5 — TypeScript `zconf` toolkit** (`[OPUS]`): `doctor` · `graph` · `scan` · `bench` · `new-profile`.
- [ ] **Phase 7 — Docs, agent rules, CI**: README for strangers, `docs/ARCHITECTURE.md`, zsh-first instruction files, container smoke matrix.

---

## P3 — Backlog

- [ ] **Phase 8 remainder**: `scripts/` grouping, `extras/` audit. (`_zenvs/` → `profiles/` was promoted out of this phase and confirmed by the user — see Done below. `zdoctor` also already shipped, in P1.2.)
- [ ] Migrate the `finografic`-branded repo-alias block in `_zenvs/home-macos/home-macos.aliases.zsh` (now `profiles/home-macos/`) to the `REPO_ALIASES` `.env` pattern — flagged during P2.1, deliberately out of scope there.

---

## Done

| Item                                                                                                                    | Completed  |
| ----------------------------------------------------------------------------------------------------------------------- | ---------- |
| `P0.2`–`P0.5` — secrets/PII scrub, git-config-mutation removal, 66 MB vendored binaries purged, LICENSE/CI              | 2026-07-26 |
| **Phase 1** — load-model contract: `core/detect.zsh`, source-time side effects purged, single `PATH` owner              | 2026-07-26 |
| **Phase 2** — `office-macos` genericised, `apnaes` → `server-linux`, declarative profile manifests (`core/profile.zsh`) | 2026-07-26 |
| `P4.3` — startup benchmark harness (`scripts/bench-startup.zsh`), done ahead of Phase 3                                 | 2026-07-26 |
| `P4.4` (mostly) — `zsh-nvm` plugin removed, lazy nvm loading, splash tool-version caching                               | 2026-07-26 |
| `P4.5` — `_zenvs/` → `profiles/` rename (D2, confirmed by the user)                                                     | 2026-07-26 |

Full detail, evidence, and verification for every item above lives in
[`TODO_PUBLIC_RELEASE_REFACTOR.md`](./TODO_PUBLIC_RELEASE_REFACTOR.md#done).
