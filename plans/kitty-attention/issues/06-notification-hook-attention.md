## TLDR

Make the `notification` hook add a typed attention icon when Claude is waiting for tool approval.

## What to build

Update `tools/ai/claude/config/hooks/notification` to add attention when Claude needs tool approval:

1. Resolve the current tab ID from `KITTY_WINDOW_ID` via `kitty-window-tab-id` (same pattern as the `stop` hook).
2. Check focus via `kitty-tab-focused`: if the tab is already focused, skip the attention add.
3. If unfocused, call `kitty-tab-attention-add "$tabId" --type notification`.

The existing `audio-play-oroshi` call and `exit 2` are preserved unchanged.

Guard the attention block: skip entirely when `KITTY_WINDOW_ID` is unset.

## Behavioral Tests

**notification hook**
- Calls `kitty-tab-attention-add --type notification` when `KITTY_WINDOW_ID` is set and the tab is not focused
- Does not call `kitty-tab-attention-add` when the tab is focused
- Does not call `kitty-tab-attention-add` when `KITTY_WINDOW_ID` is unset
- Still plays the audio notification sound regardless of focus state

## Acceptance criteria

- [ ] Approval requests show the `notification` attention icon on unfocused tabs
- [ ] No icon added when the Claude tab is already focused
- [ ] Audio notification unaffected
- [ ] Bats tests written and passing
