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
