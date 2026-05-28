## TLDR

Wire `lua-test` into lint-staged, CLAUDE.md, and `git-file-test`.

## What to build

Three wiring changes to complete the test act:

1. **lint-staged**: add `lua-test` to the Lua file pattern so staged files run their specs before commit
2. **CLAUDE.md**: document `lua-test <filepath>` as the testing command
3. **git-file-test**: extend the autoloaded function to call `lua-test-path` for `.lua` files and run resolved specs alongside BATS tests

## Acceptance criteria

- [ ] Committing a staged Lua file with a failing spec blocks the commit
- [ ] Committing a staged Lua file with a passing spec (or no spec) succeeds
- [ ] `CLAUDE.md` documents `lua-test <filepath>`
- [ ] `git-file-test` with a dirty Lua file that has a spec runs that spec
- [ ] `git-file-test` with no dirty Lua files does not error
