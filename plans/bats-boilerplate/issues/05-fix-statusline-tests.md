## TLDR

Fix 3 failing tests in `statusline.bats` — the test setup uses the old colors API (`COLOR_RED=1`) and the wrong directory (`env/` instead of `dist/`).

## What to build

In `tools/ai/claude/config/__tests__/statusline.bats`:

1. **Fix the colors mock.** The setup creates `env/colors.zsh` with `COLOR_RED=1; COLOR_YELLOW=3` syntax. The statusline script now reads `dist/colors.zsh` and expects an associative array `COLORS[red]`. Create the mock at the correct path with the correct format.

2. **Fix the script invocation.** The test calls `bats_run_zsh "${OROSHI_ROOT}/tools/ai/claude/config/statusline"` but `OROSHI_ROOT` is mocked to a temp dir that doesn't contain the script. Either copy/symlink the script into the temp dir, or use the real path while mocking only external dependencies.

3. **Verify the test expectations still match the script's output format.** The script may have evolved since the tests were written.

## Behavioral Tests

- All 3 tests should pass after the fix
- Tests should properly mock colors and context-badge

## Acceptance criteria

- [ ] `bats statusline.bats` reports 0 failures
- [ ] Tests use the current colors API (`COLORS` associative array, `dist/` path)
