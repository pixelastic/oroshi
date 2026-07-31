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

## Issue 02 — plan-end script
### `local` in script with shebang
```zsh
local planDirectory="$1"
```
**Problem:** Reviewer flagged `local` as semantically wrong at script top-level
**Reason skipped:** variables.md explicitly says "Use `local` for all variables, even if not in a function"; plan-start follows the same pattern

### Mock pattern "dead code"
```bash
git() { :; }
bats_mock git
```
**Problem:** Reviewer claimed mock function definitions are dead code overwritten by bats_mock
**Reason skipped:** bats_mock uses `declare -f "$@"` to export the function body, then unsets locally — the pattern is correct and tests pass

### Raw git add/commit usage
```zsh
git add "$planDirectory"
git commit --message "$commitMessage"
```
**Problem:** Reviewer flagged raw porcelain instead of existing helpers
**Reason skipped:** No git-add or git-commit wrappers exist; issue spec explicitly calls for `git add` and `git commit`

### git commit args on one line
```zsh
git commit --message "$commitMessage"
```
**Problem:** Multiple args on one line
**Reason skipped:** Only two args; the standard's example shows continuation for 3+ args — borderline judgement call
