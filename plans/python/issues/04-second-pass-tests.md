## TLDR

Create `test_tabs_second_pass.py` covering tab drawing decisions and end-of-cycle teardown in `second_pass`.

## What to build

Create `tools/term/kitty/config/__tests__/test_tabs_second_pass.py`. Tests use a `MagicMock` screen and populate `tabState["manifest"]` and `tabState["displayedTabIds"]` directly. `draw_statusbar` is mocked to avoid pulling in statusbar state.

## Behavioral Tests

**`draw_tab_item`**
- Sets `screen.cursor.fg` to `tab_data["fg"]`
- Sets `screen.cursor.bg` to `tab_data["bg"]`
- Calls `screen.draw` with `tab_data["title"]`
- Sets `screen.cursor.bg` to `tab_data["separatorBg"]` for the separator
- Sets `screen.cursor.fg` to `tab_data["separatorFg"]` for the separator
- Calls `screen.draw` a second time for the separator glyph

**`second_pass` — display filter**
- Tab whose ID is in `displayedTabIds` → `draw_tab_item` called
- Tab whose ID is not in `displayedTabIds` → `draw_tab_item` not called

**`second_pass` — end-of-cycle teardown (`is_last=True`)**
- `tabState["allTabIds"]` is reset to `[]`
- `draw_statusbar` is called with `screen`

**`second_pass` — mid-cycle (`is_last=False`)**
- `tabState["allTabIds"]` is not reset
- `draw_statusbar` is not called

**`second_pass` — return value**
- Returns `screen.cursor.x`

## Acceptance criteria

- [ ] New file `__tests__/test_tabs_second_pass.py` created
- [ ] All tests pass (`python-test __tests__/test_tabs_second_pass.py`)
- [ ] `tabState` reset in fixture between tests
- [ ] `draw_statusbar` mocked
- [ ] Lint passes (`python-lint --fix __tests__/test_tabs_second_pass.py`)
