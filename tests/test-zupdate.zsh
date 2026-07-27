#!/bin/zsh
# ============================================================================ #
# NOTE: ZUPDATE TESTS
#
# Covers `update-config.zsh` without ever committing or pushing anything real:
# the pure helpers are reached by SOURCING the script (its bottom guard means
# sourcing does not run `zupdate-main`), and the end-to-end paths run against a
# throwaway repo in $TMPDIR with a local "remote".
# ============================================================================ #

ZSHRC_ROOT="${ZSHRC_ROOT:-${0:A:h:h}}"
export ZSHRC_ROOT

typeset -i passed=0 failed=0

function ok() {
  local label="$1"
  print "  ${_g:-}ok${_0:-}    $label"
  (( passed++ ))
}

function nope() {
  local label="$1" expected="$2" actual="$3"
  print "  ${_r:-}FAIL${_0:-}  $label"
  print "        expected: $expected"
  print "        actual:   $actual"
  (( failed++ ))
}

function check-eq() {
  local label="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then ok "$label"; else nope "$label" "$expected" "$actual"; fi
}

# Sourcing must NOT run the tool. If the guard is wrong this hangs or mutates
# the real repo, which is exactly the failure worth catching.
source "$ZSHRC_ROOT/update-config.zsh"

print "\nmessage normalisation:"

check-eq "bare message gets a chore: prefix" \
  "chore: tidy up aliases" "$(zu-normalize-message 'tidy up aliases')"

check-eq "an existing type is left alone" \
  "feat: add a thing" "$(zu-normalize-message 'feat: add a thing')"

check-eq "a scoped type is left alone" \
  "fix(git): stop clobbering _B" "$(zu-normalize-message 'fix(git): stop clobbering _B')"

check-eq "a breaking-change marker is left alone" \
  "refactor!: drop the spinner" "$(zu-normalize-message 'refactor!: drop the spinner')"

check-eq "a scoped breaking change is left alone" \
  "feat(zconf)!: change the CLI" "$(zu-normalize-message 'feat(zconf)!: change the CLI')"

# The old auto-message, which this repo's own commitlint hook rejects.
check-eq "the old auto-message is rescued into a valid one" \
  "chore: updated from: home-macos" "$(zu-normalize-message 'updated from: home-macos')"

check-eq "a word that merely starts with a type is not mistaken for one" \
  "chore: features are nice" "$(zu-normalize-message 'features are nice')"

check-eq "a type without the colon-space is not treated as a prefix" \
  "chore: fix that bug" "$(zu-normalize-message 'fix that bug')"

print "\nAI-drafted commit message (must not hit a real Ollama in CI):"

# No end-to-end test calls run-zupdate with neither a message nor --sync,
# so the AI path is never reached there — this checks its own guard clause
# directly instead, against a dir with no zconf build (never a real network
# call). Called plainly, not via `$(...)`: it sets
# $ollama_commit_message/$ollama_commit_meta directly rather than printing
# them, since command substitution would fork a subshell in zsh and those
# assignments would never reach this caller.
no_build_dir="$(mktemp -d "${TMPDIR:-/tmp}/zupdate-test-nobuild-XXXXXX")"
ollama_commit_message='unset' ollama_commit_meta='unset'
if ZSHRC_ROOT="$no_build_dir" ollama-commit-message; then
  nope "ollama-commit-message is silently unavailable without a zconf build" \
    "non-zero return" "returned 0"
else
  ok "ollama-commit-message is silently unavailable without a zconf build"
fi
check-eq "ollama-commit-message clears \$ollama_commit_message on failure" "" "$ollama_commit_message"
rm -rf "$no_build_dir"

# ============================================================================ #
# End-to-end, against a throwaway repo with a local remote.
# ============================================================================ #

print "\nend-to-end (throwaway repo):"

sandbox="$(mktemp -d "${TMPDIR:-/tmp}/zupdate-test-XXXXXX")"
trap 'rm -rf "$sandbox"' EXIT

git init --quiet --bare "$sandbox/remote.git"
git clone --quiet "$sandbox/remote.git" "$sandbox/work" 2> /dev/null

(
  builtin cd "$sandbox/work"
  git config user.email "test@example.com"
  git config user.name "Test"
  git config commit.gpgsign false
  print "initial" > README.md
  git add README.md
  git commit --quiet -m "chore: initial"
  git push --quiet origin HEAD:master 2> /dev/null
  git branch --set-upstream-to=origin/master master 2> /dev/null
) > /dev/null 2>&1

# The script always operates on $ZSHRC_ROOT, so point it at the sandbox.
function run-zupdate() {
  ZSHRC_ROOT="$sandbox/work" zsh "$ZSHRC_ROOT/update-config.zsh" "$@" 2>&1
}

# --- dry run changes nothing ------------------------------------------------
print "modified" >> "$sandbox/work/README.md"
before="$(git -C "$sandbox/work" rev-parse HEAD)"
output="$(run-zupdate --dry-run 'test message' || true)"
after="$(git -C "$sandbox/work" rev-parse HEAD)"

check-eq "--dry-run creates no commit" "$before" "$after"

if [[ "$output" == *"dry run"* ]]; then
  ok "--dry-run says so"
else
  nope "--dry-run says so" "output containing 'dry run'" "$output"
fi

if [[ -z "$(git -C "$sandbox/work" diff --staged --name-only)" ]]; then
  ok "--dry-run stages nothing"
