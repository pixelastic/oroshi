## TLDR

Test that `bats_disable_worktree_aware` prevents re-detection and keeps inherited binaries, plus cleanup.

## What to build

Add an integration test to `tools/term/zsh/config/__tests__/zshenv-host.bats` that verifies the disable mechanism locks OROSHI_ROOT and PATH/fpath to inherited values.

The test should:
1. Create a real oroshi worktree (same pattern as issue 02)
2. Export `MOCK_OROSHI_WORKTREES_DIR` inline
3. Overwrite `bats-fixture-script-baz` and `bats-fixture-function-baz` in the new worktree to echo a custom string
4. Call `bats_disable_worktree_aware`
5. `cd` to the new worktree in the test body
6. Call `bats_run_zsh "bats-fixture-script-foo"` and assert output contains `$OROSHI_ROOT` (the inherited worktree, not the new one)
7. Call `bats_run_zsh "bats-fixture-function-foo"` and assert output contains `$OROSHI_ROOT`

Both assertions (script + function) go in a single `@test` block — do not create separate tests.

Also remove the planning comments (lines 13-28) from `tools/term/bats/config/__tests__/helper.bats` — this is the last issue, so housekeeping happens here.

## Behavioral Tests

**Disable worktree-aware keeps inherited root**
- with worktree-aware disabled, script chain resolves from inherited OROSHI_ROOT despite cd into a different worktree
- with worktree-aware disabled, function chain resolves from inherited OROSHI_ROOT despite cd into a different worktree

## Acceptance criteria

- [ ] Test passes: script fixture output contains `$OROSHI_ROOT` path, not custom string
- [ ] Test passes: function fixture output contains `$OROSHI_ROOT` path, not custom string
- [ ] Planning comments removed from `helper.bats`
- [ ] `bats zshenv-host.bats` passes (all existing + new tests)
- [ ] `bats helper.bats` still passes after comment removal
