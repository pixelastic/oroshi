## TLDR

Add `process-exists` — check if a PID is alive via `/proc/PID`.

## What to build

Create `tools/term/zsh/config/functions/autoload/system/process/process-exists`.

The function takes a single PID argument and checks if `/proc/<pid>` exists. Returns exit code 0 if the process exists, 1 otherwise. No output, no `--reply` flag — pure guard function.

Uses `setopt local_options err_return`.

## Behavioral Tests

File: `tools/term/zsh/config/functions/autoload/system/process/__tests__/process-exists.bats`

**Existing process:**
- returns 0 for current shell PID ($$)

**Missing process:**
- returns 1 for a bogus PID (9999999)

**No argument:**
- returns 1 when called without arguments

## Acceptance criteria

- [ ] `process-exists $$` returns 0
- [ ] `process-exists 9999999` returns 1
- [ ] `process-exists` (no arg) returns 1
- [ ] All tests pass via `bats`
- [ ] `zsh-lint` passes
- [ ] `bats-lint` passes
