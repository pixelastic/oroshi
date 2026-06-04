## TLDR

Fix the `bats` RTK filter so `"All tests passed."` is shown when all tests pass, and add integration tests that run `rtk bats` for real.

## What to build

In `tools/ai/rtk/config/filters.toml`, add `"^\\d+\\.\\.\\d+"` to `strip_lines_matching` so the TAP plan line (`1..6`) is stripped alongside the `ok N` lines. Once both are gone, `on_empty` triggers correctly.

Create `tools/ai/rtk/__tests__/rtk.bats` with two integration tests that run `rtk bats <fixture>` against real temporary `.bats` files (created via `printf` into `$BATS_TMP_DIR`):

- **all-pass fixture** — all tests pass → assert `$output = "All tests passed."`
- **failure fixture** — one test fails → assert output contains `not ok`, does not contain a passing `ok N` line

Do not assert on exit code.

## Behavioral Tests

- `rtk bats` on an all-passing file outputs exactly `"All tests passed."`
- `rtk bats` on a file with failures outputs `not ok` lines and suppresses `ok` lines

## Scaffolding Tests

None.

## Acceptance criteria

- [ ] `strip_lines_matching` in `[filters.bats]` includes `"^\\d+\\.\\.\\d+"`
- [ ] `rtk bats <all-pass-fixture>` outputs exactly `All tests passed.`
- [ ] `rtk bats <failure-fixture>` output contains `not ok`
- [ ] `rtk bats <failure-fixture>` output does not contain passing `ok N` lines
- [ ] All bats tests pass
