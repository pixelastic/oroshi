## TLDR

Refactor `preToolUse-Bash` and `preToolUse-Bash-helper.zsh` to use `json-get` and `json-set` instead of raw `jq` subshells.

## What to build

Replace all inline `jq` subshells in the hook and its helper file with calls to `json-get` and `json-set`. No new behavior — this is a pure refactoring.

Targets in `preToolUse-Bash`:
- Reading `inputCommand` from hook input JSON
- Reading `sessionId` from hook input JSON
- Reading the `rejected` commands array from solkan output

Targets in `preToolUse-Bash-helper.zsh` (`markAsAsked`):
- Reading existing `askedCommands` from state file via `json-get`
- Writing updated `askedCommands` back via `json-set --array`

## Scaffolding Tests

None needed — the existing `preToolUse-Bash.bats` behavioral test suite (13 tests) fully covers the hook's observable behavior. Run it after the refactor to confirm nothing broke.

## Acceptance criteria

- [ ] No raw `jq` subshells remain in `preToolUse-Bash` for parsing hook input or solkan output
- [ ] `markAsAsked` in `preToolUse-Bash-helper.zsh` uses `json-get` and `json-set --array`
- [ ] All 13 existing `preToolUse-Bash.bats` tests pass after the refactor
- [ ] Linter clean on all modified files
