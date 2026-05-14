# Calling commands

- Prefer long-form args (`--type`, not `-t`)
- One arg per line when multiple args
- Exception: common short-form idioms inside `$(...)` are fine (`jq -r`, `head -1`, `tail -1`).

## Example
```zsh
# ✅
fd \
  --type file \
  --glob "*.md" \
  /path

# ❌
fd -t f -g "*.md" /path
```
