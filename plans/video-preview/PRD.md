## Problem Statement

The fzf file browser has no preview for video files. Selecting a video shows nothing useful — unlike images and PDFs which already display visual previews. Users browsing directories with video files have no way to visually identify content without opening each file.

## Solution

When a video file is selected in fzf, generate a 4x4 thumbnail contact sheet (16 frames sampled evenly across the video's duration) via ffmpeg, cache it as a PNG, and display it using the existing Kitty icat pipeline. A metadata header shows filesize, duration, and dimensions.

## User Stories

1. As a user browsing files in fzf, I want to see a visual summary of a video file when I select it, so that I can identify videos without opening them.
2. As a user previewing a video I've already seen, I want instant preview from cache, so that repeat previews don't re-process.
3. As a user previewing a large video, I want the cache key computed quickly, so that I don't wait seconds just for hashing before ffmpeg even starts.
4. As a user, I want to see filesize, duration, and dimensions in the preview header, so that I know the video's properties at a glance.
5. As a user previewing a very short video (< 17s), I want the contact sheet to still render, so that all videos produce a preview regardless of length.
6. As a user previewing a corrupt or unsupported video, I want the preview to fail silently, so that fzf doesn't hang or show error output.

## Implementation Decisions

- **Hashing:** `file-hash` is replaced from full-file CRC32 to first-1MB md5sum. This keeps the same interface (`file-hash <path>` → stdout) but avoids reading multi-GB video files entirely. Files under 1 MB are fully read, so behavior is equivalent for small files like PDFs.
- **Caching helper rename:** `fzf-preview-document-cover` is renamed to `fzf-preview-thumbnail` to reflect its generic role (any extractor, not just document covers). All existing callers (PDF, ebook) are updated.
- **PDF extractor rename:** `pdf-cover-extract` is renamed to `pdf-thumbnail` for naming consistency with the new `video-thumbnail`.
- **New `video-thumbnail` function:** Accepts `<input> <output>`, computes duration via ffprobe, derives interval (`duration / 17`, floored at 1), and generates a 4x4 contact sheet via ffmpeg's `fps` + `tile` filters at 240px width. Follows the same contract as `pdf-thumbnail` so `fzf-preview-thumbnail` can call it as a generic extractor.
- **Contact sheet formula:** `fps=1/${interval},scale=240:-1,tile=4x4` produces 16 frames. Dividing by 17 (not 16) skips the very first and last frames, which are often black.
- **Short video handling:** Interval is floored at 1 second. For videos shorter than 16 seconds, some tiles will contain duplicate frames. No grid size adaptation — ffmpeg handles this gracefully.
- **Video dispatch:** A new `fzf-preview-file-video` function is added to the preview dispatcher, triggered when `filetypes-group` returns `"video"`. It shows header + metadata (filesize, duration, dimensions), calls `fzf-preview-thumbnail` with `video-thumbnail`, and displays via `img-display --fzf-preview`.

## Testing Decisions

Good tests verify external behavior (inputs → outputs), not implementation details. They mock collaborators (external commands), not filesystem state.

Modules with tests:
- **`file-hash`** — verify it produces a stable hash for a given file, and that the hash changes when content changes. Prior art: existing bats tests in the repo.
- **`video-thumbnail`** — verify it produces a PNG output file given a video input. Requires a small synthetic test video (can be generated with ffmpeg in setup). Prior art: `pdf-cover-extract` usage patterns.
- **`fzf-fs-preview.zsh`** — update existing tests for the `fzf-preview-document-cover` → `fzf-preview-thumbnail` rename. Add a test for the video dispatch case. Prior art: `scripts/bin/fzf/__lib/__tests__/fzf-fs-preview.bats`.

Module without tests:
- **`pdf-thumbnail`** — pure rename, no logic change. Existing tests cover the caching layer.

## Out of Scope

- Registering `webm` and `mov` in the filetype definitions
- Adapting grid size for short videos
- Fallback display when ffmpeg fails
- Any changes to `img-display`

## Further Notes

The implementation mirrors the existing `pdf-thumbnail` → `img-display --fzf-preview` pipeline. No new dependencies — ffmpeg and ffprobe are already installed.
