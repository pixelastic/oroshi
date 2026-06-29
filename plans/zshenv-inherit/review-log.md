## Issue 01 — Non-worktree resolves default
### cd outside bats_run_zsh contradicts standard
```bats
cd "$BATS_TMP_DIR"
bats_run_zsh "bats-fixture-script-foo"
```
**Problem:** Standard says cd should be inside `bats_run_zsh`, not in the bash test body.
**Reason skipped:** GUIDANCE.md and PRD explicitly override this for worktree-aware tests — cd in bash body ensures both scripts and functions are affected consistently, since fpath is set at zsh startup.

### Planning comments in helper.bats
```bats
# Test 1: Anywhere on disk (normal test directory), calling the
# bats-fixture-script-foo ensure it calls it from ~/.oroshi
# ...
```
**Problem:** Planning comments left in production test code.
**Reason skipped:** Removal is tracked in issue 03, not issue 01.
