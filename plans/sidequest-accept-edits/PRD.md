## Problem Statement

When sidequest creates a worktree and Kitty tab, Claude launches without `--permission-mode acceptEdits`. The user has to manually approve every edit in sidequest sessions, unlike Ralph sessions which auto-accept.

## Solution

Make `kitty-helper-claude-start` a transparent passthrough — all arguments forwarded directly to `claude`. Then have `sidequest-end` pass `--permission-mode acceptEdits` in the command string.

## User Stories

1. As a developer starting a sidequest, I want Claude to auto-accept edits, so that the sidequest session flows without manual approval interruptions.
2. As a developer using `kitty-window-toggle-claude`, I want the default behavior unchanged (no auto-accept), so that my general-purpose Claude sessions still require approval.
3. As a developer writing a new caller of `kitty-helper-claude-start`, I want to pass any claude flags through transparently, so that I don't need to modify the helper for each new flag.

## Implementation Decisions

- `kitty-helper-claude-start` becomes a pure passthrough: replace single-arg prompt handling with `"$@"` forwarded to `claude`. No flag parsing in the helper.
- `sidequest-end` changes its `--cmd` string from `kitty-helper-claude-start @$filepath` to `kitty-helper-claude-start --permission-mode acceptEdits @$filepath`.
- The `${=kittyCommand}` word-splitting in `kitty-tab-create` handles this correctly — none of the arguments contain spaces (slugs are sanitized basenames, claude flags are single words).
- `kitty-tab-create` is not modified.
- `kitty-window-toggle-claude` is not modified — it calls `kitty-helper-claude-start` with no args, so behavior is unchanged.

## Testing Decisions

Both modified modules have existing bats test files. Tests should verify external behavior only (what args reach `claude`, what command string reaches `kitty-tab-create`).

- **kitty-helper-claude-start**: verify that all positional args are forwarded to `claude` as-is, including multi-arg scenarios. Prior art: `scripts/bin/kitty/__tests__/kitty-helper-claude-start.bats`.
- **sidequest-end**: verify the command string passed to `kitty-tab-create` includes `--permission-mode acceptEdits`. Prior art: `scripts/bin/ai/sidequest/__tests__/sidequest-end.bats`.

## Out of Scope

- Fixing the pre-existing word-splitting limitation in `kitty-tab-create` (filepaths with spaces would break, but this is not introduced by this change).
- Adding `--permission-mode acceptEdits` to `kitty-window-toggle-claude`.
- Adding flag parsing or validation to `kitty-helper-claude-start` — it stays a dumb passthrough.

## Further Notes

The transparent passthrough design means any future caller can pass any `claude` flag without modifying the helper.
