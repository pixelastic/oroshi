## TLDR

Install selene binary and add selene.toml + vim.yml config so selene recognises vim.* globals.

## What to build

An install script that downloads the selene binary from GitHub releases to `~/local/bin/selene`. Also add a `selene.toml` and a `vim.yml` standard library definition at `config/_languages/lua/selene/` so selene can lint Neovim Lua files without flagging `vim.*` as unknown globals.

## Acceptance criteria

- [x] `selene --version` works from the terminal after running the install script
- [x] `selene.toml` references the `vim` standard library
- [x] Running selene on a clean Lua file exits 0
- [x] Running selene on a file with a known violation exits 1
