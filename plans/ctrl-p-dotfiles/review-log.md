# Review Log

## Issue 01 — filetypes-key

### Skipped: `[ ]` vs `[[ ]]` in bats status checks

**Finding:** Standards agent flagged `[ "$status" -eq 0 ]` as a hard violation, claiming `[[ ]]` should be used per testing reference.

**Dismissed because:** All existing bats tests in this codebase (`filetypes-build.bats`, `filetypes-load-definitions.bats`, etc.) use `[ "$status" -eq 0 ]`. This is the established codebase convention. The `[[ ]]` note in zsh-writer/testing.md refers to zsh `[[ ]]` conditions in production code, not bats assertions.
