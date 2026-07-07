## Problem Statement

The Kitty tab bar Python codebase has two structural issues that make it harder to reason about:

1. **Attention state lives outside `tabState`**: the list of tabs needing attention is stored in a flat file and read from disk on every individual tab parse, even though all other tab-related global state lives in `tabState`. This makes the data flow inconsistent and performs redundant file I/O per-tab instead of once per render cycle.

2. **Function names use camelCase instead of snake_case**: all Python functions (e.g. `parseRawTabData`, `firstPass`, `drawTab`, `getCursorColor`) deviate from Python PEP8 convention, making the code harder to read and inconsistent with Kitty's own API (`draw_tab`, `for_layout`, etc.).

## Solution

Refactor the tab bar Python modules to:
- Move attention state into `tabState`, loading the attention file exactly once per render cycle
- Rename all Python functions and filenames to snake_case
- Rename `parseRawTabData` to `build_tab_data` to better reflect its role (it enriches, not just parses)

No behavior change — only structural/naming improvements.

## User Stories

1. As a developer reading `tabs_first_pass.py`, I want attention data to be loaded in one place (the start of a render cycle), so that I don't have to trace file I/O scattered across multiple callsites.
2. As a developer working in any tab bar module, I want all Python functions to use snake_case, so that the code is consistent with PEP8 and Kitty's own API.
3. As a developer reading `tab_data.py`, I want `build_tab_data` to read from `tabState` instead of the filesystem, so that the function is a pure data transformer with no side effects.
4. As a developer looking for the attention loading logic, I want it to live in `tabs_first_pass.py` alongside the rest of the render cycle initialization, so that the render cycle is easy to follow end-to-end.
5. As a developer looking for tab display selection logic, I want the module to be named `pick_tabs.py` instead of `pickTabsToDisplay.py`, so that the filename follows snake_case.

## Implementation Decisions

### Attention in `tabState`

- Add `"attentionIds": set()` to `tabState` in `tabs.py`.
- In `first_pass()`, at the start of each render cycle (detected by `allTabIds` being empty), load the attention file into `tabState["attentionIds"]`.
- `build_tab_data()` reads `tabState["attentionIds"]` directly — no file I/O.
- The attention file path constant moves from `tab_data.py` to `tabs_first_pass.py`.

### Render cycle detection

The existing pattern already uses `allTabIds` as a reset signal: it is cleared at the end of `second_pass`. So `not tabState["allTabIds"]` reliably identifies the first call of a new render cycle.

### Function renames (camelCase → snake_case)

| Old name | New name | Module |
|---|---|---|
| `parseRawTabData` | `build_tab_data` | `tab_data.py` |
| `firstPass` | `first_pass` | `tabs_first_pass.py` |
| `secondPass` | `second_pass` | `tabs_second_pass.py` |
| `drawTab` | `draw_tab_item` | `tabs_second_pass.py` |
| `pickTabsToDisplay` | `pick_tabs_to_display` | `pick_tabs.py` |
| `getTabWidth` | `get_tab_width` | `pick_tabs.py` |
| `getFullTabBarWidth` | `get_full_tab_bar_width` | `pick_tabs.py` |
| `getActiveTabIndex` | `get_active_tab_index` | `pick_tabs.py` |
| `drawStatusbar` | `draw_statusbar` | `statusbar.py` |
| `getStatusbarWidth` | `get_statusbar_width` | `statusbar.py` |
| `initStatusbar` | `init_statusbar` | `statusbar.py` |
| `refreshStatusbar` | `refresh_statusbar` | `statusbar.py` |
| `statusbarUpdate` | `update_statusbar_item` | `statusbar.py` |
| `checkForForcedRefresh` | `check_for_forced_refresh` | `statusbar.py` |
| `checkForForcedReload` | `check_for_forced_reload` | `statusbar.py` |
| `getProjectData` | `get_project_data` | `projects.py` |
| `initProjectList` | `init_project_list` | `projects.py` |
| `getCursorColor` | `get_cursor_color` | `colors.py` |
| `reloadTabBar` | `reload_tab_bar` | `reload.py` |

### File renames

| Old filename | New filename |
|---|---|
| `parseRawTabData.py` | `tab_data.py` |
| `pickTabsToDisplay.py` | `pick_tabs.py` |

`reload.py` references module names as strings — it must be updated to use the new filenames.

### Names kept as-is

- `tabState["manifest"]` — already meaningful, no change
- `statusbarState["manifest"]` — same
- `tab_bar_modules/` directory name — kept
- `draw_tab` in `tab_bar.py` — this is Kitty's required callback name, never touched

## Testing Decisions

This is a pure refactor with no behavior change. The project has no Python test runner — Python modules are tested implicitly by running Kitty itself.

The existing BATS tests for `kitty-tab-attention-add` and `kitty-tab-attention-remove` cover the attention file protocol, which is unchanged. The Claude hook tests (`stop.bats`, `userPromptSubmit.bats`) are also unchanged.

No new tests are written for this refactor.

## Out of Scope

- Behavior changes to the attention system (e.g. cache invalidation strategy, attention for non-Claude tools)
- Statusbar refactoring
- Adding Python tests
- Renaming `tabState["manifest"]` or `statusbarState["manifest"]`
- Renaming the `tab_bar_modules/` directory
- Changing `tab_bar.py`'s `draw_tab` function signature (Kitty API requirement)
