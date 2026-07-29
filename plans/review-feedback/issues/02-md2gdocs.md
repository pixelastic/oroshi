## TLDR

Convert a local Markdown file to a Google Doc in the shared Drive folder.

## What to build

A `md2gdocs` CLI command that reads a Markdown file, creates a Google Doc from its content in the hardcoded `Automation/Docs/` folder on the professional Drive, and outputs the Google Docs URL to stdout.

End-to-end: user runs `md2gdocs article.md` → reads file → creates Google Doc titled "article" in `Automation/Docs/` → prints `https://docs.google.com/document/d/xxx/edit`.

### Files to create

- `scripts/bin/markdown/md2gdocs/md2gdocs` — ZSH wrapper
- `scripts/bin/markdown/md2gdocs/md2gdocs.js` — reads Markdown file, converts content to Google Docs API body structure, creates Doc in target folder via Drive + Docs API, outputs URL
- `scripts/bin/markdown/md2gdocs/__tests__/md2gdocs.js` — unit tests

### Behavior

- Accepts one positional argument: path to a Markdown file
- Accepts `--title` flag (optional): overrides the Doc title. Default: filename without extension.
- Always creates a new Doc (no update/dedup logic)
- Target folder: `Automation/Docs/` on the professional Drive (hardcoded folder ID)
- Imports `googleAuth.js` from `scripts/bin/google/`
- Markdown → Google Docs body conversion: headings, paragraphs, bold, italic, links, lists

## Behavioral Tests

**Default title from filename:**
- Given a file `my-article.md`, creates a Doc titled "my-article"

**Custom title via --title flag:**
- Given `--title "Custom Name"` and a file, creates a Doc titled "Custom Name"

**Markdown conversion:**
- Given Markdown with headings, paragraphs, bold, italic, links, and lists, the API call payload contains the correct Google Docs structural elements

**Target folder:**
- The Doc is created inside the hardcoded `Automation/Docs/` folder ID

**URL output:**
- Prints the created Doc's URL to stdout

## Acceptance criteria

- [ ] `md2gdocs article.md` creates a Google Doc and prints its URL
- [ ] Default title is filename without extension
- [ ] `--title` flag overrides the title
- [ ] Doc is created in `Automation/Docs/` folder
- [ ] Unit tests pass with mocked Google API client
