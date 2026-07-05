## Problem Statement

The `phone-pickup` skill retrieves Notion pages to resume mobile vocal sessions in Claude Code. Both scripts (`phone-pickup-list` and `phone-pickup-read`) currently return raw Notion API JSON to Claude, which includes large amounts of metadata (block IDs, user objects, timestamps, annotations, parent references) that Claude doesn't use. This wastes tokens on every invocation — roughly 10x overhead on the list, 6x overhead on the read.

## Solution

Replace the raw Notion API calls in both scripts with `notion-cli` (`4ier/notion-cli`), a well-maintained Go CLI that speaks the official Notion REST API and can output Markdown natively. Each script is rewritten to output only the data Claude needs:

- `phone-pickup-list` → minimal JSON array `[{id, date, tags, title}]`, sorted by date descending, capped at 50 entries
- `phone-pickup-read` → pure Markdown rendered from Notion blocks

The `notion-cli` tool requires `NOTION_TOKEN` instead of the existing `NOTION_API_KEY`. The three shared `notion-api` helper functions are updated to use `NOTION_TOKEN`, and the environment variable is renamed at the definition site.

## User Stories

1. As Claude running the phone-pickup skill, I want `phone-pickup-list` to return a compact JSON array with only id, date, tags, and title, so that I can parse and match entries without consuming tokens on unused metadata.
2. As Claude running the phone-pickup skill, I want `phone-pickup-read` to return pure Markdown, so that I can present the content directly without parsing nested JSON block structures.
3. As Claude running the phone-pickup skill, I want the list to be sorted by date descending and capped at 50 entries, so that recent conversations are always at the top and the payload stays bounded as the database grows.
4. As a developer reinstalling the environment, I want a reproducible install script for `notion-cli`, so that the tool is available after a machine wipe without manual steps.
5. As a developer using `notion-api`, `notion-api-post`, or `notion-api-patch`, I want them to read from `NOTION_TOKEN` instead of `NOTION_API_KEY`, so that the auth variable is consistent with `notion-cli`'s expectation.

## Implementation Decisions

- **Tool**: `4ier/notion-cli` v0.7.0, installed from the official GitHub release `.deb` (Linux amd64). Install script lives alongside other API tool installs.
- **Auth**: `notion-cli` reads `NOTION_TOKEN`. The three existing `notion-api` helpers are updated from `NOTION_API_KEY` to `NOTION_TOKEN`. The environment variable is renamed at the definition root in the user's dotfiles.
- **`phone-pickup-list` output shape** (from prototype):
  ```json
  [
    { "id": "3937be57-...", "date": "2026-07-04", "tags": ["MISC"], "title": "🥶 Skill — Grill Me" }
  ]
  ```
  Produced by piping `notion db query <db-id> --sort 'Date:desc' --limit 50 -f json` through a `jq` filter that extracts only these four fields.
- **`phone-pickup-read` output**: raw stdout of `notion block list <page-id> --md`. No YAML front matter — Claude already has the page context from the list step.
- **`NOTION_PHONE_DB_ID` guard** in `phone-pickup-list` is preserved; equivalent `page_id` guard in `phone-pickup-read` is preserved.
- **`SKILL.md`** is updated to document the new output formats so future Claude instances know what to expect from each script.
- **`notion` commands** (`notion db query*`, `notion block list*`) are added to the bash allowlist so Claude can call them without a permission prompt.

## Testing Decisions

Good tests for these scripts verify **external behavior only**: given a mocked `notion` binary, does the script produce the correct output shape? Tests must not assert on internal implementation (which flags are passed, how jq is invoked).

**Modules tested:**

- `phone-pickup-list` — mock `notion` to emit a realistic multi-entry JSON response; assert that stdout is a valid JSON array where each element has exactly `id`, `date`, `tags`, `title`. Assert that a missing `NOTION_PHONE_DB_ID` causes a non-zero exit.
- `phone-pickup-read` — mock `notion` to emit a Markdown string; assert that stdout matches. Assert that a missing page ID argument causes a non-zero exit.

**Prior art**: existing bats tests for `phone-pickup-list` and `phone-pickup-read` in their `__tests__` directories use `bats_mock` for command stubs and `bats_run_zsh` to invoke autoload functions.

## Out of Scope

- Fetching more than 50 entries (no progressive pagination in this iteration)
- YAML front matter in `phone-pickup-read` output
- Supporting block types beyond what `notion-cli --md` renders natively (toggles, callouts, tables, etc.)
- Adding `notion page view` or other `notion-cli` subcommands to the allowlist
- Updating the skill to handle pagination or fallback when the target entry is older than 50 items
