## PRD

[Lua toolchain PRD](./PRD.md)

## What to build

An install script that downloads the stylua binary from GitHub releases and installs it to `~/local/bin/stylua`, following the same pattern as the selene install script. Stylua is already configured inside Neovim via conform; this makes it available on the CLI for use by `lua-fix`.

## Acceptance criteria

- [ ] `stylua --version` works from the terminal after running the install script
- [ ] Running `stylua --check <file>` on a well-formatted Lua file exits 0
- [ ] Running `stylua --check <file>` on a poorly-formatted Lua file exits 1

## Blocked by

None — can start immediately
