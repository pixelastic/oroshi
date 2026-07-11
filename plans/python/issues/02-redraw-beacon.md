## TLDR

Implement the Redraw beacon end-to-end: `kitty-redraw` writes a beacon, `lib/redraw.py` checks it, `tabs_first_pass` delegates to it.

## What to build

Three coordinated changes form a complete vertical slice:

**`lib/redraw.py`** (new module): owns the Redraw Beacon path (`kitty/beacons/redraw`) and the Attention File path (`kitty/attention`). Imports `tabState` from `lib.tabs` at module level. Exposes a single `check()` function: if the beacon exists, read the Attention File into `tabState["attentionIds"]` and delete the beacon; otherwise do nothing.

**`kitty-redraw`** (script update): before the existing `kitty @ set-tab-color` call, `touch` the Redraw Beacon at its new path (`$OROSHI_TMP_FOLDER/kitty/beacons/redraw`). The beacon must be written first so it exists when Kitty processes the triggered render.

**`lib/tabs_first_pass.py`** (update): remove the inline Attention File reading (the `if not tabState["allTabIds"]` block that reads `_ATTENTION_FILE`). Replace it with a call to `redraw.check()` under the same render-cycle guard. `_ATTENTION_FILE` constant and `os` import in this file can be removed.

## Behavioral Tests

**`redraw.check()` — beacon present, Attention File exists**
- `tabState["attentionIds"]` is populated with the tab IDs from the file
- Beacon file is deleted after the call

**`redraw.check()` — beacon present, Attention File absent**
- `tabState["attentionIds"]` is set to an empty set
- Beacon file is deleted after the call

**`redraw.check()` — beacon absent**
- `tabState["attentionIds"]` is unchanged
- No file reads occur

**`kitty-redraw` script**
- Beacon file is created at the correct path before `kitty @ set-tab-color` is called
- `kitty @ set-tab-color --match all active_bg=NONE` is still called
- Silent on success; non-zero exit if `kitty` is unreachable

## Acceptance criteria

- [ ] `lib/redraw.py` created with `REDRAW_BEACON`, `ATTENTION_FILE` constants and `check()`
- [ ] `kitty/beacons/` directory path used for the beacon (not the old root-level path)
- [ ] `kitty-redraw` writes the Redraw Beacon before calling `set-tab-color`
- [ ] `tabs_first_pass.py` calls `redraw.check()` instead of reading the Attention File inline
- [ ] `__tests__/test_redraw.py` created with all behavioral tests above
- [ ] `scripts/bin/kitty/__tests__/kitty-redraw.bats` updated: asserts beacon creation + correct path
- [ ] All existing tests still pass
