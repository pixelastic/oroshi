## TLDR

Prune attention entries for tabs that no longer exist at the end of each render cycle.

## What to build

Three coordinated changes:

1. **`state.py`** — add `"activeTabId": None` to `tabState`.

2. **`redraw.py`** — new `cleanup(live_tab_ids)` function. Accepts a collection of live tab IDs (integers). Computes the set of attention entry keys (strings) that have no corresponding live tab. If any stale entries exist, rewrites the attention file keeping only the live entries, then touches the redraw beacon so the next cycle picks up the cleaned state. No write occurs if nothing is stale.

3. **`tabs_second_pass.py`** — at `is_last=True`, before resetting `allTabIds`:
   - Update `tabState["activeTabId"]` to the ID of the currently active tab (read from the manifest).
   - Call `redraw.cleanup(tabState["allTabIds"])`.

## Behavioral Tests

**redraw.cleanup()**
- Removes entries for tab IDs not in the live set
- Preserves entries for tab IDs that are still live
- Does not write to disk when all entries are live
- Handles an empty attention file gracefully
- Handles an empty live set (removes all entries)

**second_pass — activeTabId**
- `tabState["activeTabId"]` is set to the active tab's ID after `is_last`
- Not updated mid-cycle

**second_pass — cleanup call**
- `redraw.cleanup` is called with `allTabIds` at `is_last`
- Not called mid-cycle

## Acceptance criteria

- [ ] `tabState["activeTabId"]` tracks the currently focused tab after each render
- [ ] Closing a tab causes its attention entry to disappear on the next render
- [ ] Attention entries for live tabs are never accidentally removed
- [ ] `test_redraw.py` updated with cleanup tests
- [ ] `test_tabs_second_pass.py` updated and passing
