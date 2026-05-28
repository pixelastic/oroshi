## TLDR

Wire `lua-lint` into lint-staged, CLAUDE.md, and `git-file-lint`.

## What to build

Three wiring changes to complete the lint act:

1. **lint-staged**: add a pattern for Neovim Lua files that runs `lua-lint` on staged files before commit
2. **CLAUDE.md**: document `lua-lint <filepath>` as the linting command
3. **git-file-lint**: extend the autoloaded function to detect `.lua` files and run `lua-lint`, formatting JSON output consistently with ZSH lint output

## Acceptance criteria

- [ ] Committing a Lua file with a violation is blocked by the pre-commit hook
- [ ] Committing a clean Lua file succeeds
- [ ] `CLAUDE.md` documents `lua-lint <filepath>`
- [ ] `git-file-lint` with a dirty Lua file reports lua-lint violations
- [ ] `git-file-lint` with no dirty Lua files does not error
