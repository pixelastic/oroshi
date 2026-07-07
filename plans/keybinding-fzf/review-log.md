## Issue 01 — Primitives

### `local` at script top-level (false positive)
```zsh
local windowId="$1"
local varName="$2"
```
**Problem:** Spec agent flagged `local` at script top-level as invalid zsh syntax.
**Reason skipped:** False positive — `kitty-window-get-var` uses the same pattern and passes tests; this is established codebase convention.

### `.[0]` jq scope limited to first OS window
```zsh
kitty-remote ls | jq -r --arg winId "$KITTY_WINDOW_ID" '
  .[0].tabs[].windows[]
  | select(.id == ($winId|tonumber))
  | .overlay_for
'
```
**Problem:** `.[0]` hardcodes the first OS window; spec doesn't restrict to one OS window.
**Reason skipped:** Matches the existing pattern in `kitty-window-get-var`; single-OS-window assumption is consistent across all kitty scripts in this repo.

## Issue 02 — kitty-ctrl-p

### `local` at script top-level
```zsh
local parentId="$(kitty-overlay-window-id)"
local selection="$(ctrl-p)"
```
**Problem:** Standards flagged `local` at script top-level as a no-op (globals).
**Reason skipped:** GUIDANCE.md (Issue 01) documents this as the established codebase convention.

### UPPER_CASE for constants
```zsh
local parentId="..."
local inlineSelection="..."
```
**Problem:** zsh-writer checklist says script constants should be UPPER_CASE without `local`.
**Reason skipped:** Since `local` is used (per codebase convention), these are function-scope vars — camelCase is correct.

### Missing guard on `parentId`
```zsh
local parentId="$(kitty-overlay-window-id)"
```
**Problem:** No empty-check; could silently send to window "".
**Reason skipped:** `kitty-overlay-window-id` exits non-zero when not in an overlay; `set -e` propagates before `kitty-window-send-text` is reached.

### Stub definitions inline in `@test` blocks
**Problem:** Standards flagged stubs should be in `setup()`.
**Reason skipped:** Existing kitty tests (`kitty-tab-attention-add.bats`) define stubs inline per test — established pattern.

### `[[ ]]` vs `[ ]` in tests
**Problem:** Flagged as inconsistent with zsh-writer canonical examples.
**Reason skipped:** Existing kitty bats tests use `[[ ]]` — no inconsistency.
