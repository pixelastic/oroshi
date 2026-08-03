## Issue 01 — colorize-git-status-path helper
### Test file placement
```bats
# File at scripts/bin/fzf/__tests__/fzf-colorize-git-status-path.bats
```
**Problem:** Tests should be in `__lib/__tests__/` per strict sibling rule
**Reason skipped:** Existing convention — all fzf helper tests live in `fzf/__tests__/`, not `fzf/__lib/__tests__/`

### case statement instead of one-liners
```zsh
case "$gitStatus" in
  A) prefix="+"; prefixColor="git-added" ;;
  M) prefix="~"; prefixColor="git-modified" ;;
  D) prefix="-"; prefixColor="git-removed" ;;
esac
```
**Problem:** Conditions reference recommends one-liner state machine pattern
**Reason skipped:** case is more readable for 3-way string match; no nesting, flat structure

### Header style
```zsh
# $ fzf-colorize-git-status-path <filepath> <gitStatus>
```
**Problem:** Reviewer initially flagged missing `$` invocation prefix
**Reason skipped:** Fixed during FIX step; matches sibling `fzf-colorize-path.zsh` format

## Issue 02 — Wire helper into dirty pickers
### Missing scaffolding tests in diff
```bats
# Tests in plans/vfa-fzf-colors/scaffold/02-wire-helper-into-dirty-pickers.bats
@test "dirty --source: modified file has ~ prefix" { ... }
@test "stageable --source: modified file has ~ prefix" { ... }
```
**Problem:** Spec review flagged missing --source prefix tests in __tests__/ dirs
**Reason skipped:** Tests live in scaffold/ per TDD scaffolding convention — review-diff only sees __tests__/ dirs

### Linter/test pass not visible in diff
```
# git-file-lint and git-file-test ran clean during implementation
```
**Problem:** Cannot confirm linter/tests pass from diff alone
**Reason skipped:** Process artifacts, not code — confirmed during implementation step
