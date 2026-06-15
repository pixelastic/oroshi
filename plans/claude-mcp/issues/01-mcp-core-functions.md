## TLDR

Add `claude-mcp-is-added`, `claude-mcp-add`, and `claude-mcp-remove` as zsh autoload functions with tests.

## What to build

Create the directory `tools/term/zsh/config/functions/autoload/ai/claude/mcp/` and add three
functions. The `oroshi-reload-fpath` loader picks up the new subdirectory automatically via
its `autoload/**/*(N)` glob — no loader changes needed.

**`claude-mcp-is-added <name>`**
Reads `~/.claude.json` via `jq` and exits 0 if the key `mcpServers.<name>` exists, 1
otherwise. This is the shared predicate used by `add`, `remove`, and `toggle`.

**`claude-mcp-add <name>`**
First calls `claude-mcp-is-added`; if the server is already registered, prints a message
and exits 0 (no-op). Otherwise looks for `claude-mcp-add-<name>` in PATH; if found, calls
it and prints a restart reminder on success; if not found, exits non-zero with an error.

**`claude-mcp-remove <name>`**
First calls `claude-mcp-is-added`; if the server is not registered, prints a message and
exits 0 (no-op). Otherwise calls `claude mcp remove --scope user <name>` and prints a
restart reminder.

Tests live in `tools/term/zsh/config/functions/autoload/ai/claude/mcp/__tests__/`.

## Behavioral Tests

**`claude-mcp-is-added`**
- exits 0 when server key is present in `~/.claude.json`
- exits 1 when server key is absent from `~/.claude.json`

**`claude-mcp-add`**
- does nothing when server is already added
- exits non-zero with error when no `claude-mcp-add-<name>` script exists
- calls the sub-script when it exists (mocked via `bats_mock`)

**`claude-mcp-remove`**
- does nothing when server is not added
- calls `claude mcp remove --scope user <name>` when server is added (mocked via `bats_mock claude`)

## Acceptance criteria

- [ ] `tools/term/zsh/config/functions/autoload/ai/claude/mcp/` directory created
- [ ] `claude-mcp-is-added` exits 0/1 based on `~/.claude.json` content
- [ ] `claude-mcp-add` is a no-op if server already registered
- [ ] `claude-mcp-add` errors if no dedicated sub-script found
- [ ] `claude-mcp-add` delegates to sub-script and prints restart reminder on success
- [ ] `claude-mcp-remove` is a no-op if server not registered
- [ ] `claude-mcp-remove` calls `claude mcp remove --scope user <name>` and prints restart reminder
- [ ] All tests pass (`bats <testfile>`)
