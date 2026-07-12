## TLDR

Clear the attention icon when the Claude process exits by calling `kitty-tab-attention-remove` in the claude wrapper script.

## What to build

In the `claude` binary wrapper (`scripts/bin/ai/claude`), after the claude binary exits, call `kitty-tab-attention-remove` for the current window's tab. Resolve the tab ID from `KITTY_WINDOW_ID` via `kitty-window-tab-id`, matching the pattern already used in the `stop` hook.

Guard the call: skip it when `KITTY_WINDOW_ID` is unset (non-kitty environment).

## Behavioral Tests

**claude wrapper**
- Calls `kitty-tab-attention-remove` with the resolved tab ID after the binary exits
- Does not call `kitty-tab-attention-remove` when `KITTY_WINDOW_ID` is unset

## Acceptance criteria

- [ ] Closing Claude removes its tab from the attention file
- [ ] Wrapper works correctly in a non-kitty environment (`KITTY_WINDOW_ID` unset)
- [ ] Bats tests written and passing
