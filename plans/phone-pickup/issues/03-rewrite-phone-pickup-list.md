## TLDR

Rewrite `phone-pickup-list` to output a minimal JSON array via `notion db query | jq`.

## What to build

Replace the `notion-api-post` call with `notion db query <db_id> --sort 'Date:desc' --limit 50 -f json` piped through a `jq` filter. The output is a JSON array where each element contains exactly four fields: `id`, `date`, `tags`, `title`. The `NOTION_PHONE_DB_ID` guard is preserved.

The jq filter shape (from prototype):
```
[.results[] | {id, date: .properties.Date.date.start, tags: [.properties.Tags.multi_select[].name], title: .properties.Name.title[0].plain_text}]
```

The existing tests assert on implementation details (which API endpoint was called, that raw JSON passes through unchanged) — both will be false after this rewrite. Replace them with behavioral tests that mock the `notion` binary and verify output shape.

## Behavioral Tests

**Happy path**
- output is a valid JSON array
- each entry has exactly `id`, `date`, `tags`, `title` fields
- `tags` is an array of strings

**Guard**
- exits non-zero when `NOTION_PHONE_DB_ID` is unset

## Acceptance criteria

- [ ] `phone-pickup-list` outputs a JSON array with `{id, date, tags, title}` per entry
- [ ] `phone-pickup-list` (no `NOTION_PHONE_DB_ID`) exits non-zero
- [ ] Old tests removed; new behavioral tests pass
- [ ] `bats-lint` passes on the test file
- [ ] `zsh-lint` passes on the function file
