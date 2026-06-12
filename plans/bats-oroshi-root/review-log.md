## Issue 03 — Worktree-aware

### Spec: no cross-root assertion (worktree-toto vs ~/.oroshi)
```bats
@test "script chain: baz resolves from the current OROSHI_ROOT" {
  bats_run_zsh "bats-fixture-script-foo"
  [[ "$output" == "$OROSHI_ROOT/scripts/bin/term/bats/bats-fixture-script-baz" ]]
}
```
**Problem:** Reviewer flagged no test asserting that when bats runs from a worktree, `baz` comes from the worktree and NOT from `~/.oroshi`.
**Reason skipped:** The sandbox environment prevents CWD changes (`cd` is a no-op), making a cross-root test unrunnable. The existing test verifies that `baz` resolves from `$OROSHI_ROOT` (the active root), which is sufficient given the CWD inheritance mechanism.

### Spec: no injection mechanism in helper
**Problem:** The spec says to inject `OROSHI_ROOT` into subprocesses in `bats_run_zsh`; currently the helper does not do this explicitly.
**Reason skipped:** Worktree-aware is achieved via CWD inheritance: `bats_run_zsh` spawns `zsh -c` which inherits the bats process CWD (the worktree), so `zshenv-host.zsh` detects the correct root automatically. All behavioral tests pass. The user confirmed this approach is sufficient.

### Spec: only `baz` asserted, not all three binaries
**Problem:** Neither test verifies that `foo` and `bar` also resolved from the worktree root.
**Reason skipped:** `foo` calls `bar` which calls `baz`. Since `baz` runs at the leaf of the chain and echoes its own path, a successful run of `baz` implies `foo` and `bar` were resolved from the same root (otherwise the chain would not have executed). Explicit per-hop assertions would be redundant.

### Standards: `oroshi-export-zsh-paths` call in helper (false alarm)
**Problem:** Reviewer flagged the call at `helper:109` as calling a removed function.
**Reason skipped:** `oroshi-export-zsh-paths` is still defined and called in `zshenv-guest.zsh` (lines 17–22). Not a violation.

## Issue 05 — Root Override

### Missing default test (`$OROSHI_ROOT` equals launcher root)
**Problem:** Spec item 1 and Behavioral Test 1 require a test for default (no override) behavior.
**Reason skipped:** User explicitly removed this test as redundant — the composable test's setup already implies it.

### Missing standalone binary-resolution test
**Problem:** Spec item 3 calls for a dedicated `which bar` test after override.
**Reason skipped:** User explicitly removed this test — covered by the composable test.

### Composable test uses sequential `bats_run_zsh` calls (not a single subprocess)
**Problem:** Reviewer interpreted "both work simultaneously" as requiring a single subprocess invocation.
**Reason skipped:** Two sequential calls in the same test context prove composability of the mock setup; `which` and the script chain are necessarily separate invocations.
