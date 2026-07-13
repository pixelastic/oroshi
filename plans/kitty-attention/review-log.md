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
