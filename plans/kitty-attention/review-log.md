## Issue 01 — Typed attention format
### Unquoted $1 assignment
```zsh
local tabId=$1
```
**Problem:** Unquoted `$1` deviates from documented pattern which quotes assignments
**Reason skipped:** Pre-existing pattern (line was unchanged), and ZSH `local` assignment doesn't word-split

### No guard for malformed lines in redraw.py
```python
tab_id, attention_type = line.split(":", 1)
```
**Problem:** Lines without `:` would raise ValueError
**Reason skipped:** Attention file is only written by our own scripts which always produce valid `tabId:type` format — defensive parsing is out of scope

## Issue 02 — Icon rendering
### Duplicate isFullscreen guard
```python
if isFullscreen:
    suffixIcons += _icons["kitty-tab-fullscreen"]
# ...
if isFullscreen:
    title = f"{title} "
```
**Problem:** Two separate `if isFullscreen` checks could be merged
**Reason skipped:** Intentional — first appends icon to suffix collector, second appends trailing space after all icons are joined. Merging would break the ordering logic.

### Placeholder glyph in icons.jsonc
```json
"tab-attention-notification": "?"
```
**Problem:** `?` looks like a TODO left behind
**Reason skipped:** Issue spec explicitly says "The user will replace `?` with the final glyph"

## Issue 03 — Clear on close

### Missing set -e in claude wrapper
```zsh
#!/usr/bin/zsh
```
**Problem:** Script has no `set -e` error protection per zsh-writer header standard.
**Reason skipped:** Intentional — wrapper must continue after claude binary exits non-zero to run cleanup and terminal fix.

### Guard style should be return-early
```zsh
if [[ "$KITTY_WINDOW_ID" != "" ]]; then
  tabId="$(kitty-window-tab-id "$KITTY_WINDOW_ID")"
  kitty-tab-attention-remove "$tabId"
fi
```
**Problem:** if/then/fi instead of guard + exit 0.
**Reason skipped:** Two instructions inside block (requires if/then/fi per feedback_zsh_if_multiline), and cannot exit 0 because terminal-fix code follows.

### Guard tests empty vs unset
```zsh
[[ "$KITTY_WINDOW_ID" != "" ]]
```
**Problem:** Conflates unset and empty string; spec says "unset".
**Reason skipped:** Same pattern used in stop hook (`tools/ai/claude/config/hooks/stop:14`). Functionally equivalent — KITTY_WINDOW_ID is never set to empty by kitty.
