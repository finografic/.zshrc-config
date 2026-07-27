# TODO — Ollama Commit Message Warmup

> **Status:** Planned (2026-07-28). Small follow-up for reducing Ollama warm-up time in
> `zupdate` and `_gcai` without making ordinary shell commands surprising.

---

## Context

`zupdate` and `_gcai` can generate commit messages through the local Ollama-backed
`zconf message` flow. The preferred default model is `gemma4:e4b-it-qat`, chosen after
local comparison against alternatives such as `qwen2.5-coder:3b`.

Private local configuration now includes:

```zsh
OLLAMA_KEEP_ALIVE=30m
```

That should reduce repeated cold starts once the model has been used. This TODO tracks
small repo-side improvements to make the workflow feel warm when a commit is likely.

---

## Plan

### Phase 1 — Respect keep-alive in the message path

- [x] Confirm `zconf message` forwards `OLLAMA_KEEP_ALIVE` or sets an explicit
      `keep_alive` value on Ollama API requests.
- [x] Prefer an explicit request-level `keep_alive` only if needed; otherwise keep
      the global `OLLAMA_KEEP_ALIVE=30m` behavior.
- [x] Keep the timeout/load timeout concept separate from keep-alive: timeout is for
      slow loading or generation, keep-alive is for model residency after use.

### Phase 2 — Add reusable git-root helpers

- [x] Add a shell helper named `git-root` that prints `git rev-parse --show-toplevel`
      and returns non-zero outside a worktree.
- [x] Add `is-git-root` that succeeds only when `$PWD` is exactly the repo root.
- [x] Reuse the helpers where current modules inline repo-root checks.

### Phase 3 — Optional opportunistic preload

- [x] Add `ollama-model-loaded` using Ollama's loaded-model state (`/api/ps` or
      equivalent CLI/API behavior).
- [x] Add `ollama-preload-default-model` that sends a tiny/no-output preload request
      for `${OLLAMA_DEFAULT_MODEL:-gemma4:e4b-it-qat}`.
- [x] Add a debounce guard, e.g. one preload attempt per model every five minutes.
- [x] Trigger the preload in the background from `listing-eza` only when `is-git-root`
      succeeds.
- [x] Do not hijack `l`; keep the hook inside the existing listing function and make
      failures silent.

### Phase 4 — Manual unload only

- [x] Do not auto-unload when leaving a repository; multiple terminals make that too
      surprising.
- [x] Optionally add a manual `ollama-unload-default-model` helper for explicit memory
      cleanup.

---

## Acceptance Criteria

- [x] First `_gcai` / `zupdate` call can warm the model and keep it resident for the
      configured window.
- [x] Running `l` at a git repo root can start a silent background preload.
- [x] Running `l` outside a repo root never calls Ollama.
- [x] Repeated listings do not spam Ollama.
- [x] No user-visible listing output changes unless there is an existing listing error.
