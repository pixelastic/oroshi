## TLDR

Add a `[filters.pytest]` block to `filters.toml` so RTK strips pytest header noise and passing-test lines, leaving only failures.

## What to build

Add a `[filters.pytest]` block to the RTK filter config. It matches `^python-test\b`, strips ANSI codes, and removes the following line patterns:
- `^=+ test session starts` — opening header separator
- `^platform ` — Python/pytest version line
- `^rootdir:` — project root path
- `^configfile:` — config file path
- `^plugins:` — pytest plugins list
- `^collected \d+` — collected items count
- ` PASSED$` — individual passing test lines
- `^=+ \d+ passed in` — all-passed footer line

When all output is stripped (all tests passed), the filter emits `"All tests passed."`.

FAILED lines, failure details, the short test summary section, and mixed footers (e.g. `1 failed, 2 passed in 0.42s`) are kept as-is.

Add two integration tests to `rtk.bats` using real `.py` fixture files. Prior art: existing `rtk bats` and `rtk yarn run test` integration tests in the same file, which create real fixture files and assert on filtered output.

## Behavioral Tests

**All tests pass**
- `rtk python-test` on an all-passing `.py` file → output is exactly `"All tests passed."`
- Exit code is 0

**Some tests fail**
- `rtk python-test` on a file with one passing and one failing test → output contains failure details
- Output does not contain `PASSED`
- Output does not contain header lines (`platform`, `rootdir`, `configfile`, `collected`)
- Exit code is 1

## Acceptance criteria

- [ ] `rtk python-test` on an all-passing file outputs exactly `"All tests passed."`
- [ ] `rtk python-test` on a failing file shows failure details and no `PASSED` lines
- [ ] Header lines (`platform`, `rootdir`, `configfile`, `plugins`, `collected N items`) are absent from output
- [ ] All existing `rtk.bats` tests still pass
- [ ] `bats-lint` passes on `rtk.bats`
