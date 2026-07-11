# PRD — Kitty Tab Bar: Test Coverage

## Problem Statement

The core tab bar rendering pipeline has no tests. `build_tab_data`, `pick_tabs`, `first_pass`, and `second_pass` are the four modules that together decide which tabs are shown, what they look like, and what gets drawn to the screen — yet all four are dark. Changes to icon placement, color assignment, tab selection priority, or state management can only be validated by launching Kitty, which makes iteration slow and regressions invisible. The beacon modules (`redraw`, `reload`) and utility modules (`projects`, `helper`, `tab_data.init`) are already well-covered; the gap is the pipeline itself.

## Solution

Add test suites for the four untested pipeline modules, extending the existing `test_tab_data.py` and creating three new test files. Each module is tested in isolation via mocks, with `tabState` reset between tests. The goal is behavioral coverage: the tests should catch any change to which tabs are selected, what appears in their title, which colors they receive, or what gets drawn to the screen.

## User Stories

1. As a developer, I want tests for `build_tab_data`, so that I can change icon placement, attention/fullscreen flags, and color selection without silent regressions.
2. As a developer, I want tests for `pick_tabs`, so that I can change the tab selection priority or space budget algorithm with confidence.
3. As a developer, I want tests for `first_pass`, so that I know state is populated correctly and beacon checks are triggered at the right moment.
4. As a developer, I want tests for `second_pass` and `draw_tab_item`, so that I know tabs are drawn (or skipped) correctly and the screen cursor is set as expected.

## Implementation Decisions

### `test_tab_data.py` — extend with `build_tab_data` tests

The existing file only covers `init`. Add cases for `build_tab_data`:

- Returns `{}` when `tab` is falsy
- Basic fields: `id`, `name`, `isActive`, `isFullscreen`, `defaultBg`, `separatorBg`
- Title format: `" {icon}{name} "` with surrounding spaces
- Attention icon appended to title when tab ID is in `tabState["attentionIds"]`
- Fullscreen icon appended (with trailing space) when `layout_name == "stack"`
- Active tab: uses `projectData["fg"]` / `projectData["bg"]` when present, falls back to `draw_data.active_fg` / `draw_data.active_bg`
- Inactive tab: uses `projectData["bgInactive"]` / `projectData["bg"]` when present, falls back to inactive draw_data colors
- `separatorFg` equals tab `bg`
- `separatorBg` equals `defaultBg` (set by caller from next tab)

### `test_pick_tabs.py` — new

- `get_tab_width`: returns `len(title) + 1` (separator)
- `get_full_tab_bar_width`: sums all tab widths
- `get_active_tab_index`: returns index of the tab with `isActive == True`
- `pick_tabs_to_display`: all tabs fit → `displayedTabIds == allTabIds`
- `pick_tabs_to_display`: overflow → active tab always included
- `pick_tabs_to_display`: overflow → priority order is active, +1, -1, further before, further after
- `pick_tabs_to_display`: budget exhausted → stops adding tabs
- `pick_tabs_to_display`: positions out of bounds (< 1 or > tab_count) skipped

### `test_tabs_first_pass.py` — new

- First call of a render cycle (empty `allTabIds`) triggers `reload.check()` then `redraw.check()`
- Subsequent calls within same cycle do not re-trigger beacon checks
- Tab data stored in `tabState["manifest"]` keyed by tab ID
- `index` stored on tab data
- Tab ID appended to `allTabIds` once; duplicate calls do not duplicate entries
- `separatorBg` updated to next tab's `bg` when `extra_data.next_tab` is present
- `separatorBg` left at `defaultBg` when there is no next tab
- `pick_tabs_to_display` called when `is_last=True`, not before

### `test_tabs_second_pass.py` — new

- `draw_tab_item`: sets `screen.cursor.fg` and `screen.cursor.bg` from tab data, calls `screen.draw(title)`
- `draw_tab_item`: sets separator colors and calls `screen.draw` a second time
- `second_pass`: tab in `displayedTabIds` → `draw_tab_item` called
- `second_pass`: tab not in `displayedTabIds` → `draw_tab_item` not called
- `second_pass`: `is_last=True` → resets `tabState["allTabIds"]` to `[]`
- `second_pass`: `is_last=True` → calls `draw_statusbar(screen)`
- `second_pass`: `is_last=False` → does not reset or call `draw_statusbar`
- `second_pass`: returns `screen.cursor.x`

## Testing Decisions

- All tests use `pytest` + `pytest-mock`
- `tabState` is reset in a `setup()` fixture in each new test file
- Kitty types (`Screen`, `TabBarData`, `DrawData`, `ExtraData`) are mocked with `MagicMock`
- `build_tab_data` tests mock `lib.tab_data.projects.get` and `lib.tab_data._icons` directly
- `pick_tabs` tests populate `tabState` directly with synthetic manifests
- `first_pass` tests mock `reload.check`, `redraw.check`, `build_tab_data`, and `pick_tabs_to_display`
- `second_pass` tests mock `draw_statusbar` and `draw_tab_item` where appropriate
- No real file I/O, no real Kitty process

## Out of Scope

- `statusbar.py` — unused code, no tests planned
- `helper.debug` — dev utility, not behavioral
- `tab_bar.draw_tab` — already covered by `test_tab_bar.py`
- `redraw.check`, `reload.check`, `projects`, `tab_data.init` — already covered
