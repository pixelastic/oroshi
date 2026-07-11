## TLDR

Create `test_tabs_first_pass.py` covering state population and beacon trigger timing in `first_pass`.

## What to build

Create `tools/term/kitty/config/__tests__/test_tabs_first_pass.py`. `first_pass` is the function Kitty calls once per tab per render cycle. Tests mock `build_tab_data`, `reload.check`, `redraw.check`, and `pick_tabs_to_display` so the test only verifies orchestration logic, not the collaborators.

## Behavioral Tests

**Beacon checks — timing**
- `reload.check` is called on the first invocation of a render cycle (when `allTabIds` is empty)
- `redraw.check` is called on the first invocation of a render cycle
- `reload.check` is called before `redraw.check`
- Neither check is called on subsequent invocations within the same cycle (when `allTabIds` is non-empty)

**Manifest population**
- Tab data returned by `build_tab_data` is stored in `tabState["manifest"]` keyed by tab ID
- `index` (passed by Kitty) is stored on the tab data in the manifest

**`allTabIds` tracking**
- Tab ID is appended to `allTabIds` on first call for that tab
- Calling `first_pass` again for the same tab ID does not duplicate the entry

**Separator background**
- When `extra_data.next_tab` is present, `separatorBg` in the manifest is updated to the next tab's `bg`
- When `extra_data.next_tab` is `None`, `separatorBg` is not changed

**End-of-cycle trigger**
- `pick_tabs_to_display` is called when `is_last=True`
- `pick_tabs_to_display` is not called when `is_last=False`

## Acceptance criteria

- [ ] New file `__tests__/test_tabs_first_pass.py` created
- [ ] All tests pass (`python-test __tests__/test_tabs_first_pass.py`)
- [ ] `tabState` reset in fixture between tests
- [ ] `reload.check`, `redraw.check`, `build_tab_data`, `pick_tabs_to_display` all mocked
- [ ] Lint passes (`python-lint --fix __tests__/test_tabs_first_pass.py`)
