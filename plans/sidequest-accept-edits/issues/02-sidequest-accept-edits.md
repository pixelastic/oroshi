## TLDR

Pass `--permission-mode acceptEdits` from sidequest-end so Claude auto-accepts edits in sidequest sessions.

## What to build

In `scripts/bin/ai/sidequest/sidequest-end`, change the `--cmd` string from:

`kitty-helper-claude-start @$filepath`

to:

`kitty-helper-claude-start --permission-mode acceptEdits @$filepath`

## Behavioral Tests

Prior art: `scripts/bin/ai/sidequest/__tests__/sidequest-end.bats`

**Valid file: --cmd includes --permission-mode acceptEdits**
- The `--cmd` string passed to `kitty-tab-create` contains `--permission-mode acceptEdits` before the prompt filepath

Update the existing test "valid file: calls kitty-tab-create with filepath as prompt in --cmd" to expect the new command string.

## Acceptance criteria

- [ ] `sidequest-end` passes `--permission-mode acceptEdits` in the `--cmd` string
- [ ] Existing sidequest-end tests updated and passing
- [ ] `zsh-lint` passes
