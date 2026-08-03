## Issue 01 — git-status-raw
### File placement in autoload/git/ instead of autoload/git/file/
```zsh
# File: tools/term/zsh/config/functions/autoload/git/git-status-raw
```
**Problem:** Reviewer flagged that the function is placed in `autoload/git/` while similar helpers like `git-file-list-dirty-raw` live in `autoload/git/file/`.
**Reason skipped:** GUIDANCE.md and issue spec explicitly state `git-status-raw` goes in `autoload/git/`, not `autoload/git/file/`. This is a higher-level abstraction over the file-specific `-raw` functions.

## Issue 03 — migrate dirty-raw consumers
### Mixed filepath/filePath casing across files
```zsh
local filepath=$splitLine[1]   # fzf-git-files-dirty, git-file-list-dirty
local filePath=$splitLine[1]   # git-file-edit, git-file-lint, git-file-test, complete-git-files-dirty
```
**Problem:** Inconsistent variable casing across consumer files
**Reason skipped:** Pre-existing inconsistency not introduced by this diff; each file kept its original convention

### function keyword style
```zsh
function fzf-source() {        # added by linter
function displayZshAndBatsLintErrors() {  # added by linter
```
**Problem:** `function name()` vs `name()` declaration style differs from skill examples
**Reason skipped:** No explicit rule in standards; auto-applied by zsh-lint --fix

## Issue 04 — migrate stageable/staged consumers
### Completion output still uses colon separator
```zsh
echo "$suggestion:$statusString[$fileStatus[$suggestion]]"
```
**Problem:** `complete-git-files-dirty-stageable` line 32 still uses `:` as output separator
**Reason skipped:** This is the ZSH completion display format (description separator), not raw input parsing — out of scope of the `▮` migration