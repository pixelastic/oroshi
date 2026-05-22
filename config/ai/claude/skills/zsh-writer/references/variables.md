# Variables

- Use `local` for all variables, even if not in a function.
- Always `local var="$(cmd)"` on one line — never split (`local var; var=...`). `local` exits 0 regardless of the subshell, so guard on the next line: `[[ "$var" == "" ]] && return 1`.
- Use `isSomething` or `hasSomething` for booleans
- Use `UPPER_CASE` for constants.

## Example

```zsh
THRESHOLD=5

local branchName="$1"
local remoteName="origin"
[[ "$2" != "" ]] && remoteName="$(git-branch-name $2)"

# Stop if empty
local repoMain="$(git-worktree-main)"
[[ "$repoMain" == "" ]] && return 1
```
