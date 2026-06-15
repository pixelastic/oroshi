## Guidance

### Goal

Add on-demand MCP toggle functions so the Google Slides MCP server (~150MB RAM) only loads
when explicitly enabled, not in every Claude session.

### File locations

- New functions: `tools/term/zsh/config/functions/autoload/ai/claude/mcp/`
- Tests: `tools/term/zsh/config/functions/autoload/ai/claude/mcp/__tests__/`
- Prior art (patterns to follow): `tools/term/zsh/config/functions/autoload/ai/claude/`

### Conventions

- ZSH autoload functions — no shebang, no execute bit
- Use `setopt local_options err_return` (not `set -e`) — these are autoload functions
- Use `[[ $flag == "1" ]]` for boolean checks, not `(( flag ))`
- Use `if/then/fi` for multi-instruction blocks; `&&` only for single-action one-liners
- Use `local var="$(cmd)"` + manual guard; never split `local`/assignment
- Preserve existing comments; delete comments together with the code they describe

### Testing

- Run tests: `bats <filepath>`
- Lint: `zsh-lint <filepath>` and `bats-lint <filepath>`
- Mock `HOME` to redirect `~/.claude.json` reads/writes: `bats_mock_env HOME "$BATS_TMP_DIR"`
- Write fixture JSON to `$BATS_TMP_DIR/.claude.json` before running the function under test
- Mock `claude` via `bats_mock claude` to prevent real CLI calls
- Mock sub-functions via `bats_mock <fn>` (e.g. `bats_mock claude-mcp-is-added`)

### Key decisions

- `claude mcp add/remove` uses `--scope user` (cross-project availability)
- Naming follows Claude CLI terminology: `add`/`remove`, not `enable`/`disable`
- `claude-mcp-add` is a dispatcher — server-specific logic lives in `claude-mcp-add-<name>`
- Google Slides credentials come from `/home/tim/local/src/google-slides-mcp/.envrc` at
  call time — never stored in oroshi
- `claude-mcp-add-google-slides` has no tests (calls real `claude` CLI)
- After add/remove, user must restart their Claude session for the change to take effect

### Context

- Claude Code has no native "disabled" server flag — add/remove is the only mechanism
- MCP config is read at session startup; changes take effect at next session launch
- `oroshi-reload-fpath` globs `autoload/**/*(N)` — the new `mcp/` subdirectory is picked
  up automatically, no loader changes needed

## Discoveries

<!-- Append findings here after each issue, format:
### Issue XX — short title
- Finding
-->
