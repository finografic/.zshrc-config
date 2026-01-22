Perfect — thank you for restating that constraint. That changes *how* we proceed, not *what* we’re aiming for, and your instincts here are exactly right.

I’m going to be very explicit and conservative.
**No step below should break your shell at any point**, and every step will be:

* additive first
* reversible
* source-order safe
* committable in isolation

I’ll outline the **plan**, then we’ll execute **Step 1 only** in this message.

---

# Ground rules (locked in)

We will respect these throughout:

1. **Active system**

   * Your shell must keep working after *every* edit
   * No “big bang” refactors
   * No silent behavior changes

2. **Iterative**

   * Each step is independently valid
   * Each step can be committed
   * Rollback is always trivial

3. **No tool assumptions**

   * NVM, PNPM, Node versions must continue to work exactly as now
   * No installer breakage
   * No prompt regressions

4. **Shell-first**

   * Node/TS only when it *reduces* risk, not increases it

---

# High-level migration plan (safe path)

We’ll do this in **four phases**, but we’ll only *execute Phase 1 now*.

## Phase 1 — Stabilize & isolate (NO behavior change)

* Leave `.zshrc` functionally identical
* Stop the bleeding (duplication, drift)
* Introduce *scaffolding*, not logic

## Phase 2 — Vendor capture (additive)

* Introduce `vendor/`
* Mirror existing PNPM/NVM logic there
* Load vendors from both places (temporarily)

## Phase 3 — Harvest & verify

* Add `zshrc-harvest` script
* Extract known installer blocks
* Verify equivalence
* Only then remove from `.zshrc`

## Phase 4 — Minimal `.zshrc`

* `.zshrc` becomes immutable
* All policy lives in repo
* Optional cleanup of temp shims

---

# Phase 1 — what we do **now**

This phase does **not** change behavior.

### Goals

* Prepare structure
* Make later moves safe
* Avoid touching installer-generated blocks
* Avoid breaking order-sensitive code (p10k, compinit)

---

## Step 1.1 — Add a bootstrap prelude (NO-OP)

Create a new file:

`~/.zshrc-config/bootstrap/00-prelude.zsh`

Contents (minimal, inert):

```zsh
# Bootstrap prelude
# Intentionally minimal and side-effect free
# Reserved for future migration from ~/.zshrc
```

This does nothing today.
Its purpose is **structural**, not functional.

✅ Safe
✅ No behavior change
✅ Commit-worthy

---

## Step 1.2 — Source prelude at TOP of `main.zsh`

At the very top of `main.zsh`, add:

```zsh
source "$ZSHRC_ROOT/bootstrap/00-prelude.zsh"
```

Nothing breaks because:

* file exists
* file does nothing
* order is unchanged

This gives us a **controlled insertion point** later.

---

## Step 1.3 — Freeze `.zshrc` (without changing it yet)

Do **not** edit logic yet.

Add only comments to `.zshrc`, above your source line:

```zsh
# =============================================================================
# NOTE:
# Everything above this line is considered "shell bootstrap" and is stable.
# Everything below is installer-managed or legacy and will be harvested.
# =============================================================================

source "$HOME/.zshrc-config/main.zsh"

# =============================================================================
# INSTALLER-MANAGED BLOCKS (DO NOT EDIT MANUALLY)
# =============================================================================
```

No logic change.
No reorder.
No deletion.

This is a **psychological contract** as much as a technical one.

---

## Why I’m *not* doing more yet

I am deliberately **not**:

* moving PNPM
* touching NVM
* changing PATH
* touching antidote
* relocating p10k
* adding auto-clean logic

Because:

> Until we have a guaranteed “safe injection point”, moving logic is risky.

We just created that injection point.

---

# About your “temporary migration script” idea

Your idea is **solid**, and we will use it — but *later*.

The correct place for it is exactly what you suggested:

* `bootstrap/00-prelude.zsh`
* or `bootstrap/01-legacy-compat.zsh`

This will act as:

* a shim
* a compatibility bridge
* a safety net

And yes:

* it can be deleted later
* or left as a documented escape hatch

We just don’t populate it yet.

---

# What we do next (next message)

Next safe step (Phase 2, Step 2.1):

**Introduce `vendor/` with mirror-only logic**

Meaning:

* copy existing PNPM/NVM logic *verbatim*
* source it in addition to existing locations
* confirm no breakage
* only then decide removal

This keeps your shell 100% functional while we migrate ownership.

---

## Before proceeding

Please do this now:

1. Create `bootstrap/00-prelude.zsh`
2. Add the `source` line at top of `main.zsh`
3. Add the comment fences to `.zshrc`
4. Open a new terminal
5. Confirm:

   * prompt works
   * node / pnpm / nvm still work
   * no new output or warnings

Then reply with:

* “All good”
  or
* exact error/output (if any)

Once confirmed, we proceed to **vendor/** safely.

You’re doing this exactly the right way.
