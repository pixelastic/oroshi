## TLDR

Inject `CLAUDE_IS_SUBAGENT=1` via preToolUse-Bash hook when `agent_id` is present, and create the `is-claude-subagent` helper.

## What to build

Two pieces that form a single feature:

### Hook injection

Modify `tools/ai/claude/config/hooks/preToolUse-Bash` to read `agent_id` from the input JSON. When present, prefix the command with `export CLAUDE_IS_SUBAGENT=1;` before passing it to the output helpers (`autoApprove`, `askWithReason`, `askWithAutoAccept`).

The injection must happen early, before the command reaches Solkan or RTK, so that the final `updatedInputCommand` carries the prefix regardless of the permission decision path.

### `is-claude-subagent` helper

A ZSH script at `scripts/bin/ai/is-claude-subagent` that checks the `CLAUDE_IS_SUBAGENT` env var.

- Exit 0 if `CLAUDE_IS_SUBAGENT` is `"1"`
- Exit 1 otherwise
- No output in either case
- Include a comment block explaining that `CLAUDE_IS_SUBAGENT` is NOT a native Claude Code env var — it is injected by the preToolUse-Bash hook when `agent_id` is present in the hook's stdin JSON

## Behavioral Tests

### Hook tests

Add to `tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats`:

**When input JSON contains agent_id:**
- output command is prefixed with `export CLAUDE_IS_SUBAGENT=1;`

**When input JSON does not contain agent_id:**
- output command is unchanged (no prefix)

### Helper tests

Test file: `scripts/bin/ai/__tests__/is-claude-subagent.bats`

**When CLAUDE_IS_SUBAGENT=1:**
- exits 0

**When CLAUDE_IS_SUBAGENT is unset:**
- exits 1

**When CLAUDE_IS_SUBAGENT is something else (e.g. "0"):**
- exits 1

## Acceptance criteria

- [ ] preToolUse-Bash hook prefixes commands with `export CLAUDE_IS_SUBAGENT=1;` when `agent_id` is in input JSON
- [ ] `scripts/bin/ai/is-claude-subagent` exists and is executable
- [ ] `is-claude-subagent` has a comment explaining the injection mechanism
- [ ] Exits 0 when `CLAUDE_IS_SUBAGENT=1`, exits 1 otherwise
- [ ] No output on stdout or stderr in any case
- [ ] All bats tests pass (hook + helper)
- [ ] `zsh-lint` passes on all modified/new files
