## PRD

[Unified PreToolUse-Bash Hook](PRD.md)

## What to build

Create `preToolUse-Bash` — the unified orchestrator that runs both subscripts and merges their results into a single `hookSpecificOutput` JSON response.

It reads Claude Code's hook JSON from stdin, extracts the command, runs both subscripts in parallel (solkan for permission, rtk for rewrite), then emits the correct JSON for one of the four output cases:

| Solkan | RTK      | JSON output                                      |
|--------|----------|--------------------------------------------------|
| allow  | unchanged | `permissionDecision: allow`                     |
| allow  | rewritten | `permissionDecision: allow` + `updatedInput`    |
| ask    | unchanged | *(no permissionDecision, no updatedInput)*      |
| ask    | rewritten | `updatedInput` only                             |

Key decisions encoded here:
- Solkan checks the **original** command (not the RTK-rewritten one)
- `updatedInput` preserves all original `tool_input` fields, updating only `command`
- `updatedInput` is only included when RTK stdout differs from original command
- Subscripts are injected via `PRETOOLUSE_SOLKAN_SCRIPT` / `PRETOOLUSE_RTK_SCRIPT` env vars (default to sibling scripts)
- JSON built with `jq` directly — no `acceptTool()` from hookLib.zsh

Script lives at `config/ai/claude/claudecode/hooks/preToolUse-Bash`.

Tests live at `scripts/bin/__tests__/preToolUse-Bash.bats`. Use mock scripts in `bats_tmp`:
- `mock-solkan-allow`: exits 0
- `mock-solkan-ask`: exits 1
- `mock-rtk-pass`: echoes `$1` unchanged
- `mock-rtk-rewrite`: echoes `rtk $1`

Write tests first (red), then implement.

## Acceptance criteria

- [ ] outputs `permissionDecision: allow` with no `updatedInput` when solkan allows and RTK does not rewrite
- [ ] outputs `permissionDecision: allow` + `updatedInput.command` when solkan allows and RTK rewrites
- [ ] outputs no `permissionDecision` and no `updatedInput` when solkan refuses and RTK does not rewrite
- [ ] outputs `updatedInput.command` but no `permissionDecision` when solkan refuses and RTK rewrites
- [ ] preserves original `tool_input` fields (e.g. `description`) in `updatedInput` when rewriting

## Blocked by

- [issue-001-pretooluse-bash-solkan.md](issue-001-pretooluse-bash-solkan.md)
- [issue-002-pretooluse-bash-rtk.md](issue-002-pretooluse-bash-rtk.md)
