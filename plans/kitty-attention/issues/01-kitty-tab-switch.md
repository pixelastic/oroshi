## TLDR

Create `kitty-tab-switch` script to switch the focused tab by Tab ID.

## What to build

Add a new shell script `scripts/bin/kitty/kitty-tab-switch` that takes a Tab ID
as argument and switches focus to that tab via `kitty @ focus-tab --match id:$1`.

The script follows the existing `kitty-tab-*` naming convention. It propagates
errors from `kitty @` directly (no validation, no custom messages).

## Acceptance criteria

- [ ] `kitty-tab-switch {tabId}` switches focus to the specified tab
- [ ] Non-zero exit code if the tab doesn't exist (propagated from kitty)
- [ ] Script follows `set -e` convention
