## PRD

[Lua toolchain PRD](./PRD.md)

## What to build

Three wiring changes to complete the test act:

1. **lint-staged**: add `lua-test` to the Lua file pattern so staged Lua files run their specs before commit
2. **CLAUDE.md**: document `lua-test <filepath>` as the command for running Lua tests
3. **git-file-test**: extend the existing autoloaded function to also call `lua-test-path` for `.lua` files and run the resolved specs alongside the BATS tests

## Acceptance criteria

- [ ] Committing a staged Lua file with a failing spec blocks the commit
- [ ] Committing a staged Lua file with a passing spec (or no spec) succeeds
- [ ] `CLAUDE.md` documents `lua-test <filepath>`
- [ ] `git-file-test` run in a repo with a dirty Lua file that has a spec runs that spec
- [ ] `git-file-test` run with no dirty Lua files does not error

## Blocked by

- issue-011 (lua-test must exist)
