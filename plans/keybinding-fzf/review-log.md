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
