## PRD

[Unified PreToolUse-Bash Hook](PRD.md)

## What to build

Create `preToolUse-Bash-rtk` — a subscript that rewrites a bash command to its RTK token-efficient equivalent.

It receives the raw command as `$1`, calls `rtk`, and prints the final command to stdout. If RTK has no rewrite, it prints the original unchanged. Exit code is always 0 on success; any non-zero exit means no rewrite — caller treats stdout as original.

Script lives at `config/ai/claude/claudecode/hooks/preToolUse-Bash-rtk`.

Tests live at `scripts/bin/__tests__/preToolUse-Bash-rtk.bats`. Write tests first (red), then implement.

## Acceptance criteria

- [ ] prints the original command unchanged when RTK has no equivalent (`echo hello` → `echo hello`)
- [ ] prints the rewritten command when RTK rewrites (`git status` → `rtk git status`)
- [ ] is idempotent: a command already prefixed with `rtk` passes through unchanged (`rtk git status` → `rtk git status`)

## Blocked by

None — can start immediately.
