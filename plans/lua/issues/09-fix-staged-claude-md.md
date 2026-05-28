## TLDR

Wire `lua-fix` into lint-staged and document it in CLAUDE.md.

## What to build

Three wiring changes to complete the fix act:

1. **lint-staged**: add `lua-fix` to the Lua file pattern so staged files are auto-formatted before commit
2. **CLAUDE.md**: document `lua-fix <filepath>` as the formatting command
3. Verify the lint-staged Lua pattern now runs both `lua-lint` and `lua-fix`

## Acceptance criteria

- [ ] Committing a staged Lua file auto-applies stylua formatting via lint-staged
- [ ] `CLAUDE.md` documents `lua-fix <filepath>`
- [ ] The lint-staged Lua pattern runs both `lua-lint` and `lua-fix`
