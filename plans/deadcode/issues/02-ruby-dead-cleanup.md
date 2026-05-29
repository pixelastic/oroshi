## TLDR

Delete two broken/empty Ruby test files from `music-metadata-update/tests/`.

## What to build

Delete two files in `music-metadata-update/tests/`:
- `mp3.test.rb` — has a `require` pointing to a file that does not exist; it cannot run
- `music-metadata-update.test.rb` — empty template, no tests

If the `tests/` directory is empty after both deletions, delete it too.

The production Ruby engines in `music-metadata-update/` are not touched.

## Acceptance criteria

- [ ] `mp3.test.rb` is deleted
- [ ] `music-metadata-update.test.rb` is deleted
- [ ] `tests/` directory is deleted if empty
- [ ] All other files in `music-metadata-update/` are untouched
