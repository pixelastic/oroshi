## PRD

[Lua toolchain PRD](./PRD.md)

## What to build

Three wiring changes to complete the lint act:

1. **lint-staged**: add a pattern for Neovim Lua files that runs `lua-lint` on staged files before commit
2. **CLAUDE.md**: document `lua-lint <filepath>` as the command for linting Lua
3. **git-file-lint**: extend the existing autoloaded function to also detect `.lua` files and run `lua-lint` on them, formatting the JSON output the same way it formats ZSH lint output

## Acceptance criteria

- [ ] Staging and committing a Lua file with a violation is blocked by the pre-commit hook
- [ ] Staging and committing a clean Lua file succeeds
- [ ] `CLAUDE.md` documents `lua-lint <filepath>`
- [ ] `git-file-lint` run in a repo with a dirty Lua file reports lua-lint violations
- [ ] `git-file-lint` run with no dirty Lua files does not error

## Blocked by

- issue-004 (lua-lint orchestrator)
- issue-005 (Neovim integration — lint act fully complete)
