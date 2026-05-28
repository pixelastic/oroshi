## TLDR

Wire `lua-lint` into Neovim as the inline diagnostic source for Lua files (HITL).

## What to build

Add a `configureLinter` function to the `lua.lua` filetype module that registers a custom nvim-lint linter invoking `lua-lint` and parsing its JSON output into Neovim diagnostics.

`lua_ls` stays active for completion and go-to-definition. `stylua` via conform stays as the formatter. Only the linting diagnostics source changes.

**HITL**: after implementation, a human opens a Lua file in Neovim to verify diagnostics appear and no regressions exist.

## Acceptance criteria

- [ ] `configureLinter` added to the `lua.lua` filetype module
- [ ] Opening a Lua file with `vim.deepcopy(` shows the `noVimDeepcopy` diagnostic inline
- [ ] `lua_ls` completion and go-to-definition still work
- [ ] `stylua` formatting on save still works
- [ ] No spurious duplicate diagnostics
