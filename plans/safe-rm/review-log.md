## Issue 02 — rm-for-claude dirs
### find -type f short arg
```zsh
local diskFilesRaw="$(find "$absolutePath" -type f 2>/dev/null)"
```
**Problem:** `find -type f` uses short arg instead of long-form
**Reason skipped:** `find` has no long-form equivalent for `-type`; same category as documented exceptions (mkdir -p, sed -n, etc.)

### Manual for loop for flag detection
```zsh
for arg in "$@"; do
  [[ "$arg" == "--recursive" ]] && isRecursive=1
  [[ "$arg" == -* && "$arg" != --* && "$arg" == *[rR]* ]] && isRecursive=1
done
```
**Problem:** Should use `zparseopts` instead of manual loop
**Reason skipped:** Function must preserve `$@` verbatim for `/bin/rm`; `zparseopts -D` would consume args. Same pattern used in pre-existing code.

### Batch check uses per-file grep
```zsh
if ! echo "$headFiles" | grep --quiet --line-regexp --fixed-strings "$relDiskFile"; then
```
**Problem:** Per-file grep loop instead of true batch comparison
**Reason skipped:** Spec says "not per-file git calls" — data gathering is batched via `find` + `git ls-tree`; the comparison loop avoids N git invocations which was the intent.
