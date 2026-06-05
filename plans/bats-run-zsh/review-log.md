## Issue 01 — bats_run_zsh helper

### realpath exits 0 on non-existent paths
```bash
local abs_path="$(realpath "$path")"
[[ "$abs_path" == "" ]] && return 1
```
**Problem:** Reviewer claimed `realpath` exits 0 on missing files so the guard never fires.
**Reason skipped:** On GNU/Linux (coreutils), `realpath` exits non-zero and writes nothing to stdout for missing paths. `local` swallows the exit code but `abs_path` is empty, so the guard fires correctly. macOS behavior differs but this codebase targets Linux.

### Stdin via <<< not explicitly forwarded
```bash
run zsh -c "$cmd" -- "$@"
```
**Problem:** Reviewer flagged that `run zsh -c` may not preserve stdin piped via `<<<`.
**Reason skipped:** Identical pattern used by existing `bats_run_function` and `bats_run_script`, which already support `<<<` in their usage docs. No regression introduced.

### Autoload fpath not set up in cmd string
```bash
run zsh -c "[[ -f '${mock_file}' ]] && source '${mock_file}'; ${func} \"$@\"" -- "$@"
```
**Problem:** Reviewer flagged that `.zshenv` is not sourced in the cmd, so fpath is not configured and autoload functions won't resolve.
**Reason skipped:** ZSH always sources `.zshenv` for non-interactive shells (`zsh -c` included). The exported `OROSHI_ROOT` causes `.zshenv` to pin fpath to the worktree — same mechanism `bats_run_function` relies on. No explicit source needed.

## Issue 02 — noRunZsh message

### Bare `[[` assertions always pass (Standards reviewer)
```bash
[[ "$output" == *"bats_run_zsh"* ]]
[[ "$output" != *"bats_run_function"* ]]
```
**Problem:** Reviewer claimed bare `[[` is a no-op in BATS that silently passes.
**Reason skipped:** `expect_rule_violation` in `rules-helper` (lines 22–23) uses identical bare `[[` assertions. This is the established pattern for this codebase. BATS propagates non-zero exits from `[[`, so a failed condition fails the test.

### "Update existing test" vs "add new tests" (Spec reviewer)
**Problem:** Reviewer flagged that the spec says "update the corresponding test" but the diff adds new tests instead of modifying existing ones.
**Reason skipped:** No pre-existing test asserted message content — there was nothing to update. Adding new tests is the correct interpretation of "update the test file to assert the new message text."

## Issue 03 — Pilot migration

### `[[ $isAutoloadedFunction == "0" ]]` tests negative flag (Standards reviewer)
```zsh
if [[ $isAutoloadedFunction == "0" ]]; then
  run zsh -c "..." -- "$@"
  return
fi
```
**Problem:** Standard pattern is `== "1"` for the positive branch; restructure so the autoload branch checks `== "1"` and scripts fall through.
**Reason skipped:** This code is in the `bats_run_zsh` helper committed in Issue 01 — outside the diff for this session. The current issue only migrated a test file. Flagging for potential cleanup in a future session.
