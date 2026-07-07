## TLDR

Move attention state into `tabState`, load the attention file once per render cycle, and rename `parseRawTabData.py` → `tab_data.py` with `build_tab_data()`.

## What to build

### `tabState` schema change

Add `"attentionIds": set()` to the `tabState` dict in `tabs.py`. This makes attention state first-class alongside `manifest`, `allTabIds`, and `displayedTabIds`.

### Load attention once per render cycle

At the start of `first_pass()` in `tabs_first_pass.py`, detect the beginning of a new render cycle (when `allTabIds` is empty — it is reset at the end of each `second_pass`). At that point, read the attention file and store the result as a `set` in `tabState["attentionIds"]`. The file path constant moves here from `tab_data.py`.

This means the attention file is read exactly once per full tab bar redraw, not once per tab per pass.

Also rename `firstPass` → `first_pass` in this file.

### Rename `parseRawTabData.py` → `tab_data.py`

Rename the file and the main function: `parseRawTabData` → `build_tab_data`. The function now reads `tabState["attentionIds"]` directly instead of opening the attention file. Remove all file I/O from this module.

Update the import in `tabs_first_pass.py` and the module name string in `reload.py`.

## Acceptance criteria

- [ ] `tabState` has an `"attentionIds"` key (a `set`) at startup
- [ ] `tabState["attentionIds"]` is populated at the start of each render cycle
- [ ] `build_tab_data()` reads from `tabState["attentionIds"]`, no file I/O
- [ ] `first_pass()` uses snake_case name
- [ ] File `parseRawTabData.py` no longer exists; `tab_data.py` takes its place
- [ ] `reload.py` references `"tab_bar_modules.tab_data"` (not `parseRawTabData`)
- [ ] Attention icon appears on unfocused tabs when Claude finishes
- [ ] Attention icon clears when user sends a message
- [ ] `kitty-tab-bar-reload` reloads without error
