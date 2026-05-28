## TLDR

`lua-test` runner + mini.test plugin + first `lodash_spec.lua` to validate the full pipeline.

## What to build

Four things delivered together as an end-to-end slice:

1. **mini.test plugin**: add `echasnovski/mini.test` to the lazy.nvim plugin spec
2. **minit.lua**: bootstrap file that prepends the mini.test path onto runtimepath and runs the spec via `MiniTest.run_file()`
3. **lua-test**: ZSH script that accepts a Lua file path, resolves the spec via `lua-test-path` if needed, and invokes `nvim --headless -l minit.lua -- <spec>`. Exit 0 if all tests pass, exit 1 if any fail.
4. **First spec**: `__tests__/lodash_spec.lua` testing one function from `lodash.lua` to validate the pipeline end-to-end. Goal is infrastructure validation, not coverage.

## Acceptance criteria

- [ ] `mini.test` is listed as a lazy.nvim plugin
- [ ] `minit.lua` exists and bootstraps mini.test from the lazy data directory
- [ ] `lua-test <spec_file>` runs and exits 0 when the spec passes
- [ ] `lua-test <source_file>` resolves to its spec and runs it
- [ ] `lua-test` exits 1 when a test fails
- [ ] `lua-test` exits 0 silently on a file with no spec
- [ ] `__tests__/lodash_spec.lua` contains one passing test
