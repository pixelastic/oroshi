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

## Issue 02 — Wire deprecate-prepare
### Unconditional npm-name call with empty $clonedAt
```zsh
local packageName="$(npm-name "$clonedAt" || true)"
```
**Problem:** Old code guarded on `$clonedAt != ""` before calling helpers; new code calls `npm-name ""` when clonedAt is empty.
**Reason skipped:** `npm-name` returns 1 on missing package.json (handles empty path), `|| true` catches it, no behavioral difference. Adding a guard would duplicate logic npm-name already owns.
