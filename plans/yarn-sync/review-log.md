## Issue 02 — context-slug
### git-branch-current not called directly
```zsh
local branchSlug="$(cd "$targetPath" && git-branch-slug)"
```
**Problem:** Spec lists `git-branch-current` as a collaborator but the implementation only calls `git-branch-slug`
**Reason skipped:** `git-branch-slug` already delegates to `git-branch-current` internally; calling both would be redundant

## Issue 04 — submodule-update-all
### Mock body formatting
```bash
git() { echo "$@" > "$BATS_TMP_DIR/git-args.txt"; }
```
**Problem:** `echo` with redirection not split to one-arg-per-line
**Reason skipped:** Mock internals are not production command invocations; the rule targets real code

### Test assertion comments
```bash
[[ "$status" -eq 0 ]]
[[ "$args" == *"-C"* ]]
```
**Problem:** No comments on assertion lines
**Reason skipped:** "Comments for guard clauses" targets production early-return guards, not test assertions

## Issue 05 — file-has-changed-repo
### `; true` vs `|| true` in context-slug
```zsh
local repoName="$(git-github-project-name "$targetPath" 2>/dev/null; true)"
```
**Problem:** `; true` is unconventional, typically `|| true` is used
**Reason skipped:** No documented standard prohibits either form; both suppress err_return in subshell

### `git -C` short form
```zsh
gitCmd=(git -C "$repoPath")
```
**Problem:** calling-commands standard says prefer long-form args
**Reason skipped:** `git -C` has no long-form equivalent

### `_mock_defaults` helper at file scope in context-slug.bats
```bats
_mock_defaults() {
```
**Problem:** feedback_bats_setup_vars says vars go in setup()
**Reason skipped:** Rule targets variable declarations, not helper function definitions; helper varies per test

### Mock duplication in git-submodule-update-all.bats
```bats
git() { echo "$@" > "$BATS_TMP_DIR/git-args.txt"; }
```
**Problem:** Same mock defined in multiple tests, could be in setup()
**Reason skipped:** No rule requires mock deduplication; tests are self-contained
