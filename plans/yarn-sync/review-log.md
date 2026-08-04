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
