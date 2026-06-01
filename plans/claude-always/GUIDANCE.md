## Guidance

### Domain vocabulary

Use these terms consistently (defined in `__docs/GLOSSARY.md`):
- **auto-approve** — solkan allows, command executes immediately (`permissionDecision: "allow"`)
- **ask** — 2-option dialog shown with rejected binary name (`permissionDecision: "ask"`)
- **escalate** — 3-option dialog including "allow for session" (`permissionDecision: "defer"`)

### Files

- Hook: `tools/ai/claude/config/hooks/preToolUse-Bash`
- Solkan checker: `tools/ai/claude/config/hooks/preToolUse-Bash-solkan`
- Allowlist: `tools/ai/claude/config/hooks/allowlist.json`
- Glossary: `tools/ai/claude/config/hooks/__docs/GLOSSARY.md`
- Tests: `tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats`

### Testing

Run tests: `rtk bats tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats`
Lint hook: `zshlint tools/ai/claude/config/hooks/preToolUse-Bash`

### Key constraints

- Hook must **always exit 0** — Claude Code treats any non-zero exit as a hook error
- **No `set -e`** in the hook (removed previously due to unexpected exits in the decision matrix)
- `permissionDecisionReason` must **not** be included with `permissionDecision: "defer"` — causes hook error in Claude Code v2.1.84
- `systemMessage` top-level field was tested and causes hook errors — do not use
- Session state is written **only on ask decisions**, not on escalate
- Mock names reflect what **solkan returns**: `mock-solkan-allow`, `mock-solkan-reject-single`, `mock-solkan-reject-multi`

### Session state

- Path: `$CLAUDE_SESSIONS_DIR/{sessionId}/state.json`
- Default `CLAUDE_SESSIONS_DIR`: `/tmp/oroshi/claude/sessions`
- Schema: `{ "preToolUse": { "Bash": { "askedCommands": ["wget"] } } }`
- In `/tmp` → no cleanup needed (cleared on reboot)

### Env var overrides (for tests)

- `PRETOOLUSE_SOLKAN_SCRIPT` — override solkan script path
- `PRETOOLUSE_RTK_SCRIPT` — override RTK script path
- `CLAUDE_HOOKS_LOG_DIR` — override debug log directory
- `CLAUDE_SESSIONS_DIR` — override session state directory

## Discoveries
