# Args parsing

- DO NOT use `while` / `shift` to parse args
- Use `zmodload zsh/zutil` + `zparseopts -E -D`
- Assign arg values to clear variables

## Example

```zsh
zmodload zsh/zutil
zparseopts -E -D \
  -force=flagForce \
  -separator:=flagSeparator

local isForce=${#flagForce}
local separator=${flagSeparator[2]}
local target="$1"
```
