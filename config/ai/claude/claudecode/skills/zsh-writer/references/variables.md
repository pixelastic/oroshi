# Variables

- Use `local` for all variables, even if not in a function.
- DO NOT split `local` from its assignment — always `local var="$(cmd)"`, never `local var; var="$(cmd)"`
- DO NOT use `|| return` after a local assignment; guard with `[[ "$var" == "" ]] && return 0` on the next line instead
- DO NOT do `local raw line worktreePath=""`, define each variable on its own line
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
