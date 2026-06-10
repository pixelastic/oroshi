## TLDR

Add `[filters.yarn]` to `filters.toml` so RTK filters Vitest output for `yarn run test`, and cover it with tests.

## What to build

Add a `[filters.yarn]` entry to `tools/ai/rtk/config/filters.toml`. This filter is applied by the RTK binary at execution time when the hook runs `rtk yarn run test ...`. The `match_command` field ensures the filter only activates for `yarn run test` invocations, not other yarn commands.

Filter rules (from prototype against real aberlaas/Vitest output):
- `strip_ansi = true`
- Strip: lines starting with `✓` (passing tests), `RUN` header, `Start at` and `Duration` timing lines, `✘ Tests are failing` (redundant), all-passing summary lines matching `^\s*(Test Files|Tests)\s+\d+ passed`
- `on_empty = "All tests passed."`

On failure, RTK keeps: `❯` file/describe headers, `×` failing test lines, the `Failed Tests` separator block, the `FAIL` block with AssertionError and diff, source context lines, and mixed summary lines (e.g. `1 failed | 1 passed`).

Add two test cases to `tools/ai/rtk/__tests__/rtk.bats` following the pattern of the existing `rtk bats` tests. The `setup()` already copies `filters.toml` into `$BATS_TMP_DIR` and sets `XDG_CONFIG_HOME` — the new tests use this same setup with `.js` fixtures.

Also delete `tools/ai/rtk/__tests__/vitest-demo/` — this directory was created during prototyping and must not be committed.

## Behavioral Tests

**All-passing**
- `rtk yarn run test <all-passing-js-file>` exits 0
- output equals exactly `"All tests passed."`

**Failing**
- `rtk yarn run test <failing-js-file>` exits 1
- output contains failure details (e.g. `AssertionError` or `not ok` equivalent)
- output does not contain `✓` (passing test lines are suppressed)

## Acceptance criteria

- [ ] `[filters.yarn]` entry present in `filters.toml` with correct `match_command`, strip rules, and `on_empty`
- [ ] `rtk yarn run test <all-passing>` outputs exactly "All tests passed."
- [ ] `rtk yarn run test <failing>` exits 1 and contains failure details without `✓` lines
- [ ] `tools/ai/rtk/__tests__/vitest-demo/` directory deleted
- [ ] All tests pass (`bats` + `bats-lint` + `yarn run test`)
