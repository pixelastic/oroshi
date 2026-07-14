## TLDR

Rename `fzf-preview-document-cover` → `fzf-preview-thumbnail` and `pdf-cover-extract` → `pdf-thumbnail`.

## What to build

Two renames to generalize naming before adding video support:

1. Rename function `fzf-preview-document-cover` to `fzf-preview-thumbnail` in `fzf-fs-preview.zsh`. Update callers: `fzf-preview-file-pdf`, `fzf-preview-file-ebook`.
2. Rename autoload file `pdf-cover-extract` to `pdf-thumbnail` in the `pdf/` autoload directory. Update its caller in `fzf-fs-preview.zsh`.
3. Update existing tests in `fzf-fs-preview.bats` to use new names.

## Scaffolding Tests

- `fzf-preview-document-cover` string does not appear in `fzf-fs-preview.zsh`
- `pdf-cover-extract` string does not appear in `fzf-fs-preview.zsh`
- `pdf-cover-extract` file does not exist in the `pdf/` autoload directory

## Acceptance criteria

- [ ] `fzf-preview-document-cover` renamed to `fzf-preview-thumbnail` everywhere
- [ ] `pdf-cover-extract` renamed to `pdf-thumbnail` (file + all references)
- [ ] Existing tests updated and passing
- [ ] PDF and ebook previews still work (no functional change)
