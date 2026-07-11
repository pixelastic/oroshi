## TLDR

Implement the Reload beacon end-to-end: `kitty-reload` writes a beacon, `lib/reload.py` checks it and reloads all modules, `tabs_first_pass` calls it before Redraw.

## What to build

**`lib/reload.py`** (refactored): owns the Reload Beacon path (`kitty/beacons/reload`). Exposes a single `check()` function: if the beacon exists, delete it first (prevent double-trigger), then dynamically reload all currently loaded `lib.*` modules via `importlib.reload()` (no hardcoded list — iterate `sys.modules`), then call `projects.init()` and `tab_data.init()` via `sys.modules`. If the beacon is absent, do nothing. The existing `reload_tab_bar()` function and `TAB_BAR_MODULES` list are removed.

**`kitty-reload`** (full rewrite): `touch` the Reload Beacon at `$OROSHI_TMP_FOLDER/kitty/beacons/reload`, then call `kitty-redraw`. This replaces both the old `kitty-reload` (which polled for a beacon via a 1s timer) and `kitty-tab-bar-reload` (which wrote a different beacon). The script is otherwise silent.

**`kitty-tab-bar-reload`** (deleted): no longer needed; `kitty-reload` subsumes it.

**`lib/tabs_first_pass.py`** (update): add a call to `reload.check()` immediately before the existing `redraw.check()` call. Reload runs first so definition files are fresh when the Attention File is read.

**`lib/statusbar.py`** (no change): the file is left exactly as-is. Only its import is removed (handled in issue 04).

## Behavioral Tests

**`reload.check()` — beacon present**
- Beacon is deleted at the start of the call
- `importlib.reload` is called for each `lib.*` module in `sys.modules`
- `projects.init()` is called after reload
- `tab_data.init()` is called after reload

**`reload.check()` — beacon absent**
- No modules are reloaded
- No init functions are called

**`kitty-reload` script**
- Reload Beacon is created at the correct path
- `kitty-redraw` is called
- Silent on success

## Scaffolding Tests

`tabs_first_pass` calls `reload.check()` before `redraw.check()` within the render-cycle guard.

## Acceptance criteria

- [ ] `lib/reload.py` refactored: `check()` with dynamic module discovery, no hardcoded list
- [ ] `lib/reload.py` deletes beacon before reloading (prevents double-trigger)
- [ ] `lib/reload.py` calls `projects.init()` and `tab_data.init()` via `sys.modules` after reload
- [ ] Old `reload_tab_bar()` and `TAB_BAR_MODULES` removed from `lib/reload.py`
- [ ] `kitty-reload` script fully rewritten: beacon + `kitty-redraw`
- [ ] `kitty-tab-bar-reload` script deleted
- [ ] `tabs_first_pass.py` calls `reload.check()` before `redraw.check()`
- [ ] `__tests__/test_reload.py` created with all behavioral and scaffolding tests above
- [ ] `scripts/bin/kitty/__tests__/kitty-reload.bats` created
- [ ] All existing tests still pass
