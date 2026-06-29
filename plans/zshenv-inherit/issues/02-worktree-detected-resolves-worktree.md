## TLDR

Test that script and function chains resolve from a detected oroshi worktree when cd'd into it.

## What to build

Add an integration test to `tools/term/zsh/config/__tests__/zshenv-host.bats` that verifies worktree-aware detection routes binaries to the correct worktree.

The test should:
1. Create a real oroshi worktree via `git -C "$OROSHI_ROOT" worktree add --detach "$BATS_TMP_DIR/worktrees/oroshi--bats-test"`
2. Export `MOCK_OROSHI_WORKTREES_DIR="$BATS_TMP_DIR/worktrees"` inline in the test
3. Overwrite `bats-fixture-script-baz` in the new worktree to echo a custom string (e.g., `echo "from-test-worktree"`)
4. Overwrite `bats-fixture-function-baz` in the new worktree to echo the same custom string
5. `cd` to the new worktree in the test body
6. Call `bats_run_zsh "bats-fixture-script-foo"` and assert output equals the custom string
7. Call `bats_run_zsh "bats-fixture-function-foo"` and assert output equals the custom string

Both assertions (script + function) go in a single `@test` block — do not create separate tests.

Also add `git -C "$OROSHI_ROOT" worktree prune` to the teardown function — this is the first test that creates a real worktree and needs cleanup.

## Behavioral Tests

**Detected oroshi worktree uses worktree binaries**
- inside a detected oroshi worktree, script chain resolves from that worktree
- inside a detected oroshi worktree, function chain resolves from that worktree

## Acceptance criteria

- [ ] Test passes: script fixture output matches custom string from the new worktree
- [ ] Test passes: function fixture output matches custom string from the new worktree
- [ ] Teardown includes `git worktree prune` after `bats_cleanup`
- [ ] `bats zshenv-host.bats` passes (all existing + new tests)
