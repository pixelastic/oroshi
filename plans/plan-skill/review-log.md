## Issue 01 — plan-start script
### Empty variable guards
```zsh
local root="$(git-directory-root)"
local currentBranch="$(git-branch-current)"
local slug="$(git-branch-slug "$currentBranch")"
```
**Problem:** No guards on potentially empty variables before passing to `jo`
**Reason skipped:** `prd-end` has identical pattern; these git helpers always return values in a valid repo context. Adding guards diverges from the source script without functional benefit.

### bats_disable_worktree_aware
```bash
bats_run_zsh "plan-start"
```
**Problem:** Tests mock `git-directory-root` to return `/repo` (outside worktree) without `bats_disable_worktree_aware`
**Reason skipped:** Tests don't `cd` outside the worktree; all collaborators are mocked. The helper is only needed when tests actually navigate outside the worktree.
