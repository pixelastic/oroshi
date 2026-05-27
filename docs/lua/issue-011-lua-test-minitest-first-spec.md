## PRD

[Lua toolchain PRD](./PRD.md)

## What to build

Four things delivered together as a complete end-to-end test slice:

1. **mini.test plugin**: add `echasnovski/mini.test` to the lazy.nvim plugin spec
2. **minit.lua**: a bootstrap file in the Neovim config directory that prepends the mini.test plugin path onto the runtime path and runs the spec file passed as argument via `MiniTest.run_file()`
3. **lua-test**: a ZSH script that accepts a Lua file path, resolves the spec via `lua-test-path` if needed, and invokes `nvim --headless -l minit.lua -- <spec>`. Exits 0 if all tests pass, 1 if any fail.
4. **First spec**: `__tests__/lodash_spec.lua` in the functions directory, testing a single function from `lodash.lua` to validate the entire pipeline end-to-end. Only one function is tested — the goal is infrastructure validation, not coverage.

## Acceptance criteria

- [ ] `mini.test` is listed as a lazy.nvim plugin and installs on `Lazy sync`
- [ ] `minit.lua` exists and correctly bootstraps mini.test from the lazy data directory
- [ ] `lua-test __tests__/lodash_spec.lua` runs and exits 0 when the spec passes
- [ ] `lua-test lodash.lua` resolves to `__tests__/lodash_spec.lua` and runs it
- [ ] `lua-test` exits 1 when a test fails
- [ ] `__tests__/lodash_spec.lua` contains one passing test for one lodash function
- [ ] `lua-test` exits 0 silently when called on a Lua file with no spec

## Blocked by

- issue-010 (lua-test-path must exist)
