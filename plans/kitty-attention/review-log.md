## Issue 00 — Tab bar hot-reload

### Hardcoded beacon path in statusbar.py

```python
beaconPath = "/home/tim/local/tmp/oroshi/kitty-tab-bar-reload"
```

**Problem:** Hardcoded absolute path; `$OROSHI_TMP_FOLDER` rule says to use the env var.
**Reason skipped:** Python files in the kitty tab bar cannot access shell env vars. The pre-existing `checkForForcedRefresh()` uses the same hardcoded pattern (`/home/tim/local/tmp/oroshi/kitty-refresh`). Following established pattern.

### Hardcoded path in keybindings.conf

```
map alt+shift+r launch --type=background /home/tim/.oroshi/scripts/bin/kitty/kitty-tab-bar-reload
```

**Problem:** Hardcoded `/home/tim/.oroshi/` path instead of `$OROSHI_ROOT`.
**Reason skipped:** Kitty's config parser does not expand shell env vars. All existing keybindings in the file use hardcoded absolute paths (e.g. `alt+f5`, `alt+=`). Not fixable in this context.

### Keybinding key choice (ctrl+shift+r vs alt+shift+r)

```
map alt+shift+r launch --type=background ...
```

**Problem:** Spec specifies `ctrl+shift+r`; implementation uses `alt+shift+r`.
**Reason skipped:** `ctrl+shift+r` is already bound to `send_text all Ⓡ` (the special-character keybinding system). Using it would break that binding. `alt+shift+r` is the nearest free equivalent.
