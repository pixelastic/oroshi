## TLDR

Create `claude-stop` script that terminates the calling Claude Code main session using the `is-claude` and `is-claude-subagent` helpers.

## What to build

A ZSH script at `scripts/bin/ai/claude-stop`.

**Guards (silent exit 0):**
1. `is-claude` fails → not in Claude, exit 0
2. `is-claude-subagent` succeeds → in a subagent, exit 0

**Kill logic:**
1. Walk up the process tree from `$PPID` via `/proc/PID/stat` (field 4 = ppid)
2. At each step, read `/proc/PID/comm`
3. First process with `comm == "claude"` → send SIGTERM to that PID
4. Exit 0 after sending SIGTERM (fire-and-forget)
5. If the chain reaches PID 1 without finding `claude` → print error to stderr, exit 1

## Behavioral Tests

Test file: `scripts/bin/ai/__tests__/claude-stop.bats`

**When not in Claude (is-claude fails):**
- exits 0, no kill sent

**When in a subagent (is-claude-subagent succeeds):**
- exits 0, no kill sent

**When in main Claude session:**
- walks ppid chain and sends SIGTERM to the `claude` process

**When claude process not found in chain:**
- exits 1, prints error to stderr

## Acceptance criteria

- [ ] `scripts/bin/ai/claude-stop` exists and is executable
- [ ] Silent exit 0 when not in Claude
- [ ] Silent exit 0 when in a subagent
- [ ] Sends SIGTERM to the first `claude` ancestor process
- [ ] Exit 1 with stderr message when `claude` not found in ancestor chain
- [ ] bats tests pass
- [ ] `zsh-lint` passes
