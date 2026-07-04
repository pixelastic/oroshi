## TLDR

Fix `filetype-group` so it returns the correct group for dotfile config files.

## What to build

In `filetype-group`, replace the inline `${filepath:e:l}` extension extraction with a call to `filetypes-key` (issue 01). Use `$REPLY` as the key for the `FILETYPES[key:group]` lookup. This makes `.fdignore` resolve to key `_fdignore` and return group `config` instead of empty string.

## Behavioral Tests

**Dotfile returns correct group**
- `filetype-group .fdignore` → `config`
- `filetype-group .gitignore` → `config`

**Regular file behavior unchanged**
- `filetype-group file.png` → `image`

## Scaffolding Tests

None — the change is behavioral (adds correct dotfile group resolution), not a pure refactor.

## Acceptance criteria

- [ ] `filetype-group .fdignore` returns `config`
- [ ] Regular file group resolution unchanged
- [ ] New bats test added for dotfile group case
- [ ] `zsh-lint` passes
- [ ] `bats-lint` passes on the test file
