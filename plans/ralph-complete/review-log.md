## Issue 01 — plan-list-raw
### bats_mock pattern should use env vars not shell function overrides
```bats
git-directory-root() { echo "$BATS_GIT_DIR"; }
bats_mock git-directory-root
```
**Problem:** Spec reviewer flagged that `feedback_bats_stub_path.md` requires env-var style stubs instead of PATH stubs.
**Reason skipped:** That memory note applies to PATH manipulation stubs, not shell function overrides. All existing tests in this repo (`fzf-claude-sessions-source-no-query.bats`, `fzf-fs-directories-ralph-source.bats`, etc.) use the function-override + `bats_mock` pattern for mocking autoloaded functions. This is the established convention.
