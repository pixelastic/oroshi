# Header

Header should contain a short documentation of what the script does and how to
call it.

It also contains a protection against error (`set -e` or `err_return`)

## Default (for autoloaded function)

```zsh
# One-line description
# Usage:
# $ function-name arg        # What this does
# $ function-name arg --flag # With flag
setopt local_options err_return
```

## For scripts

```zsh
#!/usr/bin/env zsh
# One-line description
# Usage:
# $ function-name arg        # What this does
# $ function-name arg --flag # With flag
set -e
```
