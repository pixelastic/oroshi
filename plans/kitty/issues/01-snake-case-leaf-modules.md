## TLDR

Rename all functions in `colors.py`, `projects.py`, and `statusbar.py` to snake_case, and update every call site.

## What to build

Rename the following functions to snake_case:

- `colors.py`: `getCursorColor` → `get_cursor_color`
- `projects.py`: `getProjectData` → `get_project_data`, `initProjectList` → `init_project_list`
- `statusbar.py`: `initStatusbar` → `init_statusbar`, `refreshStatusbar` → `refresh_statusbar`, `statusbarUpdate` → `update_statusbar_item`, `checkForForcedRefresh` → `check_for_forced_refresh`, `checkForForcedReload` → `check_for_forced_reload`, `drawStatusbar` → `draw_statusbar`, `getStatusbarWidth` → `get_statusbar_width`

Update every call site in the same pass:
- `projects.py` calls `get_cursor_color` (was `getCursorColor`)
- `statusbar.py` calls `get_cursor_color`, `get_project_data` (internal + cross-module)
- `reload.py` calls `init_project_list`, `init_statusbar`
- `tab_bar.py` calls `init_project_list`, `init_statusbar`

Internal call sites within `statusbar.py` (e.g. `statusbarUpdate` calling `refreshStatusbar`) must also be updated.

## Acceptance criteria

- [ ] All functions in `colors.py`, `projects.py`, `statusbar.py` use snake_case names
- [ ] No remaining call site uses the old camelCase names
- [ ] `reload.py` and `tab_bar.py` updated to use new names
- [ ] Kitty reloads without error (`kitty-tab-bar-reload`)
- [ ] Status bar items (cpu, ram, clock) still render correctly
- [ ] Project colors still apply to the active tab
