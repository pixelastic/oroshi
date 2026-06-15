# PRD — Claude MCP On-Demand Toggle

## Problem

The Google Slides MCP server (~150MB RAM, suspected memory leaks) would run in every Claude
Code session if added to the user-scoped config. Claude Code has no native mechanism to
pre-configure a server without auto-starting it — servers defined in `~/.claude.json`
connect at every session startup. The only way to prevent loading is to keep it out of
`~/.claude.json` entirely.

## Solution

A suite of ZSH autoload functions that add or remove MCP servers from `~/.claude.json` on
demand, without editing config files manually. A server-specific function encodes the full
`claude mcp add` command for Google Slides. After toggling, the user restarts their Claude
session to pick up the change. Google Slides is intentionally absent from
`tools/ai/claude/install` — the toggle functions are the only entry point for enabling it.

## User Stories

- As a user, I run `claude-mcp-toggle google-slides` to enable or disable the server based
  on its current state, then restart my Claude session to apply the change.
- As a user, I run `claude-mcp-add google-slides` to explicitly enable the server.
- As a user, I run `claude-mcp-remove google-slides` to explicitly disable it.
- As a user, adding a new optional MCP server in the future requires only one new
  `claude-mcp-add-<name>` function — no changes to the generic helpers.

## Implementation Decisions

### File locations

All functions live in:
`tools/term/zsh/config/functions/autoload/ai/claude/mcp/`

The `oroshi-reload-fpath` loader globs `autoload/**/*(N)` — the `mcp/` subdirectory is
picked up automatically. No loader changes needed.

### Functions

| Function | Responsibility |
|---|---|
| `claude-mcp-is-added <name>` | Predicate — reads `~/.claude.json` via `jq`, exits 0 if server key exists, 1 otherwise |
| `claude-mcp-add <name>` | Dispatcher — looks for `claude-mcp-add-<name>` in PATH; calls it or errors; prints restart reminder on success |
| `claude-mcp-remove <name>` | Wraps `claude mcp remove --scope user <name>`; prints restart reminder |
| `claude-mcp-toggle <name>` | Orchestrator — calls `is-added`, delegates to `add` or `remove` |
| `claude-mcp-add-google-slides` | Server-specific — sources `.envrc`, calls `claude mcp add` with full params |

Naming follows the official Claude CLI terminology (`add`/`remove`), not `enable`/`disable`.

### Google Slides credentials

`/home/tim/local/src/google-slides-mcp/.envrc` holds `GOOGLE_CLIENT_ID`,
`GOOGLE_CLIENT_SECRET`, and `GOOGLE_REFRESH_TOKEN`. `claude-mcp-add-google-slides` sources
this file at call time and passes vars as `-e KEY=$VALUE` flags. No credentials in oroshi.

Server binary: `/home/tim/local/src/google-slides-mcp/build/index.js`

### MCP scope

All add/remove operations use `--scope user`.

### Restart reminder

After `claude-mcp-add` or `claude-mcp-remove`, the function prints a message reminding the
user to restart their Claude session. Changes take effect only at next startup.

## Testing Decisions

Tests live in `tools/term/zsh/config/functions/autoload/ai/claude/mcp/__tests__/`.

### Mock strategy for `~/.claude.json`

`~` expands to `$HOME` at runtime. Tests use `bats_mock_env HOME "$BATS_TMP_DIR"` then
write a fixture at `$BATS_TMP_DIR/.claude.json`. No env var instrumentation in production
code.

`claude mcp add/remove` is mocked via `bats_mock claude`.

### Tests per function

**`claude-mcp-is-added`**
- server key present in fixture → exit 0
- server key absent → exit 1

**`claude-mcp-add`**
- name `google-slides` → `claude-mcp-add-google-slides` exists in PATH (real worktree PATH) → succeeds, reminder printed
- unknown name → no matching script in PATH → exits non-zero with error

**`claude-mcp-remove`**
- mocks `claude`; verifies it is called with `mcp remove --scope user <name>`
- verifies restart reminder is printed

**`claude-mcp-toggle`**
- mocks `claude-mcp-is-added` returning 0 → verifies `claude-mcp-remove` called
- mocks `claude-mcp-is-added` returning 1 → verifies `claude-mcp-add` called

**`claude-mcp-add-google-slides`** — no tests (calls real `claude` CLI; testing would
mirror the implementation with no independent signal).

## Out of Scope

- A Claude skill (`/mcp-toggle`) — deferred; can be added once the zsh layer is stable
- HTTP MCP servers (context7, make.com) — already always-on, no toggle needed
- Session-level isolation — not possible with current Claude Code architecture; toggle
  affects all future sessions until reversed
- Native Claude disable flag — does not exist as of June 2026
