## TLDR

Install the stylua binary for CLI use by `lua-fix`.

## What to build

An install script that downloads the stylua binary from GitHub releases to `~/local/bin/stylua`, following the same pattern as the selene install script. Stylua is already configured in Neovim via conform; this makes it available on the CLI.

## Acceptance criteria

- [ ] `stylua --version` works from the terminal after running the install script
- [ ] `stylua --check <file>` on a well-formatted Lua file exits 0
- [ ] `stylua --check <file>` on a poorly-formatted Lua file exits 1
