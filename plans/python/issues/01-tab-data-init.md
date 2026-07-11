## TLDR

Move `icons.json` loading from module-level side-effect into an explicit `init()` function in `lib/tab_data.py`.

## What to build

`lib/tab_data.py` currently reads `icons.json` at module level (plain `with open(...)` at the top of the file). This runs I/O at import time, which is a side effect that makes the module hard to test and inconsistent with how `lib/projects.py` loads its own definition file.

Move that read into a new `init()` function. The `_icons` variable is still a module-level dict but is now populated by calling `init()` rather than at import time.

`tab_bar.py` must call `tab_data.init()` in its startup block alongside `projects.init()`, so icons are loaded before the first render cycle.

## Behavioral Tests

**`init()` loads icons**
- After calling `init()` with a mocked JSON file, the module's icon data matches the mocked content
- After calling `init()` twice, the second call overwrites the first (last-write wins)

**No I/O at import time**
- Importing `lib.tab_data` without calling `init()` does not read any file

## Scaffolding Tests

`tab_bar.py` calls `tab_data.init()` once on the first draw (same guard as `projects.init()`).

## Acceptance criteria

- [ ] `lib/tab_data.py` has no I/O at module level
- [ ] `lib/tab_data.py` exposes `init()` which reads `icons.json` and populates `_icons`
- [ ] `tab_bar.py` calls `tab_data.init()` in the startup block
- [ ] `__tests__/test_tab_data.py` created with behavioral and scaffolding tests
- [ ] `__tests__/test_tab_bar.py` updated: `test_init_tab_data_called_on_first_draw` added
- [ ] All existing tests still pass
