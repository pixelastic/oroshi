## Guidance

### Domain vocabulary

Use these terms consistently (defined in `tools/ai/claude/config/hooks/GLOSSARY.md`):
- **auto-approve** — solkan allows, command executes immediately (`permissionDecision: "allow"`)
- **ask user** — default reject case: 3-option dialog including "allow for session" (`permissionDecision: "defer"`), no reason shown
- **ask user — first time** — exception reject case: 2-option dialog (Allow / Deny) with rejected binary name (`permissionDecision: "ask"`)

### Files

- Hook: `tools/ai/claude/config/hooks/preToolUse-Bash`
- Solkan wrapper: `tools/ai/claude/config/hooks/preToolUse-Bash-solkan.zsh`
- RTK wrapper: `tools/ai/claude/config/hooks/preToolUse-Bash-rtk.zsh`
- Allowlist: `tools/ai/claude/config/hooks/allowlist.json`
- Glossary: `tools/ai/claude/config/hooks/GLOSSARY.md`
- Tests: `tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats`

### Testing

Run tests: `rtk bats tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats`
Lint hook: `zshlint tools/ai/claude/config/hooks/preToolUse-Bash`

### Key constraints

- Hook must **always exit 0** — Claude Code treats any non-zero exit as a hook error
- **No `set -e`** in the hook (removed previously due to unexpected exits in the decision matrix)
- `permissionDecisionReason` must **not** be included with `permissionDecision: "defer"` — causes hook error in Claude Code v2.1.84
- `systemMessage` top-level field was tested and causes hook errors — do not use
- Session state is written **only on `ask user — first time` decisions**, not on `ask user`
- No env var overrides for script paths — sibling scripts are sourced by path at hook startup

### Session state

- Path: `$CLAUDE_SESSIONS_DIR/{sessionId}/state.json`
- Default `CLAUDE_SESSIONS_DIR`: `/tmp/oroshi/claude/sessions`
- Schema: `{ "preToolUse": { "Bash": { "askedCommands": ["wget"] } } }`
- In `/tmp` → no cleanup needed (cleared on reboot)

### Env var overrides (for tests)

- `CLAUDE_HOOKS_LOG_DIR` — override debug log directory
- `CLAUDE_SESSIONS_DIR` — override session state directory

### Mocking pattern (bats_mock)

Sibling scripts (`preToolUse-Bash-solkan.zsh`, `preToolUse-Bash-rtk.zsh`) define functions named after themselves — `preToolUse-Bash-solkan()` and `preToolUse-Bash-rtk()`. This avoids any naming collision with the `solkan` and `rtk` binaries they call internally.

Each sibling script starts with a guard:
```zsh
whence preToolUse-Bash-solkan > /dev/null && return 0
```
If the function already exists (because a test mocked it), sourcing is a no-op → mock is preserved.

- Hook sources both `.zsh` files unconditionally at startup
- Tests mock with `bats_mock preToolUse-Bash-solkan` / `bats_mock preToolUse-Bash-rtk` before `bats_run_script`
- `bats_run_script` passes `<<<` stdin through `run zsh -c` — confirmed working
- Sibling test files pre-populate `mock.zsh` with `hookDir` + `source` of the `.zsh` file so `bats_run_function` loads the function into the ZSH subprocess
- `preToolUse-Bash-rtk.bats` mocks `rtk` (the binary) inline via `bats_mock rtk` — no recursion risk since the function is named `preToolUse-Bash-rtk`, not `rtk`
- `hookDir` set at hook script top-level is accessible inside wrapper functions (effectively global in ZSH at script scope)

## Discoveries

### Issue 02b — bats-mock test refactor
- `bats_run_script "$SCRIPT" <<< json` does propagate stdin — no tmp-file fallback needed
- Naming wrapper functions after their script (`preToolUse-Bash-solkan`) instead of the binary they wrap (`solkan`) eliminates all recursion risk and allows clean `bats_mock` at both the hook level and the wrapper level
- Guard `whence name > /dev/null && return 0` is more robust than `${+functions[name]}` — catches binaries in PATH too, not just functions
- Sibling files renamed to `.zsh` for NeoVim syntax highlighting and pre-commit lint coverage
