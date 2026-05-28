## TLDR

`lua-fix` script that applies stylua in-place to one or more Lua files.

## What to build

A `lua-fix` script that accepts one or multiple Lua file paths and formats each in place using stylua. Mirrors `zshfix`. Stylua options (spaces, indent width 2) must match the existing Neovim conform configuration so CLI and editor produce identical output.

## Acceptance criteria

- [ ] `lua-fix <file>` formats the file in place
- [ ] `lua-fix file1.lua file2.lua` formats multiple files
- [ ] After `lua-fix`, `stylua --check <file>` exits 0
- [ ] Formatting produced by `lua-fix` matches what Neovim's conform produces on save
