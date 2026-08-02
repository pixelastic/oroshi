## TLDR

Create `is-claude` helper script that exits 0 when running inside Claude Code, 1 otherwise.

## What to build

A ZSH script at `scripts/bin/ai/is-claude` that checks the `CLAUDECODE` env var.

- Exit 0 if `CLAUDECODE` is `"1"`
- Exit 1 otherwise
- No output in either case

## Behavioral Tests

Test file: `scripts/bin/ai/__tests__/is-claude.bats`

**When CLAUDECODE=1:**
- exits 0

**When CLAUDECODE is unset:**
- exits 1

**When CLAUDECODE is something else (e.g. "0"):**
- exits 1

## Acceptance criteria

- [ ] `scripts/bin/ai/is-claude` exists and is executable
- [ ] Exits 0 when `CLAUDECODE=1`, exits 1 otherwise
- [ ] No output on stdout or stderr in any case
- [ ] bats tests pass
- [ ] `zsh-lint` passes
