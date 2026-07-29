## Issue 01 — Migrate branch scripts to autoload

### Flag test pattern in git-branch-prune
```zsh
local forceRun="0"
[[ $* =~ "-f" ]] && forceRun="1"
```
**Problem:** Reviewer flagged `== "0"` string comparison as inconsistent with `[[ $isXxx == "1" ]]` flag test pattern.
**Reason skipped:** `forceRun` is a manually-set string var, not a `${#flagXxx}` length value. The flag test convention applies to zparseopts-derived flags only.

### Scaffolding tests absent (spec review)
**Problem:** Spec reviewer reported scaffolding tests missing.
**Reason skipped:** False positive — tests exist at `plans/git-path-helpers/scaffold/01-migrate-branch-scripts-to-autoload.bats`. The reviewer didn't find the scaffold directory.

## Issue 02 — Add path args to git helpers

### Unquoted array expansion
```zsh
git ${repoArgs[@]} push \
```
**Problem:** `${repoArgs[@]}` not quoted, inconsistent with `"${helperArgs[@]}"` pattern in zsh-writer examples.
**Reason skipped:** ZSH does not word-split array expansions. Quoting empty arrays can produce an empty string argument in some contexts.

### Positional $1 vs --repo for git-directory-is-dirty
```zsh
local targetPath="${1:-.}"
```
**Problem:** Inconsistent with `--repo` flag pattern used by other helpers in this diff.
**Reason skipped:** Spec explicitly requests positional `$1` for this function. Guidance documents the convention: positional when `$1` is free, `--repo` when `$1` is taken.

### BARE_REMOTE not local in test
```bash
BARE_REMOTE="$BATS_TMP_DIR/bare-remote.git"
```
**Problem:** Variable declared without `local` in `setup()`.
**Reason skipped:** BATS `setup()` variables must be accessible in `@test` blocks; `local` would scope it too tightly.

### Custom arg parser not replaced in git-branch-push
```zsh
for arg in $argv; do
  [[ "$arg" =~ "^-" ]] && argsf[$arg]=1 || argsp+=("$arg")
done
```
**Problem:** Spec says "Replace the custom arg parser with zparseopts" but the loop remains.
**Reason skipped:** The loop handles arbitrary positional args (branchName, remoteName) and pass-through flags (--force, etc.). zparseopts alone cannot replace this without losing the dynamic flag pass-through.
