## TLDR

Guarantee that `bats_mock_oroshi_root` overrides `OROSHI_ROOT` for data/config reading inside the subprocess — without affecting binary resolution — verified with the `foo → bar → baz` fixture.

## What to build

Extend `tools/term/bats/config/__tests__/helper.bats` with Root Override tests.

Reuse the `foo → bar → baz` fixture. For Root Override tests, `baz` echoes `$OROSHI_ROOT`. The test calls `bats_mock_oroshi_root "/tmp/test-root"`, then calls `foo`, and asserts the output is `/tmp/test-root`.

Write tests covering:
1. Default (no override): `$OROSHI_ROOT` inside the subprocess equals the launcher's oroshi root
2. After override: `$OROSHI_ROOT` equals the overridden value
3. After override: binary resolution is unaffected — `which bar` still returns a path inside the worktree, not inside the overridden root

The third test is the critical orthogonality check between Root Override and Worktree-aware.

Implement any necessary changes to `bats_mock_oroshi_root` in `tools/term/bats/config/helper` to ensure the override does not bleed into binary resolution. The two mechanisms — where binaries come from and what `OROSHI_ROOT` the script sees — must be fully independent.

## Behavioral Tests

- Default (no override): `$OROSHI_ROOT` inside subprocess equals the launcher's oroshi root
- After `bats_mock_oroshi_root "/tmp/test-root"`: `baz` outputs `/tmp/test-root`
- After Root Override: `which bar` still returns a path inside the current worktree (binary resolution unaffected)
- Root Override and Worktree-aware are composable: both work simultaneously in the same test

## Acceptance criteria

- [ ] All Root Override tests pass in `helper.bats`
- [ ] Binary resolution verified independent of Root Override
- [ ] Orthogonality between Root Override and Worktree-aware confirmed by test
- [ ] Default behavior (no override) verified by test
