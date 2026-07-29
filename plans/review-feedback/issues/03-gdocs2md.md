## TLDR

Convert a Google Doc back to Markdown via the API.

## What to build

A `gdocs2md` CLI command that takes a Google Docs URL or document ID, fetches the document content via the Docs API, converts it to Markdown, and outputs it to stdout.

End-to-end: user runs `gdocs2md https://docs.google.com/document/d/xxx/edit` → fetches Doc → converts to Markdown → prints to stdout.

### Files to create

- `scripts/bin/google/gdocs/gdocs2md/gdocs2md` — ZSH wrapper
- `scripts/bin/google/gdocs/gdocs2md/gdocs2md.js` — fetches Doc JSON via Docs API, walks the structural elements, converts to Markdown
- `scripts/bin/google/gdocs/gdocs2md/__tests__/gdocs2md.js` — unit tests

### Behavior

- Accepts one argument: Google Docs URL or document ID
- Extracts document ID from URL if a full URL is provided
- Fetches document via `docs.documents.get`
- Converts Google Docs structural elements to Markdown: headings (HEADING_1–6 → #–######), paragraphs, bold (`textStyle.bold`), italic (`textStyle.italic`), links (`textStyle.link`), lists (ordered/unordered)
- Outputs Markdown to stdout
- Imports `googleAuth.js` from `scripts/bin/google/`

## Behavioral Tests

**URL parsing:**
- Given a full Google Docs URL, extracts the document ID correctly
- Given a bare document ID, uses it directly

**Heading conversion:**
- Given a Doc with HEADING_1, HEADING_2, outputs `#`, `##` Markdown headings

**Text style conversion:**
- Given bold text, outputs `**bold**`
- Given italic text, outputs `*italic*`
- Given linked text, outputs `[text](url)`

**List conversion:**
- Given ordered list items, outputs numbered Markdown list
- Given unordered list items, outputs bullet Markdown list

**Paragraph conversion:**
- Given plain paragraphs, outputs them separated by blank lines

## Acceptance criteria

- [ ] `gdocs2md <url>` outputs Markdown to stdout
- [ ] Accepts both full URL and bare document ID
- [ ] Headings, bold, italic, links, lists correctly converted
- [ ] Unit tests pass with mocked Docs API response
