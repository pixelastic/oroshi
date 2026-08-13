## TLDR

Consolidate all `better-*` functions into `misc/better/`, including migrating `better-find` and `better-grep` from `scripts/bin/`.

## What to build

Create new subdomain `tools/term/zsh/config/functions/autoload/misc/better/`.

Migrate from `scripts/bin/`:
- `better-find` → rewrite from bash to zsh autoload format, move to `misc/better/`
- `better-grep` → convert to autoload format, move to `misc/better/`

Move from `misc/` root:
- `better-cat` → `misc/better/better-cat`
- `better-ls` → `misc/better/better-ls`
- `better-rm` → `misc/better/better-rm`
- `better-rmdir` → `misc/better/better-rmdir`
- `better-ydotool` → `misc/better/better-ydotool`

Move from other domains:
- `video/better-vlc` → `misc/better/better-vlc`
- `system/better-keepass` → `misc/better/better-keepass`
- `ebook/better-ebook-viewer` → `misc/better/better-ebook-viewer`

Move tests:
- `scripts/bin/__tests__/better-ls.bats` → `misc/better/__tests__/better-ls.bats`
- `misc/__tests__/better-rm.bats` → `misc/better/__tests__/better-rm.bats`
- `misc/__tests__/better-rmdir.bats` → `misc/better/__tests__/better-rmdir.bats`

Delete original scripts from `scripts/bin/`.

## Scaffolding Tests

- All 10 `better-*` functions are callable from `misc/better/`
- No `better-*` functions remain in other domains (except functions_source references)
- Original bin scripts deleted

## Acceptance criteria

- [ ] `misc/better/` subdomain created with all 10 `better-*` functions
- [ ] `better-find` and `better-grep` rewritten to zsh autoload format
- [ ] All tests moved to `misc/better/__tests__/`
- [ ] All tests pass
- [ ] New functions pass `zsh-lint`
- [ ] No `better-*` functions remain in `misc/` root, `video/`, `system/`, `ebook/`
- [ ] Original scripts deleted from `scripts/bin/`
- [ ] Aliases (`f`, `g`) still work
