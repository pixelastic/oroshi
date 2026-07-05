## TLDR

Autoloaded zsh function that fetches a Notion page's block content by page ID and returns the raw API JSON response.

## What to build

Create `phone-pickup-read` in the `ai/phone-pickup` autoload domain. The function:

- Takes a single argument: the Notion page ID
- Issues `GET /v1/blocks/{page_id}/children` using `curl` directly
- Uses `NOTION_API_KEY` for the Bearer token and `Notion-Version: 2022-06-28` header
- Forwards the raw JSON response to stdout without modification
- Fails with a non-zero exit code if called without arguments

Follow the `setopt local_options err_return` pattern used by all sibling notion functions.

Write bats tests in an adjacent `__tests__` directory. Use `bats_mock` to stub `curl` and `bats_mock_env` to control env vars.

## Behavioral Tests

**Happy path**
- Given a page ID, the function calls the Notion blocks children endpoint with the correct page ID
- The raw JSON from curl is forwarded to stdout unchanged

**Guard: missing argument**
- When called without arguments, the function exits with a non-zero status

## Acceptance criteria

- [ ] `phone-pickup-read` exists in the `ai/phone-pickup` autoload domain
- [ ] Function accepts a page ID as its first argument
- [ ] Calls `GET /v1/blocks/{page_id}/children` with the correct auth headers
- [ ] Output is the raw Notion API JSON (no jq transformation)
- [ ] Exits non-zero when called without arguments
- [ ] Bats tests pass (`bats` + `bats-lint`)
- [ ] Zsh lint passes (`zsh-lint`)
