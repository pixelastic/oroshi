## PRD

[Lua toolchain PRD](./PRD.md)

## What to build

A `lua-fix` script that applies stylua in-place to one or more Lua files. Mirrors `zshfix`: accepts one or multiple file paths and formats each one. The stylua options (indent type: spaces, indent width: 2) must match the existing Neovim conform configuration so that the CLI and editor produce identical output.

## Acceptance criteria

- [ ] `lua-fix <file>` formats the file in place
- [ ] `lua-fix file1.lua file2.lua` formats multiple files
- [ ] After `lua-fix`, running `stylua --check <file>` exits 0
- [ ] The formatting produced by `lua-fix` matches what Neovim's conform produces on save

## Blocked by

- issue-007 (stylua must be installed)
