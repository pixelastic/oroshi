## TLDR

Add `--cmd` flag to `kitty-tab-create` to allow a custom startup command.

## What to build

Extend `kitty-tab-create` with an optional `--cmd <command>` flag. When not provided, the default command is `zsh` (preserving existing behavior). When provided, the given command is run in the new tab instead.

This mirrors the `--cmd` support already present in `kitty-window-create`.

## Acceptance criteria

- [ ] `kitty-tab-create "title"` still opens a tab running `zsh` (no regression)
- [ ] `kitty-tab-create "title" --cmd "kitty-helper-claude-start"` opens a tab running `kitty-helper-claude-start`
- [ ] `--cmd` supports arguments, e.g. `--cmd "kitty-helper-claude-start @/tmp/file.md"`
