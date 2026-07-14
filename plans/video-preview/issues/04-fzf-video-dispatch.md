## TLDR

Wire video preview into the fzf file browser dispatcher.

## What to build

Add video support to `scripts/bin/fzf/__lib/fzf-fs-preview.zsh`:

1. Add `fzf-preview-file-video` function:
   - Call `fzf-preview-header` for the file header
   - Show metadata line: filesize (`filesize-human`), duration (`video-duration`), dimensions (`video-dimensions`)
   - Call `fzf-preview-thumbnail "$fullPath" "video-thumbnail"` to get cached contact sheet
   - Display via `img-display --no-metadata --fzf-preview`
2. Add `"video"` case to the dispatch block in `fzf-preview`, routing to `fzf-preview-file-video`

Mirrors the existing `fzf-preview-file-pdf` pattern.

## Behavioral Tests

**Dispatch:**
- calls `fzf-preview-file-video` when `filetypes-group` returns "video"

**Metadata:**
- shows filesize, duration, and dimensions in preview output

**Integration:**
- calls `fzf-preview-thumbnail` with `video-thumbnail` as extractor

## Acceptance criteria

- [ ] `fzf-preview-file-video` function exists in `fzf-fs-preview.zsh`
- [ ] Video files dispatch to `fzf-preview-file-video`
- [ ] Metadata header shows filesize, duration, and dimensions
- [ ] Contact sheet displayed via `img-display --fzf-preview`
- [ ] Tests pass
