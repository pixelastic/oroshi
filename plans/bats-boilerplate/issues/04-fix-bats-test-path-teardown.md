## TLDR

Fix `teardown_file` failure in `bats-test-path.bats` — the `rm -rf "$ZDOTDIR"` exits non-zero and bats treats it as a test failure.

## What to build

In `scripts/bin/term/bats/__tests__/bats-test-path.bats`:

1. **Investigate why `rm -rf` fails.** The `setup_file` creates a temp dir, exports it as `ZDOTDIR`, and writes a `.zshenv` into it. The `teardown_file` tries `[[ -d "${ZDOTDIR:-}" ]] && rm -rf "$ZDOTDIR"`. Possible causes: directory already removed by `bats_cleanup`, permissions, or the `&&` short-circuit returning 1 when `ZDOTDIR` is empty (because `setup_file` can early-return on line 7).

2. **Fix the teardown_file** so it doesn't fail. The `[[ -d ... ]] && rm -rf ...` pattern returns 1 when the test is false — bats with `set -e` treats that as a failure. Likely fix: use `if/then/fi` or `|| true`.

3. **Check if this file still needs `setup_file`/`teardown_file` at all.** The tests call `bats-test-path` via `run`, which doesn't inherit ZDOTDIR. Evaluate whether the ZDOTDIR workaround is still needed.

## Behavioral Tests

- `teardown_file` should not cause a test failure
- All 6 existing tests should keep passing

## Acceptance criteria

- [ ] `bats bats-test-path.bats` reports 0 failures
- [ ] No `teardown_file failed` in output
