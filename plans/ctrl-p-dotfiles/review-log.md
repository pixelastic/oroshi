# Review Log

## Issue 01 — filetypes-key

### Skipped: `[ ]` vs `[[ ]]` in bats status checks

**Finding:** Standards agent flagged `[ "$status" -eq 0 ]` as a hard violation, claiming `[[ ]]` should be used per testing reference.

**Dismissed because:** All existing bats tests in this codebase (`filetypes-build.bats`, `filetypes-load-definitions.bats`, etc.) use `[ "$status" -eq 0 ]`. This is the established codebase convention. The `[[ ]]` note in zsh-writer/testing.md refers to zsh `[[ ]]` conditions in production code, not bats assertions.

## Issue 05 — filetype-group dotfiles

### Skipped: `[ ]` vs `[[ ]]` in bats assertions

```bats
[ "$status" -eq 0 ]
[ "$output" = "config" ]
```
**Problem:** Standards agent flagged POSIX `[ ]` as a hard violation; claimed `[[ ]]` is required in zsh.
**Reason skipped:** Established codebase convention documented in GUIDANCE.md Issue 01 discovery. All bats tests in this repo use `[ ]` for status/output checks.

### Skipped: mock pattern flagged as potentially dead code

```bats
setup() {
  filetypes-load-definitions() {
    typeset -gA FILETYPES
    FILETYPES[_fdignore:group]=config
  }
  bats_mock filetypes-load-definitions
}
```
**Problem:** Spec agent suggested the function definition before `bats_mock` might be dead code.
**Reason skipped:** This is the established pattern in this codebase — `bats_mock` uses the in-scope function definition as the stub body. Identical to `fzf-colorize-path.bats` and `fzf-fs-preview.bats`.
