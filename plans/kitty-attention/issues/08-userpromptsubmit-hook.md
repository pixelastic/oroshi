## TLDR

Create the `userPromptSubmit` hook that clears Attention when the user replies to Claude.

## What to build

Create a new hook script `tools/ai/claude/config/hooks/userPromptSubmit`.

When invoked, it resolves the current Tab ID from `KITTY_WINDOW_ID` via
`kitty-window-tab-id` and calls `kitty-tab-attention-remove` for that tab.

If `KITTY_WINDOW_ID` is absent, skip silently.

Register the hook in `tools/ai/claude/config/settings.json` under the
`UserPromptSubmit` key (same structure as the existing `Stop` hook entry).
Modify the file in the worktree — do not edit via the `~/.claude/settings.json`
symlink.

## Acceptance criteria

- [ ] Hook script exists at `tools/ai/claude/config/hooks/userPromptSubmit`
- [ ] `UserPromptSubmit` entry added to `tools/ai/claude/config/settings.json`
- [ ] Sending a message to Claude in an Attention tab removes its Attention state
- [ ] Hook is silent and exits 0 when `KITTY_WINDOW_ID` is absent
- [ ] Hook linted with `zsh-lint`
