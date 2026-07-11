# PRD — Kitty Tab Bar: Redraw & Reload

## Problem Statement

The Kitty tab bar's Redraw and Reload logic is scattered across multiple files with no clear ownership. The Attention File is read on every render cycle (including every tab switch and every statusbar timer tick), making disk reads far more frequent than necessary. The Reload beacon check runs on a 1-second polling timer defined inside `statusbar.py`, meaning disabling the statusbar also disables Reload — a hard coupling between two unrelated features. The two reload operations (`kitty-reload` and `kitty-tab-bar-reload`) are poorly differentiated and map onto separate scripts that are easy to confuse. There is no single place to look to understand how either Redraw or Reload works end-to-end.

## Solution

Centralize the Redraw and Reload mechanics into two dedicated Python modules (`lib/redraw.py` and `lib/reload.py`) with a single, clearly-named entry point each (`check()`). Both modules are driven by beacon files written to a dedicated `kitty/beacons/` directory rather than polling timers; beacons are checked once per render cycle at the start of `first_pass()`, making the mechanism event-driven and cheap when idle. The Attention File is only re-read when a Redraw beacon exists, eliminating the per-render disk read. The two reload scripts are merged into a single `kitty-reload` that creates the Reload beacon and then triggers a Redraw. The statusbar is decoupled entirely and disabled for now — it will be re-introduced independently later.

## User Stories

1. As a developer, I want Redraw logic centralized in `lib/redraw.py`, so that I can understand the full Redraw flow by reading one file.
2. As a developer, I want Reload logic centralized in `lib/reload.py`, so that I can understand the full Reload flow by reading one file.
3. As a developer, I want the Attention File to be read only when a Redraw beacon is present, so that tab switches and timer ticks do not trigger unnecessary disk reads.
4. As a developer, I want `redraw.check()` to be called with no arguments, so that its interface stays stable even if the internal state structure changes.
5. As a developer, I want `reload.check()` to be called with no arguments and to discover all `lib.*` modules dynamically, so that adding a new module does not require updating a hardcoded list.
6. As a developer, I want Reload to call `projects.init()` and `tab_data.init()` explicitly after reloading modules, so that definition files are re-read predictably.
7. As a developer, I want `tab_data.py` to expose an explicit `init()` function for loading `icons.json`, so that definition file loading is consistent across all modules and has no side effects at import time.
8. As a developer, I want both `reload.check()` and `redraw.check()` to be called in sequence inside `first_pass()` at the start of each render cycle, with Reload first, so that definition files are fresh before state files are read.
9. As a developer, I want Reload to proceed correctly in the same render cycle it is triggered (no "messy" frame), so that definition and state data are consistent immediately after a Reload.
10. As a user, I want a single `kitty-reload` script that creates the Reload beacon and then calls `kitty-redraw`, so that I don't need to remember two separate commands.
11. As a user, I want `kitty-redraw` to create a Redraw beacon before triggering Kitty's render, so that the tab bar knows to re-read the Attention File on the next frame.
12. As a user, I want `Alt-R` to reload both Kitty's own config (`load_config_file`) and the tab bar Python (`kitty-reload`) in one keystroke, so that I have a single shortcut that refreshes everything.
13. As a user, I want `Alt-Shift-R` to be freed up (marked TODO), so that it can be repurposed later.
14. As a developer, I want all beacon files scoped under `kitty/beacons/`, so that Kitty runtime signals are clearly separated from data files such as the Attention File.
15. As a developer, I want the Attention File to remain a plain data file at `kitty/attention`, not inside the beacons directory, so that the structural distinction between state data and signals is visible on disk.
16. As a developer, I want the statusbar to be decoupled from `tab_bar.py` by simply removing its import, leaving `statusbar.py` unchanged, so that it can be re-introduced as an independent feature later.
17. As a developer, I want `tab_bar.py` to call `tab_data.init()` at startup alongside `projects.init()`, so that icons are loaded consistently with all other definition files.
18. As a developer, I want `kitty-tab-bar-reload` to be deleted and its keybinding removed, so that there is no confusion between the old and new reload scripts.

## Implementation Decisions

### Beacon file layout

All Kitty runtime signal files live under a dedicated `beacons/` subdirectory:

- `$OROSHI_TMP_FOLDER/kitty/beacons/redraw` — signals that the Attention File should be re-read
- `$OROSHI_TMP_FOLDER/kitty/beacons/reload` — signals that all Python modules and definition files should be reloaded

The Attention File remains at `$OROSHI_TMP_FOLDER/kitty/attention` — it is a state file (contains data), not a beacon.

### `lib/redraw.py`

New module. Owns two constants: the Redraw Beacon path and the Attention File path. Exposes a single function `check()` that:
1. Returns immediately if the Redraw Beacon does not exist (no-op, no disk read beyond the existence check)
2. Reads the Attention File and populates `tabState["attentionIds"]` (importing `tabState` from `lib.tabs` at module level)
3. Deletes the Redraw Beacon

