## TLDR

Alternative md2gdocs using Pandoc → DOCX → Drive upload. Images (local and remote) are embedded in the DOCX and survive Google's conversion. Sakura-inspired typography via a versioned reference.docx.

## What to build

A `md2gdocs-docx` CLI command that converts a Markdown file to a Google Doc via Pandoc's DOCX output instead of HTML. This path solves the image problem: Pandoc embeds local images as binary in the DOCX, and Google preserves them during import.

End-to-end: user runs `md2gdocs-docx article.md` → Pandoc converts to DOCX (with embedded images) → uploads to Drive as Google Doc → prints URL → opens in browser.

### Files to create

- `scripts/bin/markdown/md2gdocs/md2gdocs-docx` — ZSH wrapper
- `scripts/bin/markdown/md2gdocs/md2gdocs-docx.js` — Pandoc conversion + Drive upload
- `scripts/bin/markdown/md2gdocs/reference.docx` — Versioned style template (Sakura-inspired typography)
- `scripts/bin/markdown/md2gdocs/__tests__/md2gdocs-docx.js` — unit tests

### Behavior

- Accepts one positional argument: path to a Markdown file
- Accepts `--title` flag (optional): overrides the Doc title. Default: filename without extension.
- Calls Pandoc via `firost.run` with:
  - `cwd` set to `path.dirname(filepath)` so local image paths resolve correctly
  - `--extract-media=/tmp/oroshi/md2gdocs/` to download and embed remote images
  - `--reference-doc=reference.docx` for Sakura-inspired styling
  - Output to `/tmp/oroshi/md2gdocs/<title>.docx`
- Uploads the DOCX to Drive with `mimeType: 'application/vnd.google-apps.document'` (Google converts to native Doc)
- Target folder: same `OROSHI_GOOGLE_DRIVE_DOCS_FOLDER_ID` env var
- Prints the Google Docs URL to stdout
- Opens the URL in the browser via `xdg-open`
- Cleans up `/tmp/oroshi/md2gdocs/` after upload

### Styling (reference.docx)

Generated programmatically, Sakura-inspired for high readability:
- **Font**: Inter or Roboto (native in Google Docs)
- **Body**: 12pt, line-spacing ~1.5
- **Headings**: H1 24pt / H2 20pt / H3 16pt, bold, more space above than below
- **Blockquotes** (`Block Text` style): left indent + gray color
- **Links** (`Hyperlink` style): teal color (#1d7484)
- **Tables**: borders, header background

Workflow to create: `pandoc --print-default-data-file reference.docx` → modify styles in the OOXML → commit.

### Image handling

- **Local images** (`![alt](./img/foo.png)`): resolved by Pandoc via `cwd`, embedded as binary in DOCX
- **Remote images** (`![alt](https://example.com/img.png)`): downloaded by Pandoc via `--extract-media`, embedded in DOCX
- **Result**: Google Doc is fully static, no external references

### No code sharing with md2gdocs.js

This is a standalone file. Duplicates `titleFromPath`, `getAuth`, `FOLDER_ID`, CLI parsing. If this approach replaces the HTML pipeline, the old file gets deleted.

## Behavioral Tests

**Pandoc called with correct arguments:**
- Given a file at `/path/to/article.md`, Pandoc is called with cwd `/path/to/`, `--reference-doc`, `--extract-media`, output path

**Upload uses DOCX mimeType:**
- The Drive API call uses `application/vnd.openxmlformats-officedocument.wordprocessingml.document` as media mimeType

**Default title from filename:**
- Given `my-article.md`, creates a Doc titled "my-article"

**Custom title via --title:**
- Given `--title "Custom"`, creates a Doc titled "Custom"

**URL format:**
- Returns `https://docs.google.com/document/d/<id>/edit`

**Opens browser:**
- `xdg-open` is called with the Doc URL

**Temp cleanup:**
- `/tmp/oroshi/md2gdocs/` is cleaned up after upload

## Acceptance criteria

- [ ] `md2gdocs-docx article.md` creates a Google Doc with images and prints its URL
- [ ] Local images appear in the Google Doc
- [ ] Remote images appear in the Google Doc (snapshot, not reference)
- [ ] Typography is Sakura-inspired (readable fonts, good spacing)
- [ ] `reference.docx` is versioned in the repo
- [ ] Opens the Doc in the browser after creation
- [ ] Temp files are cleaned up
- [ ] Unit tests pass with mocked `firost.run` and Drive API
