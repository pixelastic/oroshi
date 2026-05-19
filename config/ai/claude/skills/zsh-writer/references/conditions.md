# Conditions

- DO NOT nest multiple if/else
- Use the return early pattern (put guard clauses at top)
- Add comments explaining what clause is being guarded
- Use one-liners for state machines (`[[ cond ]] && var=$val` is ok)
- Guard clauses use `[[ "$var" == "" ]] && return/continue`, not `-n`, `-z` not `||`.
- Use `==` in `[[ ]]` rather than `=`

## Example

```zsh
# Return early if sound is disabled
sound-mode-is-enabled || exit 0

# Return early if var is empty
[[ "$worktreePath" == "" ]] && return 1

# State machine
local color=$COLOR_DEFAULT
[[ $isDefault == "1" ]] && color=$COLOR_VERSION_DEFAULT
[[ $isCurrent == "1" ]] && color=$COLOR_VERSION_CURRENT
```
