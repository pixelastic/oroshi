## Problem Statement

The user conducts vocal brainstorming sessions on Claude mobile, which saves discussion artifacts to a dedicated Notion database. There is no way to access those artifacts from Claude Code — the two environments are siloed, forcing the user to manually copy content between them when they want to continue or act on a mobile conversation from their desktop.

## Solution

Introduce a `phone-pickup` skill and two supporting zsh functions that give Claude Code read access to the Notion database used by Claude mobile. When invoked, the skill lists all entries in the database, identifies the one matching the user's description, reads its full content, and presents it — bridging the gap between mobile session and desktop session with zero manual copy-paste.

## User Stories

1. As a user, I want to say "phone pickup — récupère la discussion sur le refactoring fzf" so that Claude Code can find and load that conversation without me manually copying anything.
2. As a user, I want Claude Code to identify the correct Notion entry from a description, so that I don't need to know the exact title.
3. As a user, I want the full content of the identified page fetched automatically, so that I can immediately continue the discussion.
4. As a user, I want the skill to present multiple candidates if the description is ambiguous, so that I can pick the right one.
5. As a user, I want the Notion database ID stored as an environment variable, so that it is not hardcoded in committed files.
6. As a user, I want the zsh helpers to return raw JSON, so that the skill and any future tooling can interpret any schema without coupling to a specific property layout.
7. As a user, I want the phone-pickup helpers to follow the same naming convention as the skill, so that the toolbox stays coherent.
8. As a user, I want the integration to use the existing `NOTION_API_KEY` already in place, so that no additional credentials are needed.
9. As a user, I want no persistent MCP server overhead for this feature, so that unrelated Claude Code sessions are not burdened.
10. As a user, I want the helpers to be autoloaded zsh functions, so that they are also usable from the terminal outside Claude Code.

## Implementation Decisions

- **No new dependency.** The feature is built on `curl` and `jq`, using the existing `notion-api` infrastructure already present in the oroshi autoload tree. No third-party CLI (`notion-cli`) or MCP server is introduced.

- **Two new autoloaded zsh functions** are added under the `ai/phone-pickup` domain:
  - `phone-pickup-list` — issues `POST /v1/databases/$NOTION_PHONE_DB_ID/query` and returns the raw Notion API JSON response. No arguments.
  - `phone-pickup-read` — issues `GET /v1/blocks/{page_id}/children` and returns the raw Notion API JSON response. Single argument: the page ID.

- **Schema-agnostic output.** Both functions return unfiltered JSON. Identification and interpretation of fields (title, date, tags, body blocks) is delegated to Claude, not encoded in the shell layer. This prevents coupling to the current database schema.

- **Environment variables.** `NOTION_API_KEY` is already present in the private host config. A new variable `NOTION_PHONE_DB_ID` (value: `3937be57b8fa80328fb5f25db51eaf21`) is added to the same file, following the existing `export VAR="value"` pattern.

- **Notion API version.** Use `Notion-Version: 2022-06-28`, consistent with all existing notion autoload functions.

- **`phone-pickup` skill** instructs Claude to:
  1. Call `phone-pickup-list` to retrieve all entries.
  2. Match the user's description against titles, dates, and tags to identify the best candidate; if ambiguous, present the shortlist and ask the user to pick.
  3. Call `phone-pickup-read` with the identified page ID to retrieve the page blocks.
  4. Present the content, ready for the user to continue the conversation.

- **Read-only scope.** No write path is implemented. The skill does not create, update, or delete Notion pages.

- **Skill location.** The skill file is added to the worktree's skills directory alongside existing skills (sidequest, grill-me, etc.), following the established `SKILL.md` + YAML frontmatter format.

## Testing Decisions

Good tests verify external behavior — what the function outputs given a specific environment — not implementation details like internal variable names or curl flag order.

**Modules tested:**

- `phone-pickup-list` — bats tests verify that:
  - When `NOTION_API_KEY` and `NOTION_PHONE_DB_ID` are set, the function calls the correct Notion API endpoint (`databases/{DB_ID}/query`).
  - The raw JSON response is forwarded to stdout without modification.
  - When `NOTION_PHONE_DB_ID` is unset, the function fails with a non-zero exit code.

- `phone-pickup-read` — bats tests verify that:
  - Given a page ID argument, the function calls the correct endpoint (`blocks/{page_id}/children`).
  - The raw JSON response is forwarded to stdout.
  - When called without arguments, the function fails with a non-zero exit code.

**Prior art:** existing bats tests for notion autoload functions and ai/claude helpers in `__tests__` directories adjacent to the function files. Use `bats_mock` to stub `curl`, `bats_mock_env` to inject environment variables.

**Not tested:** the skill file (markdown), the private config addition (config-change artifact), and the integration with the live Notion API.

## Out of Scope

- **Write-back.** Creating, updating, or annotating Notion pages from Claude Code is not part of this implementation.
- **Filtering on the shell side.** No date-range, tag, or keyword filtering is applied by the zsh layer; all filtering is done by Claude.
- **MCP server.** The Notion MCP server (`@notionhq/notion-mcp-server`) is explicitly not used.
- **Other Notion databases.** Only the Claude mobile sessions database is addressed; no generic database accessor is built.
- **Pagination.** The current database is small (8 entries). Pagination support is deferred.

## Further Notes

The Notion database was verified live during the design session. The schema observed: `Name` (title, descriptive), `Date` (date property), `Tags` (multi-select). Content lives in page blocks, not in properties. The integration has been connected to the "CLI Scripts" Notion integration which holds `NOTION_API_KEY`.
