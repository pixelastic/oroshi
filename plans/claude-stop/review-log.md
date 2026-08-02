## Issue 01 — is-claude
### Potentially unnecessary bats_tmp_dir
```bash
setup() {
  bats_tmp_dir
}
```
**Problem:** `bats_tmp_dir` called in setup but `$BATS_TMP_DIR` not directly used in tests.
**Reason skipped:** `bats_mock_env` may use it internally; all existing test files follow this pattern for consistency.
