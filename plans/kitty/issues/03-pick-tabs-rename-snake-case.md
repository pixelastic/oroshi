## TLDR

Rename `pickTabsToDisplay.py` → `pick_tabs.py` and snake_case all remaining functions across `tabs_second_pass.py`, `reload.py`, and `tab_bar.py`.

## What to build

### Rename `pickTabsToDisplay.py` → `pick_tabs.py`

Rename the file. Rename all functions inside to snake_case:
- `pickTabsToDisplay` → `pick_tabs_to_display`
- `getTabWidth` → `get_tab_width`
- `getFullTabBarWidth` → `get_full_tab_bar_width`
- `getActiveTabIndex` → `get_active_tab_index`

Also calls `get_statusbar_width()` (already renamed in Issue 01) — confirm the call site uses the new name.

Update the import in `tabs_first_pass.py` and the module name string in `reload.py`.

### `tabs_second_pass.py`

- `secondPass` → `second_pass`
- `drawTab` → `draw_tab_item` (avoids shadowing Kitty's own `draw_tab` callback)

### `reload.py`

- Update `"tab_bar_modules.pickTabsToDisplay"` → `"tab_bar_modules.pick_tabs"`
- `reloadTabBar` → `reload_tab_bar`

### `tab_bar.py`

Update calls to `first_pass()` and `second_pass()` (renamed in Issues 01–02).
No signature change — these are the internal dispatch calls inside `draw_tab`.

## Acceptance criteria

- [ ] File `pickTabsToDisplay.py` no longer exists; `pick_tabs.py` takes its place
- [ ] All functions in `pick_tabs.py` use snake_case
- [ ] `tabs_second_pass.py` uses `second_pass()` and `draw_tab_item()`
- [ ] `reload.py` references `"tab_bar_modules.pick_tabs"` and `reload_tab_bar`
- [ ] `tab_bar.py` dispatches to `first_pass()` and `second_pass()`
- [ ] No camelCase function names remain anywhere in `tab_bar_modules/`
- [ ] Tab overflow behavior (too many tabs) still works — active tab always visible
- [ ] `kitty-tab-bar-reload` reloads without error
