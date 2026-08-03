## TLDR

Add `process-parent` — get parent PID from `/proc/PID/stat` field 4.

## What to build

Create `tools/term/zsh/config/functions/autoload/system/process/process-parent`.

The function takes a single PID argument and reads field 4 (PPID) from `/proc/<pid>/stat`. Outputs the parent PID. Supports `--reply` flag to set `$REPLY` instead of echoing. Returns 1 with no output if the PID doesn't exist.

Uses `setopt local_options err_return` and `zparseopts` for flag parsing.

## Behavioral Tests

File: `tools/term/zsh/config/functions/autoload/system/process/__tests__/process-parent.bats`

**Existing process:**
- returns a numeric PID for $$
- the returned parent PID itself exists (process-exists returns 0 for it)

**--reply flag:**
- sets $REPLY to the parent PID without echoing

**Missing process:**
- returns 1 for a bogus PID
- produces no output for a bogus PID

## Acceptance criteria

- [ ] `process-parent $$` outputs a number
- [ ] The output PID itself exists in `/proc`
- [ ] `process-parent --reply $$` sets `$REPLY` with no stdout
- [ ] `process-parent 9999999` returns 1
- [ ] All tests pass via `bats`
- [ ] `zsh-lint` passes
- [ ] `bats-lint` passes
