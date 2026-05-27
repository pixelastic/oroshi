## PRD

[Lua toolchain PRD](./PRD.md)

## What to build

Three wiring changes to complete the fix act:

1. **lint-staged**: add `lua-fix` to the Lua file pattern so staged Lua files are auto-formatted before commit
2. **CLAUDE.md**: document `lua-fix <filepath>` as the command for formatting Lua
3. **git-file-lint**: extend to also run `lua-fix --check` style reporting if needed, or confirm no change required

## Acceptance criteria

- [ ] Committing a staged Lua file auto-applies stylua formatting via lint-staged
- [ ] `CLAUDE.md` documents `lua-fix <filepath>`
- [ ] The lint-staged Lua pattern now runs both `lua-lint` and `lua-fix`

## Blocked by

- issue-006 (lint-staged Lua pattern already exists)
- issue-008 (lua-fix must exist)
