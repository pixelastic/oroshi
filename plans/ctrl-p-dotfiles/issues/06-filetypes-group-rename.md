## TLDR

Move `filetype-group` into the `filetypes` domain as `filetypes-group`.

## What to build

- Rename `misc/filetype-group` → `filetypes/filetypes-group`
- Rename `misc/__tests__/filetype-group.bats` → `filetypes/__tests__/filetypes-group.bats`
- Update all callers from `filetype-group` to `filetypes-group`:
  - `scripts/bin/fzf/__lib/fzf-fs-preview.zsh`
  - `tools/term/zsh/config/functions/autoload/img/img-display`
  - `scripts/bin/fzf/fzf-git-files-dirty`
  - `scripts/bin/fzf/fzf-git-files-dirty-stageable`
  - `scripts/bin/better-cat`

No logic changes — the function body already uses `filetypes-key` correctly.

## Behavioral Tests

**Existing behavior unchanged**
- `filetypes-group .fdignore` → `config`
- `filetypes-group .gitignore` → `config`
- `filetypes-group file.png` → `image`

## Scaffolding Tests

- Rename the test file; update the function name referenced inside it.

## Acceptance criteria

- [ ] `filetypes-group` lives in `filetypes/` alongside sibling functions
- [ ] `filetype-group` (singular) no longer exists
- [ ] All callers updated to `filetypes-group`
- [ ] `zsh-lint` passes on the function
- [ ] `bats-lint` passes on the test file
- [ ] All existing tests pass
