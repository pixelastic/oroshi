# Modifiers

- Prefer ZSH builtins over external commands (`basename`, `dirname`, `realpath`, etc.):
- `:t` not `basename`, `:h` not `dirname`, `:a` not `realpath`, `:r` to strip extension, `:e` for extension only

## Examples

```zsh
# Chaining modifiers
local filepath="/home/tim/docs/notes.md"
local name="${filepath:t:r}"  # notes  (basename then strip extension)

# Array joins and slices
local parts=(a b c d)
local joined="${(j:/:)parts}"    # a/b/c/d
local tail="${parts[2,-1]}"      # (b c d)
local last="${parts[-1]}"        # d
```
