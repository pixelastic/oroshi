## TLDR

Test that script and function chains resolve from `~/.oroshi` when outside any worktree.

## What to build

Add an integration test to `tools/term/zsh/config/__tests__/zshenv-host.bats` that verifies the default worktree-aware behavior when the current directory is not inside any oroshi worktree.

The test should:
1. `cd` to `$BATS_TMP_DIR` in the test body (bash, not inside `bats_run_zsh`)
2. Call `bats_run_zsh "bats-fixture-script-foo"` and assert the output path contains `$HOME/.oroshi`
3. Call `bats_run_zsh "bats-fixture-function-foo"` and assert the output path contains `$HOME/.oroshi`

Both assertions (script + function) go in a single `@test` block — do not create separate tests.

This uses `bats_run_zsh` (integration), not `run_bare_zsh` (unit). Both patterns coexist in this file.

## Behavioral Tests

**Non-worktree directory uses default OROSHI_ROOT**
- outside any worktree, script chain resolves from ~/.oroshi
- outside any worktree, function chain resolves from ~/.oroshi

## Acceptance criteria

- [ ] Test passes: script fixture output contains `$HOME/.oroshi`
- [ ] Test passes: function fixture output contains `$HOME/.oroshi`
- [ ] `bats zshenv-host.bats` passes (all existing + new tests)
