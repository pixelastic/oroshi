## TLDR

Prefix all four FZF source commands in disk.lua with `bin-zsh` so they work when fzf.vim switches &shell to sh.

## What to build

In `tools/vim/nvim/config/lua/oroshi/plugins/enabled/disk.lua`, normalize all four `fzf#run()` calls to use string source prefixed with `bin-zsh`:

- **ctrl-p** (onCtrlP): change `source = "ctrl-p --source"` to `source = "bin-zsh ctrl-p --source"`
- **ctrl-shift-p** (onCtrlShiftP): change `source = "ctrl-shift-p --source"` to `source = "bin-zsh ctrl-shift-p --source"`
- **ctrl-g** (onCtrlG): replace `local source = vim.fn.systemlist("ctrl-g --source")` with inline string `source = "bin-zsh ctrl-g --source"`
- **ctrl-shift-g** (onCtrlShiftG): replace `local source = vim.fn.systemlist("ctrl-shift-g --source")` with inline string `source = "bin-zsh ctrl-shift-g --source"`

For ctrl-g and ctrl-shift-g, remove the now-unused `local source` variable line since the source moves inline into the `fzf#run()` dict.

## Acceptance criteria

- [ ] All four `fzf#run()` calls use string source prefixed with `bin-zsh`
- [ ] No `systemlist("... --source")` calls remain
- [ ] File passes `yarn run lint:fix` (if applicable) or has no syntax errors
