## PRD

[Lua toolchain PRD](./PRD.md)

## What to build

An install script that downloads the selene binary from GitHub releases and installs it to `~/local/bin/selene`, following the same pattern as other binary install scripts in `scripts/install/`. Also add a `selene.toml` config and a `vim.toml` standard library definition at the root of the Neovim config directory so selene recognises `vim.*` globals without flagging them as unknown.

## Acceptance criteria

- [ ] `selene --version` works from the terminal after running the install script
- [ ] `selene.toml` references the `vim` standard library so `vim.*` calls are not flagged as unknown globals
- [ ] Running selene on a clean Lua file exits 0
- [ ] Running selene on a file with a known violation exits 1

## Blocked by

None — can start immediately
