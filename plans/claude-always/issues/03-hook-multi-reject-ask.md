## TLDR

Fix the hook's reject path: every rejection must return `ask user — first time` (permissionDecision: "ask") with the rejected binary list as reason.

## What to build

The hook's current reject path is broken (using `defer` + `systemMessage` from an exploratory test). Restore correct behavior: when solkan rejects one or more binaries, the hook returns `permissionDecision: "ask"` with a `permissionDecisionReason` listing the rejected binaries.

This issue covers all rejections as **ask user — first time**. The session-based distinction between `ask user` and `ask user — first time` is introduced in issue 04.

**Output contract for ask user — first time:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "❌ wget, curl ❌",
    "updatedInput": { "command": "<rewritten or original command>" }
  }
}
```

After this issue, every rejection (single or multi) returns `ask user — first time`. The distinction comes in issue 04.

## Acceptance criteria

- [ ] Hook returns `permissionDecision: "ask"` when solkan rejects any command
- [ ] `permissionDecisionReason` lists all rejected binaries separated by `, `
- [ ] `permissionDecisionReason` is wrapped with `❌ … ❌`
- [ ] `updatedInput.command` contains the RTK-rewritten command (or original if RTK ignores)
- [ ] No `systemMessage` field in the output
- [ ] All existing tests (multi-reject scenarios) pass
- [ ] Hook always exits 0 on this path
