## Issue 03 — claude-mcp-add-google-slides

### Hardcoded absolute path `/home/tim/local/src/google-slides-mcp`
```zsh
local envrc="/home/tim/local/src/google-slides-mcp/.envrc"
...
  -- node /home/tim/local/src/google-slides-mcp/build/index.js
```
**Problem:** Standards agent flagged literal `/home/tim/` paths; `$OROSHI_ROOT` memory note discourages hardcoded oroshi paths.
**Reason skipped:** The `$OROSHI_ROOT` rule covers oroshi-internal paths. This is an external project (`google-slides-mcp`) with no existing env var. GUIDANCE.md and the issue spec both specify this exact literal path as the source of truth.

### No test file
**Problem:** Standards agent flagged missing `__tests__` file as a process violation.
**Reason skipped:** Issue 03 explicitly states "No tests — calling the real `claude` CLI would require live credentials and a network connection; testing would mirror the implementation with no independent signal."

## Issue 01 — MCP core functions

### `~` vs `$HOME` in claude-mcp-is-added
```zsh
jq --exit-status ".mcpServers[\"$name\"]" ~/.claude.json > /dev/null
```
**Problem:** Reviewer flagged `~` should be `$HOME/.claude.json`.
**Reason skipped:** In ZSH `~` IS `$HOME`. Tests confirm `bats_mock_env HOME "$BATS_TMP_DIR"` correctly redirects `~/.claude.json`. The `$OROSHI_ROOT` rule in memory is specific to oroshi paths, not general HOME usage.

### Empty `$1` guard missing in claude-mcp-add and claude-mcp-remove
**Problem:** No `[[ "$name" == "" ]] && return 1` guard.
**Reason skipped:** Out of spec scope; not in acceptance criteria or behavioral tests.

### Inline stub + bats_mock pattern flagged as wrong
**Problem:** Reviewer called `fn() { ... }; bats_mock fn` a hard violation.
**Reason skipped:** This is the canonical pattern documented in `zsh-writer/references/testing.md` (verbatim example). Reviewer was incorrect.

## Issue 02 — claude-mcp-toggle

### No guard on empty `$name`
```zsh
local name="$1"
```
**Problem:** Calling with no argument silently passes empty string downstream.
**Reason skipped:** All peer MCP functions follow the same unguarded pattern — a guard here would be inconsistent without updating all of them.

### `bats_tmp_dir` called but not needed
```bash
setup() {
  bats_tmp_dir
}
```
**Problem:** Neither test writes to `$BATS_TMP_DIR`, so the call is unnecessary boilerplate.
**Reason skipped:** Every other MCP test file uses this same setup/teardown boilerplate; removing it here would be inconsistent.
