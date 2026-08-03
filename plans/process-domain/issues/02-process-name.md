## TLDR

Add `process-name` — get executable name for a PID from `/proc/PID/comm`.

## What to build

Create `tools/term/zsh/config/functions/autoload/system/process/process-name`.

The function takes a single PID argument and reads `/proc/<pid>/comm`. Outputs the executable name (e.g. `claude`, `zsh`). Supports `--reply` flag to set `$REPLY` instead of echoing. Returns 1 with no output if the PID doesn't exist.

Note: `/proc/PID/comm` truncates at 15 characters — this is accepted.

Uses `setopt local_options err_return` and `zparseopts` for flag parsing.

## Behavioral Tests

File: `tools/term/zsh/config/functions/autoload/system/process/__tests__/process-name.bats`

**Existing process:**
- returns the executable name for $$ (which is "bash" in bats)

**--reply flag:**
- sets $REPLY to the executable name without echoing

**Missing process:**
- returns 1 for a bogus PID
- produces no output for a bogus PID

## Acceptance criteria

- [ ] `process-name $$` outputs `bash`
- [ ] `process-name --reply $$` sets `$REPLY` to `bash` with no stdout
- [ ] `process-name 9999999` returns 1
- [ ] All tests pass via `bats`
- [ ] `zsh-lint` passes
- [ ] `bats-lint` passes
