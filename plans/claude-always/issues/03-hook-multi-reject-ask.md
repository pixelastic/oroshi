## TLDR

Fix the hook's reject path: multi-reject must return `permissionDecision: "ask"` with the rejected binary list as reason.

## What to build

The hook's current reject path is broken (using `defer` + `systemMessage` from an exploratory test). Restore correct behavior: when solkan rejects one or more binaries, the hook returns `permissionDecision: "ask"` with a `permissionDecisionReason` listing the rejected binaries.

This issue covers the multi-reject case only. Single-reject session logic is handled in issue 04.

**Output contract for ask:**
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

After this issue, every rejection (single or multi) returns `ask`. The ask/escalate distinction for single-reject comes in issue 04.

## Acceptance criteria

- [ ] Hook returns `permissionDecision: "ask"` when solkan rejects any command
- [ ] `permissionDecisionReason` lists all rejected binaries separated by `, `
- [ ] `permissionDecisionReason` is wrapped with `❌ … ❌`
- [ ] `updatedInput.command` contains the RTK-rewritten command (or original if RTK ignores)
- [ ] No `systemMessage` field in the output
- [ ] All existing tests (multi-reject scenarios) pass
- [ ] Hook always exits 0, including on this path
