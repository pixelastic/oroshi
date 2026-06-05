## TLDR

Rename `kitty-run-claude` to `kitty-helper-claude-start` and add optional prompt argument.

## What to build

Rename the `kitty-run-claude` script to `kitty-helper-claude-start`. The `kitty-helper-` prefix signals it is an internal command passed as `--cmd` to kitty window/tab creators, not a user-facing command.

Add an optional positional argument: if provided, it is passed as the initial prompt to Claude. When absent, Claude starts interactively as before.

Update `kitty-window-toggle-claude` to reference the new name.

## Acceptance criteria

- [ ] `kitty-run-claude` no longer exists; `kitty-helper-claude-start` replaces it
- [ ] `kitty-helper-claude-start` with no argument launches Claude interactively, then falls back to zsh
- [ ] `kitty-helper-claude-start "@/path/to/file.md"` launches Claude with that string as the initial prompt
- [ ] `kitty-window-toggle-claude` references `kitty-helper-claude-start` instead of `kitty-run-claude`
