## TLDR

Unify the multi-reject and single-reject decision paths so that session history governs the dialog choice in all cases.

## What to build

Remove the early-return block that forces **ask with reason** whenever multiple binaries are rejected. Replace it with a single path that:

1. Loads session history (`askedCmds`)
2. Computes `newRejected` — rejected commands absent from history
3. Calls `markAsAsked` for all rejected commands
4. If `newRejected` is empty → **ask with auto-accept**
5. If `newRejected` is non-empty → **ask with reason** with only `newRejected` as the reason string

`markAsAsked` is called unconditionally before the decision, consistent with the existing single-reject pattern. When `sessionId` is empty, `askedCmds` stays empty and all rejected appear new — **ask with reason** always, no special-casing.

## Behavioral Tests

**All new (no history):**
- Multi-reject with no session history → `permissionDecision: "ask"`
- Reason string contains all rejected binary names

**All seen (full history match):**
- Multi-reject where every rejected binary is already in `askedCommands` → `permissionDecision: "defer"`
- No `permissionDecisionReason` field

**Mixed (some new, some seen):**
- Multi-reject where a subset of rejected binaries is already in history → `permissionDecision: "ask"`
- Reason string contains only the new binary names, not the already-seen ones

**Existing single-reject tests (must remain green):**
- First encounter → `permissionDecision: "ask"`
- Repeat encounter → `permissionDecision: "defer"`

## Acceptance criteria

- [ ] The `if multi-reject` early-return block is removed from the hook
- [ ] A single unified reject path handles both single and multi-reject
- [ ] `askWithReason` receives only new (unseen) rejected binary names
- [ ] `askWithAutoAccept` is used when all rejected binaries are already in session history
- [ ] `markAsAsked` is called before the decision in all reject paths
- [ ] Old "multi-reject: always ask with reason" test is replaced by the 3-case matrix (A/B/C)
- [ ] All existing single-reject tests remain green
- [ ] `rtk bats` passes on the test file
