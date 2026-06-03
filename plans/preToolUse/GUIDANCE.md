## Guidance

**Context:** `preToolUse-Bash` is an autoload zsh hook that gates shell command execution. It runs Solkan (allowlist check) then RTK (command rewriter) sequentially and outputs a JSON decision to Claude Code.

**Glossary:** `tools/ai/claude/config/hooks/GLOSSARY.md` — use its vocabulary throughout. Key terms: Solkan, RTK, allow, reject, rewrite, ignore, auto-approve, ask with reason, ask with auto-accept.

**Files to modify:**
- `tools/ai/claude/config/hooks/preToolUse-Bash` — main hook (decision logic)
- `tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats` — bats tests

**Helper file (read-only):**
- `tools/ai/claude/config/hooks/preToolUse-Bash-helper.zsh` — defines `autoApprove`, `askWithReason`, `askWithAutoAccept`, `markAsAsked`

**Run tests:** `rtk bats tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats`

**Test pattern:** Tests use `bats_mock` to stub `preToolUse-Bash-solkan` and `preToolUse-Bash-rtk`. Session history is seeded by writing `state.json` directly into `$BATS_TMP_DIR/{sessionId}/`. See existing tests for prior art.

**Session state shape:**
```json
{ "preToolUse": { "Bash": { "askedCommands": ["wget", "curl"] } } }
```

**Decision rule (post-PRD):**
- Load `askedCmds` from session state
- `newRejected` = rejected commands not in `askedCmds`
- Call `markAsAsked` for all rejected (unconditionally)
- `newRejected` empty → `askWithAutoAccept`
- `newRejected` non-empty → `askWithReason` with `newRejected` (not all rejected)

## Discoveries

_(append-only — agents add findings here after each issue)_

### Issue 01 — Unified reject path

- `${arr1:|arr2}` is the zsh array subtraction operator — gives elements in `arr1` not present in `arr2`. Used to compute `newRejected=(${rejected:|askedCmds})`.
- `askWithAutoAccept` omits the `permissionDecisionReason` key entirely; `jq '.key'` on an absent key returns JSON `null`, so tests checking `== "null"` correctly validate key absence.
