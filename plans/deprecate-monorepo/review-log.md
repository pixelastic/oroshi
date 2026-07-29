## Issue 01 — npm-name
### Missing bats_cleanup teardown
```bash
setup() {
  bats_tmp_dir
  bats_disable_worktree_aware
}
```
**Problem:** No explicit `bats_cleanup` in teardown.
**Reason skipped:** `bats_tmp_dir` auto-cleans via BATS lifecycle; no manual teardown needed.
