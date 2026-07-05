## TLDR

Autoloaded zsh function that queries the Claude mobile Notion database and returns the raw API JSON response.

## What to build

Create `phone-pickup-list` in the `ai/phone-pickup` autoload domain. The function:

- Issues `POST /v1/databases/$NOTION_PHONE_DB_ID/query` using `curl` directly (not via `notion-api-post`)
- Uses `NOTION_API_KEY` for the Bearer token and `Notion-Version: 2022-06-28` header
- Accepts no arguments
- Forwards the raw JSON response to stdout without modification
- Fails with a non-zero exit code if `NOTION_PHONE_DB_ID` is unset

Follow the `setopt local_options err_return` pattern used by all sibling notion functions.

Write bats tests in an adjacent `__tests__` directory. Use `bats_mock` to stub `curl` and `bats_mock_env` to control env vars.

## Behavioral Tests

**Happy path**
- When `NOTION_API_KEY` and `NOTION_PHONE_DB_ID` are set, the function calls the Notion databases query endpoint with the correct DB ID
- The raw JSON from curl is forwarded to stdout unchanged

**Guard: missing env var**
- When `NOTION_PHONE_DB_ID` is unset, the function exits with a non-zero status

## Acceptance criteria

- [ ] `phone-pickup-list` exists in the `ai/phone-pickup` autoload domain
- [ ] Function calls `POST /v1/databases/$NOTION_PHONE_DB_ID/query` with the correct auth headers
- [ ] Output is the raw Notion API JSON (no jq transformation)
- [ ] Exits non-zero when `NOTION_PHONE_DB_ID` is unset
- [ ] Bats tests pass (`bats` + `bats-lint`)
- [ ] Zsh lint passes (`zsh-lint`)
