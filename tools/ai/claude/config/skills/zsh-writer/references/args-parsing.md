# Args parsing

- DO NOT use `while` / `shift` to parse args
- Use `zparseopts -E -D` (no `zmodload` needed — `zparseopts` is an autoloadable builtin)
- Assign arg values to clear variables

## Example

```zsh
zparseopts -E -D \
  -force=flagForce \
  -separator:=flagSeparator

local isForce=${#flagForce}
local separator=${flagSeparator[2]}
local target="$1"
```