else
  nope "--dry-run stages nothing" "empty index" "$(git -C "$sandbox/work" diff --staged --name-only)"
fi

# --- untracked files are not staged without --all ---------------------------
print "junk" > "$sandbox/work/stray.bin"
output="$(run-zupdate --yes 'chore: tracked only' || true)"

if git -C "$sandbox/work" ls-files --error-unmatch stray.bin > /dev/null 2>&1; then
  nope "an untracked file is NOT committed by default" "stray.bin untracked" "stray.bin committed"
else
  ok "an untracked file is NOT committed by default"
fi

if [[ "$output" == *"stray.bin"* ]]; then
  ok "the untracked file is still reported to you"
else
  nope "the untracked file is still reported to you" "output naming stray.bin" "$output"
fi

# The tracked edit should have gone through.
subject="$(git -C "$sandbox/work" log -1 --pretty=%s)"
check-eq "the tracked change was committed with the given message" "chore: tracked only" "$subject"

# --- --all opts the untracked file in ---------------------------------------
output="$(run-zupdate --yes --all 'chore: include stray' || true)"

if git -C "$sandbox/work" ls-files --error-unmatch stray.bin > /dev/null 2>&1; then
  ok "--all stages the untracked file"
else
  nope "--all stages the untracked file" "stray.bin tracked" "still untracked"
fi

# --- --sync produces a commitlint-valid message -----------------------------
print "more" >> "$sandbox/work/README.md"
ZENV=home-macos run-zupdate --yes --sync > /dev/null 2>&1 || true
subject="$(git -C "$sandbox/work" log -1 --pretty=%s)"

if [[ "$subject" == "chore(sync): update from "* ]]; then
  ok "--sync writes a conventional-commit subject"
else
  nope "--sync writes a conventional-commit subject" "chore(sync): update from ..." "$subject"
fi

# --- the push actually reached the remote -----------------------------------
local_head="$(git -C "$sandbox/work" rev-parse HEAD)"
remote_head="$(git -C "$sandbox/remote.git" rev-parse master 2> /dev/null || print none)"
check-eq "the commit was pushed to the remote" "$local_head" "$remote_head"

# --- the secret scan blocks a push ------------------------------------------
print 'HOST="192.168.44.99"' >> "$sandbox/work/README.md" # zconf-scan-ignore
before="$(git -C "$sandbox/remote.git" rev-parse master)"
output="$(run-zupdate --yes 'chore: leak an address' 2>&1 || true)"
after="$(git -C "$sandbox/remote.git" rev-parse master)"

check-eq "a secret match stops the push" "$before" "$after"

if [[ "$output" == *"NOT pushing"* ]]; then
  ok "the scan failure explains itself"
else
  nope "the scan failure explains itself" "output containing 'NOT pushing'" "$output"
fi

# --no-scan lets the same content through, proving the gate is the scan itself.
output="$(run-zupdate --yes --no-scan 'chore: leak on purpose' 2>&1 || true)"
after="$(git -C "$sandbox/remote.git" rev-parse master)"

if [[ "$after" != "$before" ]]; then
  ok "--no-scan bypasses the gate (so the gate was the scan)"
else
  nope "--no-scan bypasses the gate" "a new remote head" "unchanged"
fi

# --- a commit stranded by a failed scan still gets pushed later -------------
#
# Regression guard for a real bug this suite found: the scan runs AFTER the
# commit, so a blocked push leaves a committed-but-unpushed change. The next
# run saw a clean working tree, took the "nothing to commit" path, and returned
# without pushing — stranding that commit on the machine indefinitely.
# Clear the address the scan tests planted, or the scan legitimately keeps
# blocking and this test would be measuring that instead.
grep -v '192\.168\.44\.99' "$sandbox/work/README.md" > "$sandbox/readme.tmp"
mv "$sandbox/readme.tmp" "$sandbox/work/README.md"
run-zupdate --yes 'chore: remove the planted address' > /dev/null 2>&1 || true

# Commit locally, then hold it back, mimicking a scan-blocked push.
(
  builtin cd "$sandbox/work"
  print "held back" >> README.md
  git add -u
  git commit --quiet -m "chore: committed but not pushed"
) > /dev/null 2>&1

stranded="$(git -C "$sandbox/work" rev-parse HEAD)"
# Working tree is now clean, so this takes the "nothing to commit" path.
run-zupdate --yes > /dev/null 2>&1 || true
remote_head="$(git -C "$sandbox/remote.git" rev-parse master 2> /dev/null || print none)"

check-eq "a clean tree still pushes an already-committed change" "$stranded" "$remote_head"

# --- bad usage --------------------------------------------------------------
output="$(run-zupdate --nonsense 2>&1 || true)"
if [[ "$output" == *"unknown option"* ]]; then
  ok "an unknown option is rejected"
else
  nope "an unknown option is rejected" "output containing 'unknown option'" "$output"
fi

output="$(run-zupdate --sync 'and a message' 2>&1 || true)"
if [[ "$output" == *"--sync takes no message"* ]]; then
  ok "--sync plus a message is rejected"
else
  nope "--sync plus a message is rejected" "output containing '--sync takes no message'" "$output"
fi

print ""
if (( failed == 0 )); then
  print "${_g:-}$passed passed, 0 failed${_0:-}"
  exit 0
fi

print "${_r:-}$passed passed, $failed failed${_0:-}"
exit 1
