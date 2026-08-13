## TLDR

Create `misc/file/` subdomain, migrate `urls` as `file-url-list`, move `file-count` and `file-hash` into it.

## What to build

Create new subdomain `tools/term/zsh/config/functions/autoload/misc/file/`.

Migrate `urls` from `scripts/bin/urls` to `misc/file/file-url-list`:
- Rename to `file-url-list`
- Remove shebang
- Add header comment with usage
- Add `setopt local_options err_return`
- Keep existing logic (`cat "$@" | grep | sort | uniq`)

Move existing functions into the new subdomain:
- `misc/file-count` → `misc/file/file-count`
- `misc/file-hash` → `misc/file/file-hash`

Move existing tests:
- `misc/__tests__/file-count.bats` → `misc/file/__tests__/file-count.bats`
- `misc/__tests__/file-hash.bats` → `misc/file/__tests__/file-hash.bats`

Delete original `scripts/bin/urls`.

## Scaffolding Tests

- `file-url-list` is callable and extracts URLs from a file
- `file-count` still works from new location
- `file-hash` still works from new location

## Acceptance criteria

- [ ] `file-url-list` exists as autoloaded function in `misc/file/`
- [ ] `file-count` moved to `misc/file/`
- [ ] `file-hash` moved to `misc/file/`
- [ ] Tests moved to `misc/file/__tests__/`
- [ ] All tests pass
- [ ] `file-url-list` passes `zsh-lint`
- [ ] Original `urls` script deleted
