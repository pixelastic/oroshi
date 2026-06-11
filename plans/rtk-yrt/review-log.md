## Issue 02 — yarn/vitest filter

### Missing `local` on `FILTERS_TOML` and `FIXTURE_DIR` in `setup()`

```bash
FILTERS_TOML="$BATS_TEST_DIRNAME/../config/filters.toml"
...
FIXTURE_DIR="$BATS_TEST_DIRNAME/.bats-fixtures/$slug"
```

**Problem:** Reviewer flagged these as missing `local` per the zsh-writer "all function vars local" rule.

**Reason skipped:** In bats, `setup()`, `@test`, and `teardown()` run as sequential phases in the same subprocess. A `local` variable set in `setup()` goes out of scope before `@test` or `teardown()` runs. These variables intentionally persist across phases and must NOT use `local`. The pre-existing `FILTERS_TOML` follows the same pattern for the same reason.
