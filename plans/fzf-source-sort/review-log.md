## Issue 01 — DFS sort-filepaths

### `local` declared inside `@test` body
```bats
@test "root file appears before subdir file" {
  local expected="root.txt
a/file.txt"
```
**Problem:** Standards agent cited feedback_bats_setup_vars — "all test vars go inside setup()".
**Reason skipped:** That memory applies to file-top-level variables (like `CURRENT`), not per-test locals inside `@test` bodies. Prior art (`simplify-path.bats`) also uses `local` inside test bodies.

### `bats_tmp_dir` without `teardown`/`bats_cleanup`
```bats
setup() {
  bats_tmp_dir
}
```
**Problem:** Testing reference says bats_cleanup should be called in teardown.
**Reason skipped:** Prior art (`simplify-path.bats`, `slugify.bats`) follows the same pattern without teardown. Out of scope for this issue.

### Status not asserted in tests
```bats
bats_run_zsh "sort-filepaths 'a/file.txt'"
[ "$output" = "a/file.txt" ]
```
**Problem:** Testing reference first example always checks `[ "$status" -eq 0 ]`.
**Reason skipped:** Prior art (`simplify-path.bats`) omits status checks. Consistent with existing test style in this codebase.
