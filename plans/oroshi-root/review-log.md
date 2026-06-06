## Issue 01 — zshenv worktree detection

### `bats_mock` called in `setup()`
```bats
oroshi-reload-functions() { :; }
bats_mock oroshi-reload-functions
```
**Problem:** Reviewer flagged that `bats_mock` should be per-test, not in `setup()`.
**Reason skipped:** `context-root.bats` and other tests in this codebase already use the same pattern — mocking shared stubs in `setup()` is established practice here.

### `CURRENT` repurposed as a dynamic tmp wrapper script
```bats
CURRENT="$BATS_TMP_DIR/caller.zsh"
```
**Problem:** Convention for `CURRENT` is the path to the script/function under test, not a tmp wrapper.
**Reason skipped:** `zshenv.zsh` requires environment setup and `cd` before sourcing, making a direct `bats_run_zsh "$ZSHENV"` impossible. A wrapper caller script is necessary; `CURRENT` is still the file passed to `bats_run_zsh`.

### `local` at file scope in `zshenv.zsh`
```zsh
local wtRel="${PWD#"$OROSHI_WORKTREES_DIR/"}"
```
**Problem:** `local` is semantically a function-scope construct; at top level of a sourced script it is a pre-existing pattern.
**Reason skipped:** Line 42 (`local functionDirectory=...`) already does the same thing. Fixing one instance without the other would be inconsistent; full cleanup is out of scope for this issue.
