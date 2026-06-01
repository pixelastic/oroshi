## Problem Statement

When the `preToolUse-Bash` hook rejects a command (not in the allowlist), it currently shows the user a 2-option dialog (Allow / Deny) with the rejected command name displayed. This is useful for building the allowlist, but it lacks a third option: "always allow for this session". When Claude is in the middle of a task and repeatedly needs a command that is not yet allowlisted, the user must approve it one-by-one every time — there is no way to say "yes, for the rest of this session".

## Solution

Introduce a session state that tracks which binaries have already triggered an **ask user — first time** dialog in the current session. The hook uses this state to choose between two distinct user-facing behaviors:

- **ask user — first time** — 2-option dialog (Allow / Deny) with the rejected binary name shown. The exception case: used when the binary has never been seen in this session and the user needs to understand what is blocked.
- **ask user** — 3-option dialog (Allow / Allow for session / Deny) without a reason. The default case: used when the user has already been informed about this binary and may want to session-allow it.

The rule is: multiple binaries rejected → always **ask user — first time**. Single binary rejected and never seen before → **ask user — first time**. Single binary rejected and already seen in this session → **ask user**.

## User Stories

1. As a user, I want to see which binary is blocked when a new command is rejected, so that I can decide whether to allow it or add it to the allowlist.
2. As a user, I want to be able to allow a command for the entire session without being asked again, so that Claude can complete a task that requires a non-allowlisted tool.
3. As a user, I want the "allow for session" option to appear only after I have already been informed about the rejection, so that I am not bypassing safety without understanding why.
4. As a user, I want multi-command pipelines that contain multiple rejected binaries to always show me the full list of blocked commands, so that I can understand the complete scope of what is being asked.
5. As a user, I want the hook to recover gracefully if the session state file is missing or corrupt, so that the dialog still appears and I am not blocked.
6. As a user, I want the session state to persist only for the current session (not across sessions), so that session-allow decisions do not accidentally carry over.

## Implementation Decisions

### Glossary update (done first)

The GLOSSARY.md is updated before any code changes. The existing `ask user` term is split into two:

| Term | `permissionDecision` | Condition | User sees |
|------|---------------------|-----------|-----------|
| **auto-approve** | `allow` | Solkan allows | No dialog |
| **ask user** | `defer` | Solkan rejects: single binary already seen in this session | 3-option dialog (includes "allow for session") — default case |
| **ask user — first time** | `ask` | Solkan rejects: multiple binaries, OR single binary seen for the first time | 2-option dialog + rejected binary name — exception case |

The 4-cases table (Solkan × RTK) is updated to reflect the new outcomes. The GLOSSARY format follows the established vocabulary-entry style with `_Avoid:` annotations.

### Session state

- Stored at `/tmp/oroshi/claude/sessions/{sessionId}/state.json`
- `sessionId` comes from the `session_id` field of the hook's JSON input
- Structure: `{ "preToolUse": { "Bash": { "askedCommands": ["wget", "python"] } } }`
- Namespaced under `preToolUse.Bash` for extensibility (other hooks or fields can coexist)
- Written only when the decision is **ask user — first time** (not for ask user)
- All rejected binaries from a single invocation are written, even on multi-reject
- If the file or its parent directory does not exist, it is created
- If the file is unreadable or contains invalid JSON, the fallback is an empty state (treat all commands as first-time)

### Decision logic

```
if solkan allows:
  → auto-approve

rejected = solkan.commands.rejected

if len(rejected) > 1:
  → ask user — first time (reason: all rejected binaries listed)
  → write all rejected binaries to askedCommands

// Single binary rejected:
if rejected[0] in state.preToolUse.Bash.askedCommands:
  → ask user (no permissionDecisionReason)
else:
  → ask user — first time (reason: rejected[0])
  → write rejected[0] to askedCommands
```

### Output contracts

**auto-approve**: unchanged from current implementation.

**ask user — first time**:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "❌ <rejected binary or list> ❌",
    "updatedInput": { "command": "<rewritten command>" }
  }
}
```

**ask user**:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "defer",
    "updatedInput": { "command": "<rewritten command>" }
  }
}
```
Note: `permissionDecisionReason` is intentionally absent for ask user. Including it with `defer` was tested and caused a hook error in Claude Code v2.1.84.

### Environment variable overrides

Two env vars control file paths (for testing isolation):
- `CLAUDE_HOOKS_LOG_DIR` — existing var, controls debug log location. Now overridable (previously hardcoded).
- `CLAUDE_SESSIONS_DIR` — new var, defaults to `/tmp/oroshi/claude/sessions`

## Testing Decisions

Tests are BATS tests on the `preToolUse-Bash` hook. A good test calls `_run_hook` with controlled mock scripts and checks the JSON output. Tests do not inspect internal state (how jq was called, what was written to disk) except when the specific behavior being tested IS the side effect (e.g. "session state file is created").

**Mock scripts** (named after what solkan returns, not the hook's decision):
- `mock-solkan-allow` — solkan allows (exit 0, isAllowed true)
- `mock-solkan-reject-single` — solkan rejects one binary: `wget` (exit 1)
- `mock-solkan-reject-multi` — solkan rejects two binaries: `wget`, `curl` (exit 1)

**`_run_hook` helper** passes `CLAUDE_SESSIONS_DIR=$BATS_TEST_TMPDIR` and `CLAUDE_HOOKS_LOG_DIR=$BATS_TEST_TMPDIR` to isolate all file writes per test.

**New tests to add:**

1. `ask user — first time` when single binary rejected, no session state exists
2. `ask user — first time` when single binary rejected, binary not yet in session state
3. `ask user` (`defer`) when single binary rejected, binary already in session state
4. `ask user — first time` when multiple binaries rejected, even if all are already in session state
5. Session state file is created after an `ask user — first time` decision
6. Session state contains the rejected binary after an `ask user — first time` decision
7. All binaries from a multi-reject are written to session state
8. `ask user` output does not contain `permissionDecisionReason`

**Prior art**: existing `preToolUse-Bash.bats` — same `_run_hook` pattern, same mock script structure.

## Out of Scope

- Session state cleanup (not needed — `/tmp` is cleared on system reboot)
- SessionStart hook for cleanup
- `systemMessage` field (tested during exploration, causes hook errors in current Claude Code version)
- Any changes to solkan, RTK, or the allowlist format

## Further Notes

During exploration, `permissionDecision: "ask"` was found to show a 2-option dialog (Allow / Deny) and `permissionDecision: "defer"` shows a 3-option dialog (Allow / Allow for session / Deny). The `systemMessage` top-level field was tested as a way to show the rejection reason alongside the 3-option dialog but caused a "PreToolUse:Bash hook error" in Claude Code v2.1.84 and was abandoned.

The hook must always exit 0. Error paths (missing session file, jq failure) fall back to safe defaults silently.
