## Guidance

**Goal:** Make NeoVim load its Lua config from `$OROSHI_ROOT` at startup, enabling worktree-based config testing.

**Key files (relative to repo root):**
- `tools/vim/nvim/config/init.lua` — entry point, symlinked to `~/.config/nvim/init.lua`
- `tools/vim/nvim/config/lua/oroshi/` — main Lua config tree (renamed from `config/config/` in issue 01)
- `tools/vim/nvim/config/after/` — treesitter query overrides
- `tools/vim/nvim/deploy` — deploy script that creates symlinks in `~/.config/nvim/`
- `tools/vim/nvim/config/lua/oroshi/ui/statusline.lua` — contains the hardcoded path fixed in issue 02

**Conventions:**
- `$OROSHI_ROOT` is always set by zshenv — no fallback needed in Lua
- `vim.env.OROSHI_ROOT` is how Lua reads it
- runtimepath prepend goes in `init.lua` before any `require()` call
- No automated tests for Lua or deploy script changes in this project
- Use `git mv` for the directory rename to preserve history
- No import paths (`require("oroshi/X")`) need to change in any file

**Testing commands:**
- Manual: launch `nvim` with `$OROSHI_ROOT` pointing to a worktree, verify config loads from worktree
- No bats/vitest tests apply here

**Prior art for `$OROSHI_ROOT` usage in Lua:**
- `tools/vim/nvim/config/lua/oroshi/filetypes/colors.lua` — uses `$OROSHI_ROOT` for external command paths

## Discoveries

<!-- Append-only. Agents add findings here after each issue. -->
