## TLDR

Replace full-file CRC32 with first-1MB md5 in `file-hash`.

## What to build

`file-hash` currently reads the entire file to compute a CRC32 hash. Replace with `head -c 1048576 | md5sum` — reads only the first 1 MB, fast even for multi-GB videos. Same interface: `file-hash <path>` → stdout hash string.

Files under 1 MB are fully read, so behavior is equivalent for small files (PDFs, images).

## Behavioral Tests

**Stable hash:**
- produces the same hash when called twice on the same file
- produces a different hash for files with different content
- produces a hash for files smaller than 1 MB

## Acceptance criteria

- [ ] `file-hash` uses `head -c 1048576 | md5sum` instead of `crc32`
- [ ] Existing callers (`fzf-fs-preview.zsh`, `notion-icon-auto`) work without changes
- [ ] Tests pass
