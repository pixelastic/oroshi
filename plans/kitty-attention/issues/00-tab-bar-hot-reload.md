## TLDR

Build a hot-reload system for Kitty tab bar Python so changes to any
`tab_bar_modules/*.py` file take effect immediately without restarting Kitty.

## Problem

`tab_bar.py` imports modules at the top level. Python caches these in
`sys.modules`. Any edit to `statusbar.py`, `tabs.py`, etc. requires a full
Kitty restart to take effect — unusable for iterative development.

`kitty @ load-config` and `ctrl+shift+F5` do not trigger a Python module
reload for the tab bar.

## What to build

### 1 — Make `tab_bar.py` dispatch dynamically

Replace top-level `from tab_bar_modules.xxx import fn` with module-level
imports (`import tab_bar_modules.xxx as xxx`). Call functions as
`xxx.fn()` so that after `importlib.reload(xxx)`, `draw_tab` picks up the
new code on the next render.

### 2 — Add `reloadTabBar()` function

In `tab_bar.py` (or a new `tab_bar_modules/reload.py`):

```python
import importlib, sys

TAB_BAR_MODULES = [
    "tab_bar_modules.colors",
    "tab_bar_modules.helper",
    "tab_bar_modules.projects",
    "tab_bar_modules.tabs",
    "tab_bar_modules.parseRawTabData",
    "tab_bar_modules.pickTabsToDisplay",
    "tab_bar_modules.tabs_first_pass",
    "tab_bar_modules.tabs_second_pass",
    "tab_bar_modules.statusbar",
]

def reloadTabBar():
    for name in TAB_BAR_MODULES:
        if name in sys.modules:
            importlib.reload(sys.modules[name])
    initProjectList()
    initStatusbar()
```

### 3 — Timer cleanup before re-init

`initStatusbar()` calls `add_timer()` — calling it twice accumulates timers.
Before re-init, cancel existing timers. Use one of:

- **Option A**: `kitty.fast_data_types.remove_timer(timer_id)` — check if
  this API exists at runtime
- **Option B**: Generation counter — each timer callback checks a global
  `generation` int; if it doesn't match `current_generation`, it no-ops.
  Increment `current_generation` before reload.

### 4 — Beacon-triggered reload

Reuse or extend `checkForForcedRefresh()` in `statusbar.py` to call
`reloadTabBar()` when the beacon is detected.

New beacon path: `/home/tim/local/tmp/oroshi/kitty-tab-bar-reload`
(separate from `kitty-refresh` to avoid confusion)

### 5 — `kitty-tab-bar-reload` shell script

```zsh
#!/usr/bin/env zsh
touch /home/tim/local/tmp/oroshi/kitty-tab-bar-reload
```

Creates the beacon. The existing 5s polling loop picks it up.

### 6 — Keybinding

In `keybindings.conf`:

```
map ctrl+shift+r send_text all kitty-tab-bar-reload\n
```

Or a kitty `run-shell` action if `send_text` is too indirect.

## Acceptance criteria

- [ ] Edit any file in `tab_bar_modules/` and run `kitty-tab-bar-reload` →
      changes visible in tab bar within 5 seconds, no Kitty restart needed
- [ ] No timer accumulation: running reload multiple times doesn't slow the
      tab bar or spawn duplicate update loops
- [ ] Clock can be enabled/disabled in the manifest and visible after reload
- [ ] `kitty-tab-bar-reload` script exists and is executable
- [ ] Keybinding or command documented

## Scaffolding Tests

No automated tests — this is Python loaded inside Kitty's runtime.
Validate manually by:
1. Enabling clock in manifest → reload → clock appears
2. Disabling clock → reload → clock disappears
3. Reload 5× in a row → verify only one set of timers fires (check cpu/ram
   update frequency stays at 30s, not 6s)
