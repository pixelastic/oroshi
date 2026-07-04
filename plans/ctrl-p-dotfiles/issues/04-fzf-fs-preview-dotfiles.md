## TLDR

Fix `fzf-preview-header` so dotfile config files display their correct icon and color in the preview pane.

## What to build

In the `fzf-preview-header` function inside `fzf-fs-preview.zsh`, replace the inline extension extraction with a call to `filetypes-key` (issue 01). Use the returned key to look up both `FILETYPES[key:icon]` and `FILETYPES[key:color]`. This correctly resolves `.fdignore` to `_fdignore`, retrieving the registered icon glyph and color 174.

The executable fallback (triggered when color is still empty after the lookup) remains unchanged.

## Behavioral Tests

**Dotfile preview header shows correct color**
- Preview header for `.fdignore` with `FILETYPES[_fdignore:color]=174` → output contains ANSI color 174

**Dotfile preview header shows correct icon**
- Preview header for `.fdignore` with `FILETYPES[_fdignore:icon]=<glyph>` → output contains the glyph

**Regular file behavior unchanged**
- `.js` file still gets its extension-based color and icon

## Acceptance criteria

- [ ] Dotfile preview header renders in the correct FILETYPES color
- [ ] Dotfile preview header renders the correct FILETYPES icon
- [ ] All existing `fzf-fs-preview.bats` tests still pass
- [ ] New bats test for dotfile preview header added (stub `_fdignore:color` and `_fdignore:icon` in mock)
- [ ] `zsh-lint` passes
- [ ] `bats-lint` passes on the test file
