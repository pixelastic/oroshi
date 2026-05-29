## Issue 01 — plan-list-raw
### bats_mock pattern should use env vars not shell function overrides
```bats
git-directory-root() { echo "$BATS_GIT_DIR"; }
bats_mock git-directory-root
```
**Problem:** Spec reviewer flagged that `feedback_bats_stub_path.md` requires env-var style stubs instead of PATH stubs.
**Reason skipped:** That memory note applies to PATH manipulation stubs, not shell function overrides. All existing tests in this repo (`fzf-claude-sessions-source-no-query.bats`, `fzf-fs-directories-ralph-source.bats`, etc.) use the function-override + `bats_mock` pattern for mocking autoloaded functions. This is the established convention.

## Issue 03 — complete-plans compdef

### fullPath as _describe key differs from _skills/_git-worktrees pattern
```zsh
echo "${fullPath}:${baseName}"
```
**Problem:** `_skills` and `_git-worktrees` use a short name as key; `complete-plans` uses a full absolute path.
**Reason skipped:** Spec explicitly requires "Selecting a suggestion inserts the full absolute path" — intentional design.

## Issue 02 — fzf-fs-directories-plans rename
### fzf-var-write pwd flagged as dead code
```zsh
local plansDirectory="${rootDirectory}/plans"
fzf-var-write pwd "$plansDirectory"
```
**Problem:** Spec reviewer flagged that `-source` ignores `fzf-var-write pwd` since it calls `plan-list-raw` directly.
**Reason skipped:** `pwd` is consumed by `fzf-fs-directories-plans-prompt` for display purposes — it is not dead code.
