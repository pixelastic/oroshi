## TLDR

Add `claude-mcp-toggle` as a zsh autoload function that flips the registration state of any MCP server.

## What to build

Add `claude-mcp-toggle <name>` to
`tools/term/zsh/config/functions/autoload/ai/claude/mcp/`.

The function calls `claude-mcp-is-added <name>`:
- if exit 0 (registered) → delegates to `claude-mcp-remove <name>`
- if exit 1 (not registered) → delegates to `claude-mcp-add <name>`

The restart reminder is printed by `add`/`remove` — `toggle` itself prints nothing extra.

Tests live alongside the other mcp tests in `__tests__/`.

## Behavioral Tests

- calls `claude-mcp-remove` when server is currently added (`is-added` mocked to exit 0)
- calls `claude-mcp-add` when server is not currently added (`is-added` mocked to exit 1)

## Acceptance criteria

- [ ] `claude-mcp-toggle <name>` added to the `mcp/` autoload directory
- [ ] delegates to `claude-mcp-remove` when server is registered
- [ ] delegates to `claude-mcp-add` when server is not registered
- [ ] all tests pass (`bats <testfile>`)
