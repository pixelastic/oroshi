## Guidance

- The only file to modify is `tools/vim/nvim/config/lua/oroshi/plugins/enabled/disk.lua`
- DO NOT use the Write tool on this file — it contains nerd font glyphs (U+E000–U+F8FF) that Write silently strips. Use Edit only.
- Lint with `yarn run lint:fix tools/vim/nvim/config/lua/oroshi/plugins/enabled/disk.lua`
- Manual test: open Neovim, press Ctrl-P, confirm files appear progressively
- The `bin-zsh` wrapper is at `scripts/bin/bin-zsh` — do not modify it
- For ctrl-g and ctrl-shift-g, the `local source = vim.fn.systemlist(...)` line must be removed entirely (not just unused)

## Discoveries
