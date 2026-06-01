## TLDR

Update `preToolUse-Bash-rtk` to delegate the RTK rewrite decision to `rtk-can-rewrite` instead of calling `rtk rewrite` directly.

## What to build

Replace the inline `rtk rewrite` call in `preToolUse-Bash-rtk` with a call to `rtk-can-rewrite`. If it exits 0, prepend `rtk` to the command; otherwise pass the command through unchanged. A `RTK_CAN_REWRITE_CMD` env var allows the hook's tests to inject a mock.

Update the existing bats tests to mock `RTK_CAN_REWRITE_CMD` (exit-0 mock and exit-1 mock) instead of the old `RTK_CMD`-based approach. Three cases: rewrite decision yes → `rtk $cmd`; rewrite decision no → `$cmd` unchanged; command already starts with `rtk` → pass through without calling `rtk-can-rewrite`.

## Acceptance criteria

- [ ] `preToolUse-Bash-rtk` calls `rtk-can-rewrite` instead of `rtk rewrite`
- [ ] `RTK_CAN_REWRITE_CMD` env var overrides the function path for test isolation
- [ ] Running `bats foo.bats` through the hook produces `rtk bats foo.bats`
- [ ] Running `echo hello` through the hook produces `echo hello` unchanged
- [ ] Idempotency: `rtk git status` passes through unchanged without calling `rtk-can-rewrite`
- [ ] All bats tests pass
- [ ] `zshlint` clean
