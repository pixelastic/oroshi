# Variables

- Use `local` for all variables, even if not in a function.
- Use `isSomething` or `hasSomething` for booleans
- Assign default value and overwrite later
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
