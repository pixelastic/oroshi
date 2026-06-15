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
