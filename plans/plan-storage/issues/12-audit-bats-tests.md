## TLDR

Audit and update all remaining bats tests that reference local `plans/` paths.

## What to build

Search the entire test suite for references to local plan paths:
- `plans/` directory references in test setup/assertions
- `$wtRoot/plans/` or similar hardcoded paths
- Tests that create plan fixtures inside worktree directories

For each found test:
1. Update to use `$MOCK_OROSHI_PLANS_DIR` for plan directory creation.
2. Ensure plan fixtures are created in the external location.
3. Verify the test still exercises the correct behavior.

Also add the `MOCK_OROSHI_PLANS_DIR` setup to the shared bats helper (alongside `MOCK_OROSHI_WORKTREES_DIR`), providing a temp directory for plan fixtures in tests.

## Behavioral Tests

**Skip** — this issue updates existing tests, not production code.

## Acceptance criteria

- [ ] No bats test references `$wtRoot/plans/` or creates plans inside worktree dirs
- [ ] Shared bats helper exports `MOCK_OROSHI_PLANS_DIR` pointing to a temp dir
- [ ] All bats tests pass with the external plan directory model
