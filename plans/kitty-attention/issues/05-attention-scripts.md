## TLDR

Fix `kitty-tab-attention-add`, update both attention scripts to use `kitty-redraw`, add bats tests.

## What to build

Fix the bug in `kitty-tab-attention-add`: it currently exits early if the
Attention File does not exist. Fix it to create the file and its parent
directory if absent, then proceed normally.

Update both `kitty-tab-attention-add` and `kitty-tab-attention-remove` to call
`kitty-redraw` after modifying the Attention File (replacing the current
`kitty-refresh` call), so the Tab Bar Redraws immediately.

Write bats tests for both scripts.

## Behavioral Tests

**kitty-tab-attention-add:**
- Adding a Tab ID creates the Attention File if it does not exist
- Adding a Tab ID appends it to the Attention File
- Adding the same Tab ID twice does not duplicate it (idempotent)
- Adding a Tab ID triggers a Redraw

**kitty-tab-attention-remove:**
- Removing a Tab ID that is in the Attention File deletes it from the file
- Removing a Tab ID that is not in the file is a no-op
- Removing a Tab ID does not affect other Tab IDs in the file
- Removing is a no-op if the Attention File does not exist

## Acceptance criteria

- [ ] `kitty-tab-attention-add` creates the Attention File and parent dir if absent
- [ ] Both scripts call `kitty-redraw` instead of `kitty-refresh`
- [ ] Bats tests pass for both scripts
- [ ] Scripts linted with `zsh-lint`, tests linted with `bats-lint`