### `lib/reload.py`

Refactored from its current minimal state. Owns the Reload Beacon path constant. Exposes a single function `check()` that:
1. Returns immediately if the Reload Beacon does not exist
2. Deletes the Reload Beacon
3. Dynamically discovers all currently loaded `lib.*` modules and reloads each via `importlib.reload()`
4. Calls `projects.init()` and `tab_data.init()` via `sys.modules` after reload

The module list is not hardcoded — it is derived from `sys.modules` at call time using the `lib.` prefix. This means new modules are picked up automatically.

### `lib/tab_data.py`

The module-level `icons.json` file read is moved into an explicit `init()` function. The module no longer performs I/O at import time. This aligns `tab_data` with `projects` and avoids side effects at import.

### `lib/tabs_first_pass.py`

The inline Attention File reading (previously guarded by `if not tabState["allTabIds"]`) is removed entirely. It is replaced by two sequential calls at the top of the render cycle guard:

```
reload.check()
redraw.check()
```

Reload runs first so that definition files (including icon and project data) are fresh before the Attention File is processed.

### `tab_bar.py`

- `statusbar` import and `statusbar.init()` call are removed
- `tab_data.init()` is added to the startup initialization block alongside `projects.init()`

### `kitty-redraw` script

A `touch` of the Redraw Beacon is added before the existing `kitty @ set-tab-color` call. The beacon is written first so it exists when Kitty processes the render triggered by `set-tab-color`.

### `kitty-reload` script

Fully rewritten to:
1. `touch` the Reload Beacon
2. Call `kitty-redraw`

This replaces both the old `kitty-reload` and `kitty-tab-bar-reload` scripts. `kitty-tab-bar-reload` is deleted.

### `keybindings.conf`

`Alt-R` is changed to use Kitty's `combine` action to run `load_config_file` followed by a background launch of `kitty-reload`. `Alt-Shift-R` is removed and marked TODO.

### `GLOSSARY.md`

- Beacon paths updated to reflect the `kitty/beacons/` layout
- **Redraw Beacon** added as a term
- **Hard Reload Beacon** removed (merged into Reload Beacon)
- **State File** and **Definition File** terms retained from the recent update

## Testing Decisions

Good tests verify external behavior, not implementation details. They do not assert on internal state that is not observable from outside the module. Tests mock collaborators (filesystem, external processes) rather than reproducing their internal behavior.

### CLI tests (Bats)

**`kitty-redraw.bats`** (update existing):
- Verify the Redraw Beacon is created at the correct path
- Verify `kitty @ set-tab-color` is called with the correct arguments
- Verify no output on success
- Verify non-zero exit if `kitty` is unreachable
- Prior art: existing `kitty-redraw.bats`, `kitty-tab-attention-add.bats`

**`kitty-reload.bats`** (new):
- Verify the Reload Beacon is created at the correct path
- Verify `kitty-redraw` is called
- Verify no output on success
- Prior art: `kitty-redraw.bats`

### Python tests (pytest)

**`test_redraw.py`** (new):
- `check()` with beacon present: Attention File read, `tabState["attentionIds"]` populated, beacon deleted
- `check()` with beacon absent: no file reads, `tabState["attentionIds"]` unchanged, no error
- `check()` with beacon present but Attention File absent: `attentionIds` set to empty set, beacon deleted
- Prior art: `test_projects.py`

**`test_reload.py`** (new):
- `check()` with beacon present: beacon deleted, `importlib.reload` called on `lib.*` modules, `projects.init()` called, `tab_data.init()` called
- `check()` with beacon absent: no-op
- Prior art: `test_projects.py`

**`test_tab_data.py`** (new):
- `init()` populates icon data from mocked JSON
- `init()` can be called multiple times without error
- Prior art: `test_projects.py`

**`test_tab_bar.py`** (update):
- Replace `test_init_statusbar_called_on_first_draw` with `test_init_tab_data_called_on_first_draw`
- Keep all other existing tests

## Out of Scope

- Statusbar reimplementation — `statusbar.py` is left untouched; only its import is removed from `tab_bar.py`
- Redraw beacon check via a background timer — deliberately removed; all beacon checks are render-cycle-driven
- Any changes to `kitty-tab-attention-add` or `kitty-tab-attention-remove` — they already call `kitty-redraw`, which is correct
- Changes to `test_projects.py` or `test_colors.py` — unaffected by this work
- The `_generation` mechanism in `statusbar.py` — irrelevant while statusbar is disabled

## Further Notes

The render cycle timing is safe: `importlib.reload()` updates module `__dict__` objects in-place. A function currently executing in a module continues to access the updated globals via its `__globals__` pointer, which references the same `__dict__`. This means that after `reload.check()` runs inside `first_pass()`, the subsequent `redraw.check()` call sees the freshly reloaded `tabState` from `lib.tabs`. No extra render cycle is needed to stabilize.
