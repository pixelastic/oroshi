## Issue 01 — is-zsh-autoload-function

### No teardown/bats_cleanup in test file

```bats
setup() {
  bats_tmp_dir
}
```

**Problem:** Standards agent flagged missing `teardown` calling `bats_cleanup`.
**Reason skipped:** Prior art `is-zsh.bats` (same directory) also omits teardown. Consistent with existing codebase pattern.
