# Variables

- Use `local` for all variables, even if not in a function.
- Use `isSomething` or `hasSomething` for booleans
- Use `UPPER_CASE` for constants.
- Use `local myVar="$(my-command)"`, not `local myVar; myVar="$(my-command)"`
- DO NOT do `local raw line worktreePath=""`, define each variable on its own line
- Assign default value and overwrite later

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
