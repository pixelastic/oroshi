## PRD

[Lua toolchain PRD](./PRD.md)

## What to build

Wire `lua-lint` into Neovim as the linter for Lua files, replacing the diagnostic-only role currently played by `lua_ls`. The `lua.lua` filetype module gains a `configureLinter` function that registers a custom nvim-lint linter invoking `lua-lint`, parsing its JSON output into Neovim diagnostics.

Note: `lua_ls` stays active for completion, hover, and go-to-definition. `stylua` via conform stays as the formatter. Only the linting diagnostics source changes.

This issue is HITL: after implementation, a human must open a Lua file in Neovim and confirm that:
- `lua-lint` violations appear as diagnostics inline
- `lua_ls` completion still works
- No duplicate or conflicting diagnostics from both sources

## Acceptance criteria

- [ ] `configureLinter` added to `lua.lua` filetype module
- [ ] Opening a Lua file with a `vim.deepcopy(` call shows a diagnostic in Neovim
- [ ] `lua_ls` completion and go-to-definition still work
- [ ] `stylua` formatting on save still works
- [ ] No spurious duplicate diagnostics

## Blocked by

- issue-004 (lua-lint orchestrator must exist)
