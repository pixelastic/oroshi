## TLDR

Add session state so single-reject uses `ask user — first time` on first encounter and `ask user` on subsequent ones.

## What to build

Introduce session state to distinguish first-time rejections (exception) from repeat ones (default). The state is a JSON file scoped to the current Claude session.

**Session state location:** `$CLAUDE_SESSIONS_DIR/{sessionId}/state.json`
- `CLAUDE_SESSIONS_DIR` defaults to `/tmp/oroshi/claude/sessions`
- `sessionId` comes from the `session_id` field of the hook's JSON input
- Parent directory is created if it does not exist

**Session state schema:**
```json
{
  "preToolUse": {
    "Bash": {
      "askedCommands": ["wget", "python"]
    }
  }
}
```

**Decision logic:**
```
if len(rejected) > 1:
  → ask user — first time (reason: all rejected binaries)
  → write all rejected binaries to askedCommands

// Single binary rejected:
if rejected[0] in state.preToolUse.Bash.askedCommands:
  → ask user (permissionDecision: "defer", no permissionDecisionReason)
else:
  → ask user — first time (reason: rejected[0])
  → write rejected[0] to askedCommands
```

**Error handling:** if `state.json` is absent, unreadable, or contains invalid JSON, treat `askedCommands` as empty (first-time behavior). Never surface errors to Claude Code — hook always exits 0.

**Output contract for ask user:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "defer",
    "updatedInput": { "command": "<rewritten or original command>" }
  }
}
```
Note: `permissionDecisionReason` is intentionally absent. Including it with `defer` causes a hook error in Claude Code v2.1.84.

**State is written only on `ask user — first time` decisions**, not on `ask user`.

## Acceptance criteria

- [ ] Hook reads `CLAUDE_SESSIONS_DIR` from env with `/tmp/oroshi/claude/sessions` as default
- [ ] Single-reject, no session file → returns `ask user — first time` with reason
- [ ] Single-reject, binary not in `askedCommands` → returns `ask user — first time` with reason
- [ ] Single-reject, binary in `askedCommands` → returns `ask user` (`defer`, no reason)
- [ ] Multi-reject, all binaries already in `askedCommands` → still returns `ask user — first time` with reason
- [ ] After an `ask user — first time` decision, `state.json` exists and contains the rejected binary in `askedCommands`
- [ ] After a multi-reject `ask user — first time`, all rejected binaries are in `askedCommands`
- [ ] `ask user` output does not contain `permissionDecisionReason`
- [ ] Missing or corrupt `state.json` falls back silently to first-time behavior
- [ ] Hook always exits 0
- [ ] 8 new BATS tests covering the above scenarios
