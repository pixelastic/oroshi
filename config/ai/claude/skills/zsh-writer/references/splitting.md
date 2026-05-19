# Splitting

- Use `▮` (U+25AE) as the default separator
- Use `${(@ps/▮/)line}` to split back (it preserves empty fields)
- Use `${(@s:/:)filepath}` to split a filepath

## Example

```zsh
local parts=(${(@ps/▮/)rawLine})
local first=${parts[1]}
local second=${parts[2]}
```
