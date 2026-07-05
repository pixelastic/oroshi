## Issue 02 — refactors

### No teardown/bats_cleanup in is-zsh-autoload-function.bats

```bats
setup() {
  bats_tmp_dir
}
```

**Problem:** Standards agent flagged missing `teardown` calling `bats_cleanup`.
**Reason skipped:** File was committed in issue 01 (out of scope for this refactor); same pattern already noted in review-log issue 01.

## Issue 01 — is-zsh-autoload-function

### No teardown/bats_cleanup in test file

```bats
setup() {
  bats_tmp_dir
}
```

**Problem:** Standards agent flagged missing `teardown` calling `bats_cleanup`.
**Reason skipped:** Prior art `is-zsh.bats` (same directory) also omits teardown. Consistent with existing codebase pattern.
