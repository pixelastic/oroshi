## TLDR

Extract unresolved comments from a Google Doc as JSON.

## What to build

A `gdocs-comments-json` CLI command that takes a Google Docs URL or document ID, fetches comments via the Drive API, filters to unresolved only, and outputs a JSON array to stdout.

End-to-end: user runs `gdocs-comments-json https://docs.google.com/document/d/xxx/edit` → fetches comments → filters → prints `[{"anchor": "...", "comment": "..."}]`.

### Files to create

- `scripts/bin/google/gdocs/gdocs-comments-json/gdocs-comments-json` — ZSH wrapper
- `scripts/bin/google/gdocs/gdocs-comments-json/gdocs-comments-json.js` — fetches comments via Drive API `comments.list`, filters `resolved: false`, maps to `{anchor, comment}` shape, outputs JSON

### Behavior

- Accepts one argument: Google Docs URL or document ID
- Extracts document ID from URL if needed (same logic as `gdocs2md`)
- Uses Drive API `comments.list` with `fields` param to get `quotedFileContent.value` (anchor) and `content` (comment text)
- Filters out resolved comments (`resolved: true`)
- Outputs JSON array: `[{"anchor": "quoted text", "comment": "user's comment"}]`
- Empty array `[]` if no unresolved comments
- Imports `googleAuth.js` from `scripts/bin/google/`

## Acceptance criteria

- [ ] `gdocs-comments-json <url>` outputs JSON array to stdout
- [ ] Only unresolved comments are included
- [ ] Each entry has `anchor` and `comment` fields, nothing else
- [ ] Empty array when no unresolved comments exist
