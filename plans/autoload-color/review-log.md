## Issue 03 — better-ls ZSH conversion

### Missing teardown + bats_cleanup
```bats
bats_load_library 'helper'

setup() {
  bats_tmp_dir
  ...
}
```
**Problem:** Reviewer flagged missing `teardown()` with `bats_cleanup`.
**Reason skipped:** The `helper` library already provides a default `teardown()` that calls `bats_cleanup`. Redeclaring it would be boilerplate — consistent with `better-rm.bats`, `fzf-colorize-path.bats`, and all other test files in the codebase.

### Weak coverage of non-autoload case
**Problem:** Reviewer flagged that test 2 "works only by accident" because the mock `exa` unconditionally writes `$LS_COLORS` to a file.
**Reason skipped:** This is correct behavior — the mock IS called unconditionally (the guard only controls what goes into `LS_COLORS`, not whether `exa` is called). The `bats_mock_env "LS_COLORS" ""` baseline ensures the assertion is deterministic.

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
