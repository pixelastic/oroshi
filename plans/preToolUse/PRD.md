## Problem Statement

When Claude runs a command containing multiple **reject**ed binaries, the hook always shows **ask with reason** — even if the user has already been informed about all of them in the current session. This forces the user to repeatedly dismiss a verbose 2-option dialog for command combinations they've already reviewed, instead of the lighter 3-option dialog that offers "Allow for session".

## Solution

Unify the multi-reject and single-reject decision paths into one. The criterion becomes: "is at least one rejected binary new to this session?" If yes → **ask with reason** (showing only the new binaries). If all have already been seen → **ask with auto-accept**.

## User Stories

1. As a user, I want the hook to show me **ask with reason** only for binaries I haven't seen before, so that I'm not re-informed about commands I've already reviewed.
2. As a user, I want **ask with reason** to display only the new binary names in the reason string, so that I'm not confused by commands I've already consciously evaluated.
3. As a user, when Claude runs a multi-command with several unknown binaries, I want to see all the new ones in a single **ask with reason** dialog, so that I can evaluate them in one step.
4. As a user, when Claude retries a multi-command containing only binaries I've already seen, I want the lighter **ask with auto-accept** dialog, so that I can use "Allow for session" without extra friction.
5. As a user, when a multi-command mixes known and new binaries, I want **ask with reason** to appear (not **ask with auto-accept**), so that I'm always informed before approving anything new.
6. As a user, without an active session, I want the hook to fall back to **ask with reason** for all rejected binaries, so that the conservative default is preserved.

## Implementation Decisions

- The `if multi-reject` early-return block is removed. The single-reject path is extended to cover all reject counts.
- The unified path loads session history, computes `newRejected` (rejected commands absent from history), calls `markAsAsked` for all rejected commands, then decides:
  - `newRejected` is empty → **ask with auto-accept**
  - `newRejected` is non-empty → **ask with reason** with `newRejected` as the reason string (not all rejected)
- `markAsAsked` is called unconditionally before the decision, consistent with the existing single-reject pattern.
- When `sessionId` is empty, `stateFile` is never written and `askedCmds` stays empty, so all rejecteds appear new → **ask with reason** always. No special-casing needed.

## Testing Decisions

Tests cover only the external behavior of the hook (JSON output fields `permissionDecision` and `permissionDecisionReason`), not internal variable names or helper call order.

**Module under test:** `preToolUse-Bash` (the main hook orchestrator).

**Prior art:** existing bats tests for this hook use `bats_mock` to stub `preToolUse-Bash-solkan` and `preToolUse-Bash-rtk`, and seed `state.json` directly to control session history. New tests follow the same pattern.

**Test matrix for the unified reject path (replaces the old "multi-reject: always ask with reason" test):**

| Case | Rejected | History | Expected decision | Expected reason |
|------|----------|---------|------------------|-----------------|
| A — all new | `wget`, `curl` | _(none)_ | `ask` | `❌ wget, curl ❌` |
| B — all seen | `wget`, `curl` | `wget`, `curl` | `defer` | _(none)_ |
| C — mixed | `wget`, `curl`, `newcmd` | `wget`, `curl` | `ask` | `❌ newcmd ❌` |

Existing tests for single-reject (first encounter → `ask`, repeat encounter → `defer`) remain unchanged.

## Out of Scope

- Changes to `askWithReason`, `askWithAutoAccept`, or `markAsAsked` helper functions.
- Changes to Solkan or RTK layers.
- Persisting history across sessions (history is session-scoped by design).
- Any UI changes to the Claude Code permission dialogs.

## Further Notes

The GLOSSARY.md definitions of **ask with reason** and **ask with auto-accept** have already been updated to reflect this new unified rule before implementation begins.
