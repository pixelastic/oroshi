---
name: debug-script
description: Use when writing throw-away debug or exploration scripts.
---

# Debug Script

## When to Use

Write a throw-away script when a Bash command is syntactically complex — multi-line, uses subshells, or involves non-trivial pipes.

## Pattern

- **Target folder:** `/tmp/oroshi/claude/scripts/`
- **Naming:** descriptive name, no file extension (e.g. `inspect-hooks`, `dump-state`)
- **Shebang:** first line must be a shebang like `#!/usr/bin/env zsh`
- **Permissions:** `chmod +x` before executing
- **Execution:** call by full path — never `zsh path/to/file`

## ZSH Example

```zsh
#!/usr/bin/env zsh
# Inspect allowlist entries that match a pattern

file="$1"
pattern="$2"

jq --arg p "$pattern" '.[] | select(test($p))' "$file"
```

```sh
chmod +x /tmp/oroshi/claude/scripts/inspect-allowlist
/tmp/oroshi/claude/scripts/inspect-allowlist tools/ai/claude/config/hooks/allowlist.json "scripts"
```

## Node Variant

Same pattern — swap the shebang:

```js
#!/usr/bin/env node
// Inspect allowlist entries that match a pattern
const [,, file, pattern] = process.argv;
const entries = JSON.parse(require('fs').readFileSync(file, 'utf8'));
entries.filter(e => e.includes(pattern)).forEach(e => console.log(e));
```

```sh
chmod +x /tmp/oroshi/claude/scripts/inspect-allowlist
/tmp/oroshi/claude/scripts/inspect-allowlist tools/ai/claude/config/hooks/allowlist.json scripts
```
