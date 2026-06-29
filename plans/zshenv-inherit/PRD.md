## Problem Statement

Oroshi's zshenv detects whether the current directory is inside an oroshi worktree and automatically switches OROSHI_ROOT, PATH, and fpath to that worktree's binaries. This worktree-aware behavior can now be disabled via `bats_disable_worktree_aware`, but there are no tests verifying the detection, the switching, or the disable mechanism end-to-end.

## Solution

Add integration tests to `zshenv-host.bats` that verify the full worktree-aware lifecycle: default resolution from `~/.oroshi`, detection of a real oroshi worktree, and the disable mechanism that locks inherited binaries.

## User Stories

1. As a developer modifying zshenv, I want a test proving that binaries resolve from `~/.oroshi` when outside any worktree, so that I don't break the default behavior
2. As a developer modifying zshenv, I want a test proving that binaries resolve from a detected oroshi worktree when I cd into it, so that worktree-aware detection is covered
3. As a developer modifying zshenv, I want a test proving that `bats_disable_worktree_aware` prevents re-detection, so that the disable mechanism is covered
4. As a developer writing bats tests, I want confidence that `bats_disable_worktree_aware` works correctly, so that I can safely cd to directories outside the worktree without breaking fixture resolution

## Implementation Decisions

- **All tests in `zshenv-host.bats`**: worktree-aware is a zshenv feature, not a bats helper feature. Mixing unit tests (`run_bare_zsh`) and integration tests (`bats_run_zsh`) in the same file is acceptable.
- **3 tests, each combining script + function assertions**: no separate tests per mechanism — each test asserts both PATH (script chain) and fpath (function chain) in a single test.
- **`cd` in the test body (bash), not inside `bats_run_zsh` argument**: functions autoload from fpath set at zsh startup, so `cd` inside the zsh command doesn't affect function resolution. Doing the `cd` in the test body before `bats_run_zsh` ensures both scripts and functions are affected consistently.
- **Real oroshi worktree**: Test 2 and 3 create a real git worktree of the oroshi repo via `git worktree add --detach` into `$BATS_TMP_DIR/worktrees/oroshi--bats-test`. This avoids recreating zshenv infrastructure (path.zsh, oroshi-reload-path, etc.) in a fake worktree.
- **`MOCK_OROSHI_WORKTREES_DIR` inline per test**: exported only in tests that need it, not in `setup()`, because setting it globally would break existing tests (the bats process CWD would no longer match the mock worktrees dir pattern).
- **Modified fixtures in the new worktree**: Test 2 overwrites `bats-fixture-script-baz` and `bats-fixture-function-baz` in the new worktree to echo a custom string, proving by content (not just path) that the correct worktree's binary was called.
- **Cleanup via `git worktree prune`**: added after `bats_cleanup` in teardown. `bats_cleanup` removes the files; `git worktree prune` cleans up the orphaned git metadata.
- **Remove planning comments**: lines 13-28 in `helper.bats` (the planning comments describing the 4 tests) are deleted since the tests are now implemented elsewhere.
- **Assertion targets**:
  - Test 1 (non-worktree): output path contains `$HOME/.oroshi`
  - Test 2 (worktree detected): output matches custom string written into the modified fixture
  - Test 3 (disable): output path contains `$OROSHI_ROOT` (the inherited worktree, not the one we cd'd into)

## Testing Decisions

- **Prior art**: the existing tests in `zshenv-host.bats` use `run_bare_zsh` to test zshenv-host in isolation. The new tests use `bats_run_zsh` to test the full integration chain. Both patterns coexist in the same file.
- **What makes a good test here**: assert on observable output (which binary was called, what it printed), not on internal state (env var values, PATH entries). The fixture chain foo->bar->baz exists precisely for this purpose.
- **The fixture chain is already tested in `helper.bats`**: the new tests don't re-test the chain itself — they test that the worktree detection mechanism routes to the correct chain.

## Out of Scope

- Testing `bats_mock` or `bats_mock_oroshi_root` interactions with worktree-aware (already covered in `helper.bats`)
- Modifying the worktree-aware detection logic itself (already implemented in zshenv-host.zsh and zshenv-guest.zsh)
- Adding a `bats_disable_worktree_aware` test to `helper.bats` (the helper function is trivial — it just exports an env var)
- Creating a dedicated `zshenv.bats` test file (no matching function name exists)

## Further Notes

- The `bats_disable_worktree_aware` function and `OROSHI_DISABLE_WORKTREE_AWARE` env var are already implemented in the current worktree — this PRD covers only the tests.
- The BATS glossary has been updated to mention the disable mechanism in the Worktree-aware definition.
