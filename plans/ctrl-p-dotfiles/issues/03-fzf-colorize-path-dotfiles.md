## TLDR

Fix `fzf-colorize-path` so dotfile config files render in their defined color in the ctrl-p list.

## What to build

In `fzf-colorize-path`, replace the inline extension extraction with a call to `filetypes-key` (issue 01). The returned key is used directly to look up `FILETYPES[key:color]`. This correctly resolves dotfiles like `.fdignore` to their `_fdignore` key and retrieves color 174 (violet) instead of falling through to no color.

The executable fallback remains unchanged — it only triggers when no FILETYPES color is found.

## Behavioral Tests

**Dotfile with registered `_`-key gets its color**
- `.fdignore` with `FILETYPES[_fdignore:color]=174` → REPLY contains ANSI color 174 around filename

**Regular file behavior unchanged**
- `app.js` with `FILETYPES[js:color]=200` → REPLY contains ANSI color 200
- No-extension executable → REPLY contains executable color

**Directory segment still colorized separately**
- `config/.fdignore` → directory segment in directory color, filename in filetype color

## Acceptance criteria

- [ ] `.fdignore` and similar dotfiles render in their defined FILETYPES color in the fzf list
- [ ] All existing `fzf-colorize-path.bats` tests still pass
- [ ] New bats test for dotfile color case added (stub `_fdignore:color` in mock)
- [ ] `zsh-lint` passes
- [ ] `bats-lint` passes on the test file
