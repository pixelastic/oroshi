## Issue 08 — UserPromptSubmit hook

### `local` outside function body

```zsh
local tabId="$(kitty-window-tab-id "$KITTY_WINDOW_ID")"
```

**Problem:** Standards reviewer flagged `local` as invalid outside a function body.
**Reason skipped:** Same pattern used throughout the `stop` hook (`local stdinData=`, `local transcriptPath=`, etc.). `zsh-lint` does not flag it. Consistent with established project convention.

### Hardcoded path in settings.json

```json
"command": "/home/tim/.oroshi/tools/ai/claude/config/hooks/userPromptSubmit"
```

**Problem:** Reviewers flagged `$OROSHI_ROOT` convention not followed.
**Reason skipped:** Matches exactly the existing Stop hook entry format in the same file. Claude Code settings.json does not expand shell variables — hardcoded path is required.

## Issue 07 — Stop hook

### `[ ]` vs `[[ ]]` in test assertions

**Problem:** Standards reviewer flagged new tests using single-bracket `[ ]` instead of double-bracket `[[ ]]`.
**Reason skipped:** Pre-existing style. All existing tests in `stop.bats` use `[ ]`. The new tests are consistent with the file they were added to. Not introduced by this change.

## Issue 06 — Tab bar render

### Hardcoded paths in parseRawTabData.py

```python
_ICONS_PATH = "/home/tim/.oroshi/tools/term/zsh/config/theming/dist/icons.json"
_ATTENTION_FILE = "/home/tim/local/tmp/oroshi/kitty/attention"
```

**Problem:** Standards reviewer flagged these as violating `feedback_oroshi_root.md` (use `$OROSHI_ROOT` env var, not hardcoded paths).
**Reason skipped:** GUIDANCE.md explicitly documents: "Python files in the tab bar use hardcoded paths (pre-existing pattern; Python can't use env vars)." The pre-existing `statusbar.py` uses the same hardcoded pattern throughout. The feedback rule applies to ZSH scripts; the project guidance overrides it for Python tab bar modules.

### statusbar.py beacon path not updated

**Problem:** Spec says "Also update `tab_bar_modules/statusbar.py` to reference `kitty-reload` beacon path if hardcoded path has changed."
**Reason skipped:** Condition not triggered. `kitty-reload` writes beacon to `$OROSHI_TMP_FOLDER/kitty-refresh` = `/home/tim/local/tmp/oroshi/kitty-refresh`, which exactly matches `statusbar.py` line 109. No change needed.

## Issue 05 — Attention scripts

### Spec: "replace kitty-refresh" wording

**Problem:** Spec says "replace `kitty-refresh`" but the diff replaces `kitty-reload`.
**Reason skipped:** Stale spec language. By implementation time, `kitty-refresh` had already been renamed to `kitty-reload` (issue 04). Replacing `kitty-reload` with `kitty-redraw` is correct.

### bats_mock overwrites function body (spec)

**Problem:** Spec reviewer flagged that `bats_mock kitty-redraw` might overwrite the function body defined just before.
**Reason skipped:** Same false positive as issue 02 review-log. `bats_mock` exports the already-defined function; it does not redefine it. Tests pass.

### kitty-tab-id not mocked for no-arg case

**Problem:** `kitty-tab-id` is not mocked for the implicit-tab fallback path.
**Reason skipped:** All tests pass an explicit tabId. The no-arg case is not in the spec's behavioral test list.

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
