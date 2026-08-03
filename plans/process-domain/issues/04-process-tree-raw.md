## TLDR

Add `process-tree-raw` — walk the ancestor chain as `PID▮name` lines, self first, excluding init.

## What to build

Create `tools/term/zsh/config/functions/autoload/system/process/process-tree-raw`.

The function takes a single PID argument and walks the process tree upward by calling `process-parent` and `process-name` in a loop. Outputs one `PID▮name` line per process, starting with self, walking up through ancestors, stopping before PID 1 (init/systemd).

Supports `--reply` flag to set `$REPLY` instead of echoing. Returns 1 if the starting PID doesn't exist.

Uses `setopt local_options err_return` and `zparseopts` for flag parsing.

## Behavioral Tests

File: `tools/term/zsh/config/functions/autoload/system/process/__tests__/process-tree-raw.bats`

Tests use a chain of scripts created inline in `setup()`:
- `chain-outer` (zsh) calls `chain-middle` (bash) calls `chain-inner` (python3)
- `chain-inner` writes its PID to a temp file and sleeps
- Tests read the PID file, call `process-tree-raw`, then kill the chain in teardown

**Chain walk:**
- first line contains the inner process PID and "python3"
- second line contains "bash"
- third line contains "zsh"
- each line matches the format `NUMBER▮NAME`

**Excludes init:**
- no line contains PID 1

**--reply flag:**
- sets $REPLY with no stdout

**Missing process:**
- returns 1 for a bogus PID

## Acceptance criteria

- [ ] Output starts with self PID and name
- [ ] Walks through the full ancestor chain
- [ ] PID 1 is excluded
- [ ] Each line matches `PID▮name` format
- [ ] `--reply` sets `$REPLY` with no stdout
- [ ] `process-tree-raw 9999999` returns 1
- [ ] All tests pass via `bats`
- [ ] `zsh-lint` passes
- [ ] `bats-lint` passes
