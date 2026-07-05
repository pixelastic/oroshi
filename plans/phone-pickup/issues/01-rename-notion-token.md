## TLDR

Rename `NOTION_API_KEY` → `NOTION_TOKEN` in the three shared Notion API helpers.

## What to build

The `notion-cli` tool authenticates via `NOTION_TOKEN`, while the existing `notion-api`, `notion-api-post`, and `notion-api-patch` autoload functions read `NOTION_API_KEY`. Rename the variable in all three functions so that a single env var name covers both the CLI and the curl-based helpers.

The rename at the definition root (dotfiles, outside this repo) is the user's responsibility and is not part of this issue.

## Acceptance criteria

- [ ] `notion-api` reads `NOTION_TOKEN` instead of `NOTION_API_KEY`
- [ ] `notion-api-post` reads `NOTION_TOKEN` instead of `NOTION_API_KEY`
- [ ] `notion-api-patch` reads `NOTION_TOKEN` instead of `NOTION_API_KEY`
- [ ] No other files in the repo reference `NOTION_API_KEY`
