# Loops

- DO NOT use `while read` and `IFS`
- Use `for rawLine in ${(f)rawOutput}; do ... done` instead
- Use `"${(@f)var}"` to preserve empty lines

## Default

```zsh
# Standard
for rawLine in ${(f)rawOutput}; do
  local splitLine=(${(@ps/▮/)rawLine})
  local name="$splitLine[1]"
  local hash="$splitLine[2]"
done
```

## If keeping empty lines is important

```
for line in "${(@f)porcelain}"; do
  [[ "$line" == "" ]] && continue
  [[ "$line" == worktree\ * ]] && worktreePath="${line#worktree }"
done
```
