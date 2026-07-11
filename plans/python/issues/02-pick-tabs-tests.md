## TLDR

Create `test_pick_tabs.py` with full behavioral coverage of the tab selection algorithm.

## What to build

Create `tools/term/kitty/config/__tests__/test_pick_tabs.py`. Tests populate `tabState` directly with synthetic manifests and call the public functions. `get_statusbar_width` is mocked to control available space. No Kitty process involved.

## Behavioral Tests

**`get_tab_width`**
- Returns `len(title) + 1` (title length plus separator)

**`get_full_tab_bar_width`**
- Returns the sum of all tab widths in `allTabIds` order

**`get_active_tab_index`**
- Returns the `index` of the tab whose `isActive` is true

**`pick_tabs_to_display` — all fits**
- When total width ≤ available space, `displayedTabIds` equals `allTabIds`

**`pick_tabs_to_display` — overflow, priority order**
- Active tab always included first
- Tab at active+1 included before active−1
- Tab at active−1 included before tabs further away
- Tabs further before active included from closest to furthest
- Tabs further after active included from closest to furthest

**`pick_tabs_to_display` — budget**
- Stops adding tabs when the next tab would exceed remaining space
- A tab that fits is included even if a later higher-priority tab does not

**`pick_tabs_to_display` — bounds**
- Position 0 (before first tab) is skipped
- Position > tab_count (after last tab) is skipped

**`pick_tabs_to_display` — statusbar headroom**
- Available width is `max(screen_width - statusbar_width, 50)`
- Even with a very wide statusbar, at least 50 chars are available for tabs

## Acceptance criteria

- [ ] New file `__tests__/test_pick_tabs.py` created
- [ ] All tests pass (`python-test __tests__/test_pick_tabs.py`)
- [ ] `tabState` reset in fixture between tests
- [ ] `get_statusbar_width` mocked — no real statusbar state needed
- [ ] Lint passes (`python-lint --fix __tests__/test_pick_tabs.py`)
