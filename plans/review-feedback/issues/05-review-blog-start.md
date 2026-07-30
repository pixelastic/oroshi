## TLDR

Deterministic script that resolves user input (file path or URL) into a Google Docs URL ready for annotation.

## What to build

A `review-blog-start` ZSH script that takes a file path or Google Docs URL, ensures a Google Doc exists in the right folder, and returns JSON with the URL. This is the entry point called by the `/review-blog` skill.

End-to-end: skill calls `review-blog-start ./article.md` → detects file path → calls `md2gdocs` → returns `{"url": "https://docs.google.com/..."}`. Or: skill calls `review-blog-start https://docs.google.com/document/d/xxx/edit` → detects URL → returns `{"url": "https://docs.google.com/document/d/xxx/edit"}`.

### Files to create

- `scripts/bin/ai/review-blog/review-blog-start` — ZSH script
- `scripts/bin/ai/review-blog/__tests__/review-blog-start.bats` — bats tests

### Behavior

- Accepts one argument: file path or Google Docs URL
- Detection logic: if argument starts with `https://docs.google.com/` → it's a URL; otherwise → it's a file path
- File path case: verify file exists, call `md2gdocs <path>`, capture URL from stdout
- URL case: pass through as-is
- Output JSON to stdout: `{"url": "..."}`
- Return early with error if file doesn't exist or `md2gdocs` fails

## Behavioral Tests

**File path detection:**
- Given a path like `./article.md`, detects it as a file path and calls `md2gdocs`

**URL detection:**
- Given a Google Docs URL, detects it as a URL and passes it through

**JSON output:**
- Output is valid JSON with a `url` field

**Missing file:**
- Given a non-existent file path, exits with error

## Acceptance criteria

- [ ] Correctly distinguishes file paths from Google Docs URLs
- [ ] Calls `md2gdocs` for file paths, returns URL from its output
- [ ] Passes Google Docs URLs through unchanged
- [ ] Outputs valid JSON with `url` field
- [ ] Errors cleanly on missing file
- [ ] Bats tests pass with mocked `md2gdocs`
