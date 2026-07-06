## Issue 02 — kitty-redraw

### bats_mock pattern flagged as incorrect

```bats
kitty() { echo "$*" >"$BATS_TMP_DIR/kitty-args"; }
bats_mock kitty
```

**Problem:** Reviewer claimed inline function + bats_mock is wrong — that bats_mock overwrites the stub.
**Reason skipped:** False positive. `bats_mock` uses `declare -f` to serialize the function defined before it. The stub body IS the mock. This is the established pattern in the codebase (see `kitty-tab-create.bats`). Tests pass.

### `kitty @` flagged as short-form arg

```zsh
kitty @ set-tab-color --match all active_bg=NONE
```

**Problem:** Reviewer flagged `@` as a shorthand for `--to`.
**Reason skipped:** `@` is kitty's remote control subcommand syntax, not a short option flag. The long-form rule targets option flags (`-q` → `--quiet`). Not applicable.

### No test for "no JSON reload" property

**Problem:** Spec says "No data is reloaded from disk" — reviewer flagged no test asserting this.
**Reason skipped:** This is an implementation property of the `kitty @ set-tab-color` mechanism itself. It cannot be tested at the script level without inspecting Kitty internals. The mechanism is documented in GUIDANCE.md from the prior validation issue.

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
